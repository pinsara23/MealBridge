class AppRoutes {
  // Onboarding
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  
  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Donor
  static const String donorDashboard = '/donor/dashboard';
  static const String postFood = '/donor/post-food';
  static const String myDonations = '/donor/my-donations';
  static const String donationDetails = '/donor/donation-details';
  static const String donorHistory = '/donor/history';
  
  // Recipient
  static const String recipientHome = '/recipient/home';
  static const String foodDetails = '/recipient/food-details';
  static const String claimFood = '/recipient/claim-food';
  static const String myClaimedFood = '/recipient/my-claimed-food';
  
  // Volunteer
  static const String volunteerDashboard = '/volunteer/dashboard';
  static const String taskDetails = '/volunteer/task-details';
  static const String qrScan = '/volunteer/qr-scan';
  
  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminReports = '/admin/reports';
}

enum UserRole {
  donor,
  recipient,
  volunteer,
  admin,
}

class AppConstants {
  static const String appName = 'MealBridge';
  static const String appTagline = 'Real-Time Food Redistribution for Social Good';
  
  // Food Types
  static const List<String> foodTypes = [
    'Cooked Food',
    'Raw Ingredients',
    'Packed Food',
    'Bakery Items',
    'Fruits & Vegetables',
  ];
  
  // Urgency Levels
  static const String urgentWithin1Hour = 'Urgent (Within 1 hour)';
  static const String moderateWithin3Hours = 'Moderate (Within 3 hours)';
  static const String lowWithin6Hours = 'Low (Within 6 hours)';
  
  // Task Status
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';
}
