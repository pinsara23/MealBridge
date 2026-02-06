import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/colors.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class PostFoodScreen extends StatefulWidget {
  const PostFoodScreen({Key? key}) : super(key: key);

  @override
  State<PostFoodScreen> createState() => _PostFoodScreenState();
}

class _PostFoodScreenState extends State<PostFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _hoursController = TextEditingController(); // <--- NEW CONTROLLER
  final ApiService _apiService = ApiService();
  
  // UI State (Veg/Non-Veg is here, but NOT sent to API as requested)
  bool _isVeg = true; 
  bool _isLoading = false;

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 1. Get User ID
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        final userId = prefs.getInt('userId');

        if (token == null || userId == null) {
           throw Exception("User not logged in");
        }

        // 2. Prepare JSON (STRICTLY the 4 fields you asked for)
        final donationData = {
          "foodDescription": _foodNameController.text.trim(),
          
          // Parse Quantity as Double (e.g. "3.5")
          "quantityKg": double.tryParse(_quantityController.text.trim()) ?? 1.0,
          
          // Parse Hours as Integer (e.g. "4")
          "hoursValid": int.parse(_hoursController.text.trim()), 
          
          "restaurantId": userId
        };

        // 3. Send to API
        await _apiService.addDonation(token, donationData);
        
        if (!mounted) return;

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception:", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post Food',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.03),
              Colors.white,
              AppColors.secondary.withOpacity(0.02),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // --- Image Upload (Visual) ---
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.secondary.withOpacity(0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,  
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Upload Food Photo',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to add image',
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              
              // --- Field 1: Description ---
              CustomTextField(
                label: 'Food Description',
                hint: 'e.g., 10 Packets of Rice And Curry',
                controller: _foodNameController,
                prefixIcon: Icons.fastfood_rounded,
                validator: (val) => val!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 20),
              
              // --- Field 2: Quantity ---
              CustomTextField(
                label: 'Quantity (Kg)',
                hint: 'e.g., 3.5',
                controller: _quantityController,
                prefixIcon: Icons.scale_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => val!.isEmpty ? 'Enter quantity' : null,
              ),
              const SizedBox(height: 20),

              // --- Field 3: Valid Hours (Integer Input) ---
              CustomTextField(
                label: 'Valid For (Hours)',
                hint: 'e.g., 4',
                controller: _hoursController,
                prefixIcon: Icons.timer_rounded,
                // Only allow integer numbers
                keyboardType: TextInputType.number, 
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter hours';
                  if (int.tryParse(val) == null) return 'Must be a whole number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- UI ONLY: Veg / Non-Veg (Not sent to API) ---
              Row(
                children: [
                  Expanded(
                    child: _CategoryChip(
                      label: 'Vegetarian',
                      icon: Icons.eco_rounded,
                      isSelected: _isVeg,
                      onTap: () => setState(() => _isVeg = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CategoryChip(
                      label: 'Non-Veg',
                      icon: Icons.restaurant_rounded,
                      isSelected: !_isVeg,
                      onTap: () => setState(() => _isVeg = false),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // --- Submit Button ---
              CustomButton(
                text: 'Post Donation',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

// Helper Widget
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.primary.withOpacity(0.08),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}