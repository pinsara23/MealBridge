import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Add intl: ^0.18.0 to pubspec.yaml
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
        title: const Text('History & Certificates'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Certificates'),
          ],
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        // 2. Error State
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // 3. Empty State
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No history found."));
        }

        final historyList = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final item = historyList[index];

            // --- DATA MAPPING ---
            // Extracting ONLY the requested fields
            final String name = item['foodDescription'] ?? 'Unknown Item';
            final String quantity = "${item['quantityKg']} kg"; // Adding 'kg' label
            final String status = item['status'] ?? 'Unknown';
            final String date = _formatDate(item['mustPickupBy']); // Using pickup date for display

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name, // foodDescription
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status, // status
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Date and Quantity Row
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          date, // Formatted Date
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.scale_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          quantity, // quantityKg
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
    },
    // ... other certs
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: certificates.length,
      itemBuilder: (context, index) {
        final cert = certificates[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Impact Certificate',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            cert['month']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _CertStat(
                        icon: Icons.volunteer_activism_rounded,
                        label: 'Donations',
                        value: cert['donations']!,
                      ),
                    ),
                    Expanded(
                      child: _CertStat(
                        icon: Icons.people_rounded,
                        label: 'People Fed',
                        value: cert['peopleFed']!,
                      ),
                    ),
                    Expanded(
                      child: _CertStat(
                        icon: Icons.eco_rounded,
                        label: 'CO₂ Saved',
                        value: cert['co2Saved']!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CertStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CertStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}