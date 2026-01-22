import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  
  // New: Role Selection State
  String _selectedRole = 'Restaurant'; // Default value
  final List<String> _roles = ['Restaurant', 'Volunteer', 'Admin'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 1. Call Backend
        // Note: You might need to pass the selected role to your API if your backend requires it for login differentiation.
        // Assuming your current API handles role detection automatically based on email/table, otherwise update _apiService.login to accept role.
        final responseData = await _apiService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // 2. Save Token & ID to Storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);

        // Save Display Name Logic
        final dynamic userObj = responseData['user'];
        final dynamic restaurantObj = responseData['restaurant'];
        final String? displayName = (responseData['restaurantName'] ??
                responseData['hotelName'] ??
                responseData['name'] ??
                responseData['username'] ??
                responseData['fullName'] ??
                (userObj is Map ? (userObj['name'] ?? userObj['username'] ?? userObj['fullName']) : null) ??
                (restaurantObj is Map ? (restaurantObj['name'] ?? restaurantObj['restaurantName'] ?? restaurantObj['hotelName']) : null))
            ?.toString();

        if (displayName != null && displayName.trim().isNotEmpty) {
          await prefs.setString('displayName', displayName.trim());
        }

        // Save User ID
        if (responseData['userId'] is int) {
          await prefs.setInt('userId', responseData['userId']);
        } else {
          await prefs.setInt('userId', int.parse(responseData['userId'].toString()));
        }

        // Save Role from Backend (Safety check against selected role if needed)
        String backendRole = responseData['role'];
        await prefs.setString('role', backendRole);

        if (!mounted) return;

        // 3. Navigate Based on Backend Role (Ensures security)
        String route;
        if (backendRole == 'ROLE_RESTAURANT') {
          route = AppRoutes.donorDashboard;
        } else if (backendRole == 'ROLE_VOLUNTEER') {
          route = AppRoutes.volunteerDashboard;
        } else if (backendRole == 'ROLE_ADMIN' || backendRole == 'ROLE_SUPER_ADMIN') {
          route = AppRoutes.adminDashboard;
        } else {
          // Fallback or Error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unknown Role Assigned'), backgroundColor: Colors.orange),
          );
          return;
        }

        // Optional: Check if selected dropdown role matches backend role
        // This is just a UI warning, the backend role is the source of truth.
        if (_mapRoleToBackend(_selectedRole) != backendRole && backendRole != 'ROLE_SUPER_ADMIN') {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged in as $backendRole (Note: You selected $_selectedRole)'), backgroundColor: Colors.blue),
          );
        }

        Navigator.pushReplacementNamed(context, route);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Failed: ${e.toString().replaceAll("Exception:", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Helper to map UI dropdown to potential backend role strings for comparison
  String _mapRoleToBackend(String uiRole) {
    switch (uiRole) {
      case 'Restaurant': return 'ROLE_RESTAURANT';
      case 'Volunteer': return 'ROLE_VOLUNTEER';
      case 'Admin': return 'ROLE_ADMIN';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.08),
              Colors.white,
              AppColors.secondary.withOpacity(0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Center( // Centers content vertically on larger screens
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo Section
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withOpacity(0.2),
                                  AppColors.primary.withOpacity(0.05),
                                ],
                              ),
                              shape: BoxShape.circle, // Circular Logo container
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.food_bank_rounded,
                              size: 56,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Login to continue',
                      style: TextStyle(
                        fontSize: 17,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // --- ROLE DROPDOWN ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down_circle, color: AppColors.primary),
                          items: _roles.map((String role) {
                            IconData icon;
                            if (role == 'Restaurant') icon = Icons.restaurant;
                            else if (role == 'Volunteer') icon = Icons.volunteer_activism;
                            else icon = Icons.admin_panel_settings;

                            return DropdownMenuItem<String>(
                              value: role,
                              child: Row(
                                children: [
                                  Icon(icon, size: 20, color: Colors.grey[700]),
                                  const SizedBox(width: 12),
                                  Text(role, style: const TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Email Field
                    CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    CustomTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 2) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.forgotPassword);
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Button
                    CustomButton(
                      text: 'Login as $_selectedRole', // Dynamic Button Text
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 32),

                    // Register Link (Only show if not Admin, assuming Admins are added manually)
                    if (_selectedRole != 'Admin') 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          TextButton(
                            onPressed: () {
                              // Pass the selected role to registration page
                              // Mapping string to UserRole enum if needed, or pass string directly
                              Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                                arguments: _selectedRole, 
                              );
                            },
                            child: const Text('Register'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}