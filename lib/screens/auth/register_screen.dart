import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl to pubspec.yaml for time formatting
import '../../theme/colors.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart'; // Assuming you have this from Login
import '../../widgets/custom_text_field.dart'; // Assuming you have this from Login

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _role = 'Restaurant'; // Default, will be overwritten by arguments

  // --- Controllers (Shared) ---
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // --- Controllers (Restaurant) ---
  final _businessNameCtrl = TextEditingController();
  final _openTimeCtrl = TextEditingController();
  final _closeTimeCtrl = TextEditingController();
  double? _latitude;
  double? _longitude;

  // --- Controllers (Volunteer) ---
  final _presidentNameCtrl = TextEditingController();
  final _orgNameCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the role passed from Login Screen
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      setState(() {
        _role = args;
      });
    }
  }

  // --- ACTIONS ---

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      // Format to HH:mm:ss for backend
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      final formatted = DateFormat('HH:mm:ss').format(dt);
      controller.text = formatted;
    }
  }

  void _getLocation() {
    // For demo/simplicity, we set the example coordinates provided.
    // In a real app, use the 'geolocator' package here.
    setState(() {
      _latitude = 6.8471142813513906;
      _longitude = 79.94666928256423;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location retrieved successfully! 📍"), backgroundColor: Colors.green),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Special check for Location if Restaurant
    if (_role == 'Restaurant' && (_latitude == null || _longitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please set your location"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_role == 'Restaurant') {
        final data = {
          "businessName": _businessNameCtrl.text.trim(),
          "email": _emailCtrl.text.trim(),
          "password": _passwordCtrl.text.trim(),
          "phoneNumber": _phoneCtrl.text.trim(),
          "latitude": _latitude,
          "longitude": _longitude,
          "openTime": _openTimeCtrl.text.trim(),
          "closeTime": _closeTimeCtrl.text.trim(),
        };
        await _apiService.registerRestaurant(data);
      } else {
        // Volunteer
        final data = {
          "presidentFullName": _presidentNameCtrl.text.trim(),
          "organizationName": _orgNameCtrl.text.trim(),
          "email": _emailCtrl.text.trim(),
          "phoneNumber": _phoneCtrl.text.trim(),
          "password": _passwordCtrl.text.trim(),
        };
        await _apiService.registerVolunteer(data);
      }

      if (!mounted) return;
      
      // Success Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Registration Successful"),
          content: Text(_role == 'Volunteer' 
              ? "Your account is pending approval by an admin." 
              : "Account created! You can now login."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Go back to Login
              }, 
              child: const Text("Back to Login")
            ),
          ],
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors based on Role
    final bool isRestaurant = _role == 'Restaurant';
    final Color mainColor = isRestaurant ? AppColors.primary : AppColors.volunteer;
    final IconData mainIcon = isRestaurant ? Icons.store_rounded : Icons.volunteer_activism_rounded;

    return Scaffold(
      body: Container(
        height: double.infinity, // Ensure full height background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              mainColor.withOpacity(0.1),
              Colors.white,
              mainColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HEADER ---
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: mainColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Icon(mainIcon, size: 50, color: mainColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Join as $_role",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    isRestaurant ? "Share your surplus food." : "Help distribute to those in need.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // --- RESTAURANT SPECIFIC FIELDS ---
                  if (isRestaurant) ...[
                    CustomTextField(
                      label: "Business Name",
                      hint: "e.g. Masma Eat",
                      controller: _businessNameCtrl,
                      prefixIcon: Icons.store,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(_openTimeCtrl),
                            child: AbsorbPointer(
                              child: CustomTextField(
                                label: "Opens At",
                                hint: "08:00:00",
                                controller: _openTimeCtrl,
                                prefixIcon: Icons.access_time,
                                validator: (v) => v!.isEmpty ? "Required" : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(_closeTimeCtrl),
                            child: AbsorbPointer(
                              child: CustomTextField(
                                label: "Closes At",
                                hint: "22:00:00",
                                controller: _closeTimeCtrl,
                                prefixIcon: Icons.access_time_filled,
                                validator: (v) => v!.isEmpty ? "Required" : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Location Picker Button
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.location_on, color: Colors.orange),
                        ),
                        title: Text(_latitude == null ? "Set Location" : "Location Set"),
                        subtitle: Text(_latitude == null ? "Tap to get coordinates" : "$_latitude, $_longitude"),
                        trailing: const Icon(Icons.my_location, color: Colors.blue),
                        onTap: _getLocation,
                      ),
                    ),
                  ],

                  // --- VOLUNTEER SPECIFIC FIELDS ---
                  if (!isRestaurant) ...[
                    CustomTextField(
                      label: "President's Name",
                      hint: "Full Name",
                      controller: _presidentNameCtrl,
                      prefixIcon: Icons.person,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: "Organization Name",
                      hint: "e.g. Meal Bridge",
                      controller: _orgNameCtrl,
                      prefixIcon: Icons.group_work,
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ],

                  // --- COMMON FIELDS ---
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Email",
                    hint: "contact@email.com",
                    controller: _emailCtrl,
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => !v!.contains('@') ? "Invalid Email" : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Phone Number",
                    hint: "0771234567",
                    controller: _phoneCtrl,
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.length < 9 ? "Invalid Phone" : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: "Password",
                    hint: "Create a secure password",
                    controller: _passwordCtrl,
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    validator: (v) => v!.length < 4 ? "Too short" : null,
                  ),

                  const SizedBox(height: 32),

                  // --- REGISTER BUTTON ---
                  CustomButton(
                    text: "Create Account",
                    onPressed: _handleRegister,
                    isLoading: _isLoading,
                    backgroundColor: mainColor, // Green for Volunteer, Orange for Restaurant
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}