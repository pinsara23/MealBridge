import 'package:flutter/material.dart';
import '../theme/colors.dart';

class StatusChip extends StatelessWidget {
  final String status;
  
  const StatusChip({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = AppColors.warning;
        icon = Icons.schedule_rounded;
        break;
      case 'in progress':
      case 'active':
        chipColor = AppColors.info;
        icon = Icons.sync_rounded;
        break;
      case 'completed':
      case 'delivered':
        chipColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case 'confirmed':
        chipColor = const Color(0xFF7C3AED);
        icon = Icons.verified_rounded;
        break;
      case 'ready for pickup':
        chipColor = const Color(0xFF0EA5E9);
        icon = Icons.local_shipping_rounded;
        break;
      case 'cancelled':
        chipColor = AppColors.error;
        icon = Icons.cancel_rounded;
        break;
      default:
        chipColor = AppColors.textSecondary;
        icon = Icons.info_outline_rounded;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: chipColor),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: chipColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
