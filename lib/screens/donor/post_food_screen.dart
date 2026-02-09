import 'dart:ui';
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
  final _foodDescriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _validHoursController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  // UI State (Veg/Non-Veg is here, but NOT sent to API as requested)
  bool _isVeg = true; 
  bool _isLoading = false;

  @override
  void dispose() {
    _foodDescriptionController.dispose();
    _quantityController.dispose();
    _validHoursController.dispose();
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
          "foodDescription": _foodDescriptionController.text.trim(),
          
          // Parse Quantity as Double (e.g. "3.5")
          "quantityKg": double.tryParse(_quantityController.text.trim()) ?? 1.0,
          
          // Parse Hours as Integer (e.g. "4")
          "hoursValid": int.parse(_validHoursController.text.trim()), 
          
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

  Widget _buildStepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap to add image',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildModernSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Vegetarian',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Switch.adaptive(
          value: _isVeg,
          onChanged: (value) {
            setState(() {
              _isVeg = value;
            });
          },
          activeColor: AppColors.primary,
          inactiveThumbColor: AppColors.textSecondary.withOpacity(0.5),
          inactiveTrackColor: AppColors.border,
        ),
      ],
    );
  }

  Widget _buildPostButton() {
    return CustomButton(
      text: 'Post Donation',
      onPressed: _handleSubmit,
      isLoading: _isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Post Donation',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        color: const Color(0xFFF9FBFF),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepTitle('Upload Image', 'Optional but recommended'),
                const SizedBox(height: 16),
                _buildImagePlaceholder(),
                const SizedBox(height: 32),
                _buildStepTitle('Donation Details', 'Tell us what you\'re sharing'),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Food Description',
                  hint: 'e.g., 10 Packets of Rice And Curry',
                  controller: _foodDescriptionController,
                  prefixIcon: Icons.fastfood_rounded,
                  validator: (val) => val!.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Quantity (Kg)',
                        hint: 'e.g., 3.5',
                        controller: _quantityController,
                        prefixIcon: Icons.scale_rounded,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (val) => val!.isEmpty ? 'Enter quantity' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Valid For (Hours)',
                        hint: 'e.g., 4',
                        controller: _validHoursController,
                        prefixIcon: Icons.timer_rounded,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter hours';
                          if (int.tryParse(val) == null) return 'Must be a whole number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildModernSwitch(),
                const SizedBox(height: 48),
                CustomButton(
                  text: 'Post Donation',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 40),
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