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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isVeg ? AppColors.veg.withOpacity(0.15) : AppColors.nonVeg.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVeg ? AppColors.veg : AppColors.nonVeg,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isVeg ? AppColors.veg : AppColors.nonVeg,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isVeg ? 'VEG' : 'NON-VEG',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isVeg ? AppColors.veg : AppColors.nonVeg,
            ),
          ),
        ],
      ),
    );
  }
}
