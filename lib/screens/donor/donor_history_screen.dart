import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import '../../services/api_service.dart';

class DonorHistoryScreen extends StatefulWidget {
  const DonorHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DonorHistoryScreen> createState() => _DonorHistoryScreenState();
}

class _DonorHistoryScreenState extends State<DonorHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History & Impact',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
                  ],
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: 'History'),
                  Tab(text: 'Certificates'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _HistoryTab(), // Now using the connected tab
          _CertificatesTab(),
        ],
      ),
    );
  }
}

// --- HISTORY TAB (Connected to API) ---
class _HistoryTab extends StatefulWidget {
  const _HistoryTab({Key? key}) : super(key: key);

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  Future<List<dynamic>> _fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId'); // Auto-get Restaurant ID

    if (token != null && userId != null) {
      return _apiService.getDonationHistory(token, userId);
    } else {
      throw Exception("User not logged in");
    }
  }

  // Helper to format ISO date (2026-01-13...) to readable string
  String _formatDate(String? isoDate) {
    if (isoDate == null) return "Unknown Date";
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (e) {
      return isoDate;
    }
  }

  // Helper for Status Colors
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED': return Colors.green;
      case 'CLAIMED': return Colors.blue;
      case 'EXPIRED': return Colors.red;
      case 'CANCELLED': return Colors.orange;
      default: return Colors.grey;
    }
  }

  int? _extractDonationId(dynamic item) {
    final dynamic rawId = item['donationId'] ?? item['id'];
    if (rawId is int) return rawId;
    if (rawId == null) return null;
    return int.tryParse(rawId.toString());
  }

  Future<void> _showDonationImage(int donationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (!mounted) return;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
      return;
    }

    final imageFuture = _apiService.getDonationProofImage(token, donationId);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Donation #$donationId Proof'),
          content: SizedBox(
            width: 320,
            child: FutureBuilder<Uint8List?>(
              future: imageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No Image Uploaded',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No image found',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FBFF),
      child: FutureBuilder<List<dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppColors.primary.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text('No history available', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final historyList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            physics: const BouncingScrollPhysics(),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[index];

              final String name = item['foodDescription'] ?? 'Unknown Item';
              final String quantity = "${item['quantityKg']} kg";
              final String status = item['status'] ?? 'Unknown';
              final String date = _formatDate(item['mustPickupBy']);
              final int? donationId = _extractDonationId(item);

              return GestureDetector(
                onTap: () {
                  if (donationId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Donation ID not available')),
                    );
                    return;
                  }
                  _showDonationImage(donationId);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                    border: Border.all(color: Colors.black.withOpacity(0.02), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            _buildStatusChip(status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildInfoRow(Icons.calendar_today_rounded, date, AppColors.primary),
                            const SizedBox(width: 16),
                            _buildInfoRow(Icons.scale_rounded, quantity, AppColors.secondary),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Icon(Icons.photo_library_outlined, size: 14, color: AppColors.textSecondary),
                            SizedBox(width: 6),
                            Text(
                              'Tap to view proof image',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// --- CERTIFICATES TAB (Static Data for now) ---
class _CertificatesTab extends StatelessWidget {
  final List<Map<String, String>> certificates = [
    {
      'month': 'December 2025',
      'donations': '8',
      'peopleFed': '87',
      'co2Saved': '45 kg',
      'level': 'Gold',
    },
    {
      'month': 'November 2025',
      'donations': '5',
      'peopleFed': '42',
      'co2Saved': '22 kg',
      'level': 'Silver',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FBFF),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          final cert = certificates[index];
          final isGold = cert['level'] == 'Gold';

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGold 
                  ? [const Color(0xFFFFF7E6), Colors.white] 
                  : [const Color(0xFFF5F5F5), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isGold ? Colors.orange : Colors.grey).withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                )
              ],
              border: Border.all(
                color: (isGold ? Colors.orange : Colors.grey).withOpacity(0.1),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      size: 120,
                      color: (isGold ? Colors.orange : Colors.grey).withOpacity(0.05),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (isGold ? Colors.orange : Colors.grey).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                color: isGold ? Colors.orange.shade700 : Colors.grey.shade700,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Impact Award',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: isGold ? Colors.orange.shade900 : AppColors.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  Text(
                                    cert['month']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isGold ? Colors.orange.shade800.withOpacity(0.7) : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CertStat(
                              icon: Icons.volunteer_activism_rounded,
                              label: 'Donations',
                              value: cert['donations']!,
                              color: isGold ? Colors.orange.shade700 : AppColors.primary,
                            ),
                            _CertStat(
                              icon: Icons.people_rounded,
                              label: 'People Fed',
                              value: cert['peopleFed']!,
                              color: isGold ? Colors.orange.shade700 : AppColors.secondary,
                            ),
                            _CertStat(
                              icon: Icons.eco_rounded,
                              label: 'CO₂ Saved',
                              value: cert['co2Saved']!,
                              color: isGold ? Colors.orange.shade700 : Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text('Share Impact', style: TextStyle(fontWeight: FontWeight.w800)),
                            style: TextButton.styleFrom(
                              foregroundColor: isGold ? Colors.orange.shade800 : AppColors.primary,
                              backgroundColor: (isGold ? Colors.orange : AppColors.primary).withOpacity(0.1),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CertStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CertStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.6), size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
