import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/food_type_chip.dart';

class MyClaimedFoodScreen extends StatelessWidget {
  const MyClaimedFoodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data
    final claimedFood = [
      {
        'id': '1',
        'name': 'Rice and Curry',
        'quantity': 'Serves 10',
        'status': 'Confirmed',
        'statusStep': 1, // 0=Pending, 1=Confirmed, 2=Preparing, 3=Ready, 4=Completed
        'pickupTime': '5:00 PM - 7:00 PM',
        'location': '123 Main Street',
        'isVeg': true,
      },
      {
        'id': '2',
        'name': 'Fresh Vegetables',
        'quantity': '5 kg',
        'status': 'Ready for Pickup',
        'statusStep': 3,
        'pickupTime': '6:00 PM - 8:00 PM',
        'location': '456 Oak Avenue',
        'isVeg': true,
      },
      {
        'id': '3',
        'name': 'Chicken Biryani',
        'quantity': 'Serves 15',
        'status': 'Completed',
        'statusStep': 4,
        'pickupTime': '7:00 PM - 9:00 PM',
        'location': '789 Pine Road',
        'isVeg': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claimed Food', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5)),
      ),
      body: Container(
        color: const Color(0xFFF9FBFF),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
        itemCount: claimedFood.length,
        itemBuilder: (context, index) {
          final food = claimedFood[index];
          return _ClaimedFoodCard(
            name: food['name'] as String,
            quantity: food['quantity'] as String,
            status: food['status'] as String,
            statusStep: food['statusStep'] as int,
            pickupTime: food['pickupTime'] as String,
            location: food['location'] as String,
            isVeg: food['isVeg'] as bool,
          );
        },
      ),
      ),
    );
  }
}

class _ClaimedFoodCard extends StatelessWidget {
  final String name;
  final String quantity;
  final String status;
  final int statusStep;
  final String pickupTime;
  final String location;
  final bool isVeg;

  const _ClaimedFoodCard({
    required this.name,
    required this.quantity,
    required this.status,
    required this.statusStep,
    required this.pickupTime,
    required this.location,
    required this.isVeg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                      letterSpacing: -0.3,
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
                const Icon(Icons.restaurant_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  quantity,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Pickup Time
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  pickupTime,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Location
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.directions_rounded),
                  onPressed: () {},
                  color: AppColors.primary,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Order Tracking Status Bar - Only for ongoing orders
            if (statusStep < 4) ...[
              _OrderTrackingBar(currentStep: statusStep),
              const SizedBox(height: 16),
            ],
            
            // Status and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusChip(status: status),
                if (status != 'Completed')
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: const Text('Contact'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Order Tracking Status Bar Widget
class _OrderTrackingBar extends StatefulWidget {
  final int currentStep;

  const _OrderTrackingBar({required this.currentStep});

  @override
  State<_OrderTrackingBar> createState() => _OrderTrackingBarState();
}

class _OrderTrackingBarState extends State<_OrderTrackingBar> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'icon': Icons.check_circle_outline, 'label': 'Claimed'},
      {'icon': Icons.verified_outlined, 'label': 'Confirmed'},
      {'icon': Icons.restaurant_menu, 'label': 'Preparing'},
      {'icon': Icons.local_shipping_outlined, 'label': 'Ready'},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.04),
            AppColors.secondary.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Order Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Connector line
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex < widget.currentStep;
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            )
                          : null,
                      color: isCompleted ? null : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              } else {
                // Status step
                final stepIndex = index ~/ 2;
                final step = steps[stepIndex];
                final isCompleted = stepIndex < widget.currentStep;
                final isCurrent = stepIndex == widget.currentStep;

                return Column(
                  children: [
                    // Blinking current step
                    isCurrent
                        ? AnimatedBuilder(
                            animation: _blinkAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(_blinkAnimation.value),
                                      AppColors.secondary.withOpacity(_blinkAnimation.value),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(_blinkAnimation.value * 0.6),
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  step['icon'] as IconData,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              );
                            },
                          )
                        : AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: isCompleted
                                  ? const LinearGradient(
                                      colors: [AppColors.primary, AppColors.secondary],
                                    )
                                  : null,
                              color: isCompleted ? null : AppColors.border,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              step['icon'] as IconData,
                              color: isCompleted ? Colors.white : AppColors.textSecondary,
                              size: 24,
                            ),
                          ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        step['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
