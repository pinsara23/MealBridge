import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
// import '../../widgets/status_chip.dart'; // Uncomment if you have this file
// import '../../widgets/food_type_chip.dart'; // Uncomment if you have this file

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({Key? key}) : super(key: key);

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _donationsFuture;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  // 1. Load Data Logic
  void _loadDonations() {
    setState(() {
      _donationsFuture = _fetchData();
    });
  }

  Future<List<dynamic>> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');

    if (token != null && userId != null) {
      return _apiService.getRestaurantDonations(token, userId);
    } else {
      throw Exception("User not logged in");
    }
  }

  // Helper to format Date string "2026-01-13T15:35..." -> "Jan 13, 03:35 PM"
  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('MMM dd, hh:mm a').format(dt);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Active Donations',
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
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      // 2. Refresh Indicator (Pull-to-Refresh)
      body: Container(
        color: const Color(0xFFF9FBFF),
        child: RefreshIndicator(
          onRefresh: () async => _loadDonations(),
          color: AppColors.primary,
          child: FutureBuilder<List<dynamic>>(
            future: _donationsFuture,
            builder: (context, snapshot) {
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                        ),
                        const SizedBox(height: 24),
                        const Text('Oops! Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Text('${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loadDonations,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), shape: BoxShape.circle),
                        child: Icon(Icons.inventory_2_outlined, color: AppColors.primary.withOpacity(0.5), size: 64),
                      ),
                      const SizedBox(height: 24),
                      const Text('No active donations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      const Text('Your current postings will appear here.', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 32),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.postFood),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Post Now'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final donations = snapshot.data!;
              
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: donations.length,
                itemBuilder: (context, index) {
                  final item = donations[index];
                  
                  return _DonationCard(
                    name: item['foodDescription'] ?? 'No Description',
                    quantity: "${item['quantityKg']} Kg",
                    status: item['status'] ?? 'UNKNOWN',
                    time: _formatDate(item['mustPickupBy'] ?? ''),
                    isVeg: false, 
                    onTap: () {},
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final String name;
  final String quantity;
  final String status;
  final String time;
  final bool isVeg;
  final VoidCallback onTap;

  const _DonationCard({
    required this.name,
    required this.quantity,
    required this.status,
    required this.time,
    required this.isVeg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.02), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isVeg ? Colors.green : Colors.orange).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isVeg ? Icons.eco_rounded : Icons.restaurant_rounded,
                        color: isVeg ? Colors.green : Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Expires at $time",
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildInfoBadge(Icons.scale_rounded, quantity, AppColors.primary),
                    const SizedBox(width: 12),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(Icons.edit_rounded, 'Edit', AppColors.primary, () {}),
                    const SizedBox(width: 12),
                    _buildActionButton(Icons.delete_rounded, 'Remove', Colors.red, () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper color for status
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE': return Colors.green;
      case 'CLAIMED': return Colors.blue; // AppColors.info
      case 'COMPLETED': return Colors.grey;
      default: return Colors.orange;
    }
  }
}