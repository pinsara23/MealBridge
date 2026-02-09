import 'package:flutter/material.dart';
import '../theme/colors.dart';

class FoodTypeChip extends StatelessWidget {
  final bool isVeg;
  
  const FoodTypeChip({
    Key? key,
    required this.isVeg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? AppColors.veg : AppColors.nonVeg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVeg ? Icons.eco_rounded : Icons.restaurant_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            isVeg ? 'VEG' : 'NON-VEG',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
