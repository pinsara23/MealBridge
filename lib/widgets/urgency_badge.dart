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
    String shortLabel;
    
    if (urgencyLevel.toLowerCase().contains('urgent') || urgencyLevel.contains('1')) {
      badgeColor = AppColors.urgent;
      icon = Icons.bolt_rounded;
      shortLabel = 'Urgent';
    } else if (urgencyLevel.toLowerCase().contains('moderate') || urgencyLevel.contains('3')) {
      badgeColor = AppColors.moderateUrgency;
      icon = Icons.schedule_rounded;
      shortLabel = 'Moderate';
    } else {
      badgeColor = AppColors.lowUrgency;
      icon = Icons.check_circle_outline_rounded;
      shortLabel = 'Low';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor.withOpacity(0.15),
            badgeColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 5),
          Text(
            shortLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: badgeColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
