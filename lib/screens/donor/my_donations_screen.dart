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
        title: const Text('My Active Donations'),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  // If you removed FoodTypeChip, use a simple Icon/Text instead
                  Icon(
                    isVeg ? Icons.eco : Icons.restaurant, 
                    color: isVeg ? Colors.green : Colors.redAccent
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Quantity
              Row(
                children: [
                  const Icon(Icons.scale_rounded, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    quantity,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Time (Pickup By)
              Row(
                children: [
                  const Icon(Icons.access_time_filled, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    "Pickup by: $time",
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Status and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Simple Status Chip logic since widget file might be missing
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(status)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded),
                        onPressed: () {},
                        color: AppColors.primary,
                        iconSize: 20,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded),
                        onPressed: () {},
                        color: AppColors.error, // Colors.red
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ],
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