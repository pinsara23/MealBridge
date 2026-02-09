import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF4CAF50); // Fresh green
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF388E3C);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF9800); // Warm orange
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFF57C00);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Urgency Colors
  static const Color urgent = Color(0xFFFF5252);
  static const Color moderateUrgency = Color(0xFFFFB74D);
  static const Color lowUrgency = Color(0xFF81C784);
  
  // Food Type Colors
  static const Color veg = Color(0xFF4CAF50);
  static const Color nonVeg = Color(0xFFFF5722);
  
  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  
  // Role Colors
  static const Color donor = Color(0xFF2196F3);
  static const Color recipient = Color(0xFF9C27B0);
  static const Color volunteer = Color(0xFFFF9800);
  static const Color admin = Color(0xFF607D8B);
  
  // Shimmer / Subtle Surface
  static const Color shimmer = Color(0xFFF1F5F9);
  static const Color cardShadow = Color(0x0A000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient urgentGradient = LinearGradient(
    colors: [urgent, Color(0xFFFF8A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient donorGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient adminGradient = LinearGradient(
    colors: [Color(0xFF455A64), Color(0xFF78909C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient volunteerGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
