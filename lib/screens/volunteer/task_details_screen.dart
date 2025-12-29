import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_chip.dart';

class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data
    final task = {
      'foodItem': 'Rice and Curry',
      'status': 'In Progress',
      'donorName': 'Green Valley Restaurant',
      'donorPhone': '+1 234 567 8900',
      'pickupAddress': '123 Main Street, City Center',
      'pickupCode': 'P1234',
      'recipientName': 'Community Center ABC',
      'recipientPhone': '+1 234 567 8901',
      'dropAddress': '456 Oak Avenue, Downtown',
      'dropCode': 'D5678',
      'distance': '2.5 km',
      'estimatedTime': '15 mins',
      'pickupTime': '5:00 PM - 5:30 PM',
      'notes': 'Please bring insulated bags',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    task['foodItem'] as String,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task['status'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Task Progress
            _TaskProgress(status: task['status'] as String),
            
            const SizedBox(height: 24),
            
            // Pickup Section
            _InfoSection(
              title: 'Pickup Information',
              icon: Icons.store_rounded,
              color: AppColors.primary,
              children: [
                _InfoItem(label: 'Donor', value: task['donorName'] as String),
                _InfoItem(
                  label: 'Phone',
                  value: task['donorPhone'] as String,
                  trailing: IconButton(
                    icon: const Icon(Icons.call_rounded, color: AppColors.primary),
                    onPressed: () {},
                  ),
                ),
                _InfoItem(label: 'Address', value: task['pickupAddress'] as String),
                _InfoItem(label: 'Time Window', value: task['pickupTime'] as String),
                _CodeDisplay(label: 'Pickup Code', code: task['pickupCode'] as String),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Get Directions Button
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.directions_rounded),
              label: const Text('Get Directions to Pickup'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Scan QR / Enter Code Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.qrScan);
              },
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan QR / Enter Code'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Drop Section
            _InfoSection(
              title: 'Drop Information',
              icon: Icons.location_on_rounded,
              color: AppColors.secondary,
              children: [
                _InfoItem(label: 'Recipient', value: task['recipientName'] as String),
                _InfoItem(
                  label: 'Phone',
                  value: task['recipientPhone'] as String,
                  trailing: IconButton(
                    icon: const Icon(Icons.call_rounded, color: AppColors.secondary),
                    onPressed: () {},
                  ),
                ),
                _InfoItem(label: 'Address', value: task['dropAddress'] as String),
                _CodeDisplay(label: 'Drop Code', code: task['dropCode'] as String),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Trip Info
            Row(
              children: [
                Expanded(
                  child: _TripInfoCard(
                    icon: Icons.directions_car_rounded,
                    label: 'Distance',
                    value: task['distance'] as String,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TripInfoCard(
                    icon: Icons.access_time_rounded,
                    label: 'Est. Time',
                    value: task['estimatedTime'] as String,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notes
            if (task['notes'] != null)
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
                          'Special Instructions',
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
                      task['notes'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Offline Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off_rounded, color: AppColors.warning),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This task can be completed offline. Data will sync when you\'re back online.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
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
  }
}

class _TaskProgress extends StatelessWidget {
  final String status;

  const _TaskProgress({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = ['Assigned', 'Picked Up', 'Delivered'];
    int currentStep = 1; // Mock current step
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index <= currentStep;
          final isLast = index == steps.length - 1;
          
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.primary : AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 11,
                        color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppColors.primary : AppColors.border,
                      margin: const EdgeInsets.only(bottom: 20),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoItem({
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                const SizedBox(height: 4),
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
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _CodeDisplay extends StatelessWidget {
  final String label;
  final String code;

  const _CodeDisplay({
    required this.label,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                code,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code copied to clipboard')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TripInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TripInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
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
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
