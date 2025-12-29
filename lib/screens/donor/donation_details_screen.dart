import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/food_type_chip.dart';
import '../../widgets/custom_button.dart';

class DonationDetailsScreen extends StatelessWidget {
  const DonationDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data - in real app, this would come from arguments
    final donation = {
      'name': 'Rice and Curry',
      'quantity': 'Serves 10 people',
      'status': 'In Progress',
      'isVeg': true,
      'location': '123 Main Street, City Center',
      'pickupTime': '6:00 PM',
      'notes': 'Please bring containers',
      'donorName': 'John Doe',
      'donorPhone': '+1 234 567 8900',
      'claimedBy': 'Community Center ABC',
      'volunteerName': 'Jane Smith',
      'volunteerPhone': '+1 234 567 8901',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image
            Container(
              width: double.infinity,
              height: 250,
              color: AppColors.surfaceLight,
              child: const Icon(
                Icons.fastfood_rounded,
                size: 80,
                color: AppColors.textHint,
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          donation['name'] as String,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      FoodTypeChip(isVeg: donation['isVeg'] as bool),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  StatusChip(status: donation['status'] as String),
                  
                  const SizedBox(height: 24),
                  
                  // Live Status Tracker
                  _StatusTracker(currentStatus: donation['status'] as String),
                  
                  const SizedBox(height: 24),
                  
                  // Details Section
                  _InfoSection(
                    title: 'Donation Information',
                    items: [
                      _InfoItem(
                        icon: Icons.restaurant_rounded,
                        label: 'Quantity',
                        value: donation['quantity'] as String,
                      ),
                      _InfoItem(
                        icon: Icons.access_time_rounded,
                        label: 'Pickup Time',
                        value: donation['pickupTime'] as String,
                      ),
                      _InfoItem(
                        icon: Icons.location_on_rounded,
                        label: 'Location',
                        value: donation['location'] as String,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Claimed By Section
                  _InfoSection(
                    title: 'Claimed By',
                    items: [
                      _InfoItem(
                        icon: Icons.business_rounded,
                        label: 'Organization',
                        value: donation['claimedBy'] as String,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Volunteer Section
                  _InfoSection(
                    title: 'Assigned Volunteer',
                    items: [
                      _InfoItem(
                        icon: Icons.person_rounded,
                        label: 'Name',
                        value: donation['volunteerName'] as String,
                      ),
                      _InfoItem(
                        icon: Icons.phone_rounded,
                        label: 'Phone',
                        value: donation['volunteerPhone'] as String,
                        actionIcon: Icons.call_rounded,
                        onAction: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notes
                  if (donation['notes'] != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.notes_rounded, color: AppColors.info),
                              SizedBox(width: 8),
                              Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            donation['notes'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Contact Volunteer',
                          onPressed: () {},
                          icon: Icons.phone_rounded,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel Donation',
                          onPressed: () {},
                          isOutlined: true,
                          icon: Icons.cancel_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTracker extends StatelessWidget {
  final String currentStatus;

  const _StatusTracker({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'title': 'Posted', 'icon': Icons.add_circle_rounded},
      {'title': 'Claimed', 'icon': Icons.check_circle_rounded},
      {'title': 'Picked Up', 'icon': Icons.local_shipping_rounded},
      {'title': 'Delivered', 'icon': Icons.done_all_rounded},
    ];

    int currentStep = 1; // Mock current step
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Tracker',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length, (index) {
              final isCompleted = index <= currentStep;
              final isLast = index == steps.length - 1;
              
              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.primary
                                : AppColors.border,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            steps[index]['icon'] as IconData,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          steps[index]['title'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isCompleted
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: isCompleted
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted ? AppColors.primary : AppColors.border,
                          margin: const EdgeInsets.only(bottom: 30),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;

  const _InfoSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (actionIcon != null)
            IconButton(
              icon: Icon(actionIcon, color: AppColors.primary),
              onPressed: onAction,
            ),
        ],
      ),
    );
  }
}
