import 'package:flutter/material.dart';
import '../theme/colors.dart'; // Ensure this import points to your actual colors file

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  // --- NEW PARAMETERS ADDED TO FIX ERRORS ---
  final IconData? icon;
  final bool isOutlined;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,                // Added
    this.isOutlined = false,  // Added (defaults to false)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine colors based on isOutlined state
    final Color primaryColor = backgroundColor ?? AppColors.primary;
    
    // If outlined: Text/Icon is colored, Background is white/transparent.
    // If filled: Text/Icon is white, Background is colored.
    final Color fgColor = textColor ?? (isOutlined ? primaryColor : Colors.white);
    final Color bgColor = isOutlined ? Colors.transparent : primaryColor;
    final BorderSide border = isOutlined 
        ? BorderSide(color: primaryColor, width: 1.5) 
        : BorderSide.none;
    final double elevation = isOutlined ? 0 : 2;

    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor, // Affects text, icon, and ripple
          elevation: elevation,
          side: border, // Applies the border if isOutlined is true
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: fgColor,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Render Icon if provided
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Color is handled by foregroundColor property above
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}