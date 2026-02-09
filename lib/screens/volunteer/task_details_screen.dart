import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        title: const Text(
          'Mission Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    task['foodItem'] as String,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sync_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          task['status'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Task Progress
            _TaskProgress(status: task['status'] as String),
            
            const SizedBox(height: 32),
            
            // Pickup Section
            _InfoSection(
              title: 'Pickup Details',
              icon: Icons.store_rounded,
              color: AppColors.primary,
              children: [
                _InfoItem(label: 'Restaurant', value: task['donorName'] as String),
                _InfoItem(
                  label: 'Phone',
                  value: task['donorPhone'] as String,
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.call_rounded, color: AppColors.primary, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ),
                _InfoItem(label: 'Address', value: task['pickupAddress'] as String),
                _InfoItem(label: 'Time Window', value: task['pickupTime'] as String),
                _CodeDisplay(label: 'Pickup Passcode', code: task['pickupCode'] as String),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Interaction Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.directions_rounded, size: 20),
                    label: const Text("Navigate"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.qrScan);
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                    label: const Text("Verify QR"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Drop Section
            _InfoSection(
              title: 'Delivery Details',
              icon: Icons.location_on_rounded,
              color: AppColors.secondary,
              children: [
                _InfoItem(label: 'Recipient Org', value: task['recipientName'] as String),
                _InfoItem(
                  label: 'Phone',
                  value: task['recipientPhone'] as String,
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.call_rounded, color: AppColors.secondary, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ),
                _InfoItem(label: 'Address', value: task['dropAddress'] as String),
                _CodeDisplay(label: 'Drop Passcode', code: task['dropCode'] as String, isSecondary: true),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Trip Details
            const Text(
              "Trip Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TripInfoCard(
                    icon: Icons.route_rounded,
                    label: 'Distance',
                    value: task['distance'] as String,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TripInfoCard(
                    icon: Icons.timer_rounded,
                    label: 'Est. Time',
                    value: task['estimatedTime'] as String,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Notes
            if (task['notes'] != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.sticky_note_2_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      task['notes'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withOpacity(0.8),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Offline Info
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade100, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.offline_bolt_rounded, color: Colors.amber.shade700, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Mission available offline. Progress will sync once you are back online.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mission Progress",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(steps.length, (index) {
              final isCompleted = index <= currentStep;
              final isLast = index == steps.length - 1;
              
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isCompleted ? AppColors.primary : Colors.grey.shade100,
                              shape: BoxShape.circle,
                              border: isCompleted ? null : Border.all(color: Colors.grey.shade300),
                            ),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            steps[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary.withOpacity(0.5),
                              fontWeight: isCompleted ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 40,
                        height: 2,
                        color: isCompleted ? AppColors.primary : Colors.grey.shade200,
                        margin: const EdgeInsets.only(bottom: 24),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary.withOpacity(0.4),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
  final bool isSecondary;

  const _CodeDisplay({
    required this.label,
    required this.code,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = isSecondary ? AppColors.secondary : AppColors.primary;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: themeColor.withOpacity(0.6),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                code,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: themeColor,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: AppColors.textPrimary,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: themeColor.withOpacity(0.1), blurRadius: 4),
                ],
              ),
              child: Icon(Icons.copy_all_rounded, color: themeColor, size: 20),
            ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
