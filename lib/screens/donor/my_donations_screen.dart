import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Ensure intl is in pubspec.yaml
import '../../theme/colors.dart';
import '../../services/api_service.dart';
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
          'My Active Donations',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      // 2. Refresh Indicator (Pull-to-Refresh)
      body: RefreshIndicator(
        onRefresh: () async => _loadDonations(),
        child: FutureBuilder<List<dynamic>>(
          future: _donationsFuture,
          builder: (context, snapshot) {
            
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            // Error
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    TextButton(onPressed: _loadDonations, child: const Text("Retry")),
                  ],
                ),
              );
            }

            // Empty
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No donations found. Post some food!"));
            }

            // Success: List Data
            final donations = snapshot.data!;
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final item = donations[index];
                
                // Map API fields to UI
                return _DonationCard(
                  name: item['foodDescription'] ?? 'No Description',
                  quantity: "${item['quantityKg']} Kg",
                  status: item['status'] ?? 'UNKNOWN',
                  time: _formatDate(item['mustPickupBy'] ?? ''),
                  // API doesn't send 'isVeg' currently, defaulting to false or checking desc
                  isVeg: false, 
                  onTap: () {
                    // Navigate to details if needed
                  },
                );
              },
            );
          },
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
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primary.withOpacity(0.04),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Icon and Title
                Row(
                  children: [
                    // Icon Container with Gradient
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            isVeg ? Colors.green.shade400 : Colors.orange.shade400,
                            isVeg ? Colors.green.shade600 : Colors.orange.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isVeg 
                                ? Colors.green.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isVeg ? Icons.eco_rounded : Icons.restaurant_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Info Row - Quantity and Time
                Row(
                  children: [
                    // Quantity Badge
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.12),
                              AppColors.primary.withOpacity(0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.scale_rounded,
                              size: 20,
                              color: AppColors.primary.withOpacity(0.9),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              quantity,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.primary.withOpacity(0.95),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Pickup Time
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        size: 18,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Pickup: $time",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Status and Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(status).withOpacity(0.18),
                            _getStatusColor(status).withOpacity(0.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _getStatusColor(status).withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getStatusColor(status).withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Row(
                      children: [
                        // Edit Button
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.15),
                                AppColors.primary.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit_rounded),
                            onPressed: () {},
                            color: AppColors.primary,
                            iconSize: 22,
                            tooltip: 'Edit',
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Delete Button
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.error.withOpacity(0.15),
                                AppColors.error.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete_rounded),
                            onPressed: () {},
                            color: AppColors.error,
                            iconSize: 22,
                            tooltip: 'Delete',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
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