import 'package:flutter/material.dart';
import '../theme/colors.dart';

class UrgencyBadge extends StatelessWidget {
  final String urgencyLevel;
  
  const UrgencyBadge({
    Key? key,
    required this.urgencyLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    IconData icon;
    
    if (urgencyLevel.toLowerCase().contains('urgent') || urgencyLevel.contains('1')) {
      badgeColor = AppColors.urgent;
      icon = Icons.warning_rounded;
    } else if (urgencyLevel.toLowerCase().contains('moderate') || urgencyLevel.contains('3')) {
      badgeColor = AppColors.moderateUrgency;
      icon = Icons.access_time_rounded;
    } else {
      badgeColor = AppColors.lowUrgency;
      icon = Icons.check_circle_rounded;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            urgencyLevel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
