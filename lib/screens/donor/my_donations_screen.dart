import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/food_type_chip.dart';

class MyDonationsScreen extends StatelessWidget {
  const MyDonationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data
    final activeDonations = [
      {
        'id': '1',
        'name': 'Rice and Curry',
        'quantity': 'Serves 10 people',
        'status': 'Pending',
        'time': '30 mins ago',
        'isVeg': true,
      },
      {
        'id': '2',
        'name': 'Fresh Vegetables',
        'quantity': '5 kg',
        'status': 'In Progress',
        'time': '2 hours ago',
        'isVeg': true,
      },
      {
        'id': '3',
        'name': 'Chicken Biryani',
        'quantity': 'Serves 15 people',
        'status': 'Active',
        'time': '4 hours ago',
        'isVeg': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Active Donations'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeDonations.length,
        itemBuilder: (context, index) {
          final donation = activeDonations[index];
          return _DonationCard(
            name: donation['name'] as String,
            quantity: donation['quantity'] as String,
            status: donation['status'] as String,
            time: donation['time'] as String,
            isVeg: donation['isVeg'] as bool,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.donationDetails,
                arguments: donation,
              );
            },
          );
        },
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
                  FoodTypeChip(isVeg: isVeg),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Quantity
              Row(
                children: [
                  const Icon(
                    Icons.restaurant_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    quantity,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Time
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Status and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusChip(status: status),
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
                        color: AppColors.error,
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
}
