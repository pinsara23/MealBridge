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
        icon = Icons.access_time_rounded;
        break;
      case 'in progress':
      case 'active':
        chipColor = AppColors.info;
        icon = Icons.refresh_rounded;
        break;
      case 'completed':
      case 'delivered':
        chipColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        chipColor = AppColors.error;
        icon = Icons.cancel_rounded;
        break;
      default:
        chipColor = AppColors.textSecondary;
        icon = Icons.info_rounded;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}
