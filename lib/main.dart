import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

// Onboarding Screens
import 'screens/onboarding/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/role_selection_screen.dart';

// Auth Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

// Donor Screens
import 'screens/donor/donor_dashboard_screen.dart';
import 'screens/donor/post_food_screen.dart';
import 'screens/donor/my_donations_screen.dart';
import 'screens/donor/donation_details_screen.dart';
import 'screens/donor/donor_history_screen.dart';

// Recipient Screens
import 'screens/recipient/recipient_home_screen.dart';
import 'screens/recipient/food_details_screen.dart';
import 'screens/recipient/claim_food_screen.dart';
import 'screens/recipient/my_claimed_food_screen.dart';

// Volunteer Screens
import 'screens/volunteer/volunteer_dashboard_screen.dart';
import 'screens/volunteer/task_details_screen.dart';
import 'screens/volunteer/qr_scan_screen.dart';

// Admin Screens
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_reports_screen.dart';

void main() {
  runApp(const MealBridgeApp());
}

class MealBridgeApp extends StatelessWidget {
  const MealBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        // Onboarding Routes
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.roleSelection: (context) => const RoleSelectionScreen(),

        // Auth Routes
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),

        // Donor Routes
        AppRoutes.donorDashboard: (context) => const DonorDashboardScreen(),
        AppRoutes.postFood: (context) => const PostFoodScreen(),
        AppRoutes.myDonations: (context) => const MyDonationsScreen(),
        AppRoutes.donorHistory: (context) => const DonorHistoryScreen(),

        // Recipient Routes
        AppRoutes.recipientHome: (context) => const RecipientHomeScreen(),
        AppRoutes.foodDetails: (context) => const FoodDetailsScreen(),
        AppRoutes.claimFood: (context) => const ClaimFoodScreen(),
        AppRoutes.myClaimedFood: (context) => const MyClaimedFoodScreen(),

        // Volunteer Routes
        AppRoutes.volunteerDashboard: (context) => const VolunteerDashboardScreen(),
        AppRoutes.taskDetails: (context) => const TaskDetailsScreen(),
        AppRoutes.qrScan: (context) => const QRScanScreen(),

        // Admin Routes
        AppRoutes.adminDashboard: (context) => const AdminDashboardScreen(),
        AppRoutes.adminReports: (context) => const AdminReportsScreen(),
      },
    );
  }
}
