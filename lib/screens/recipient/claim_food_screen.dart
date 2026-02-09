import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ClaimFoodScreen extends StatefulWidget {
  const ClaimFoodScreen({Key? key}) : super(key: key);

  @override
  State<ClaimFoodScreen> createState() => _ClaimFoodScreenState();
}

class _ClaimFoodScreenState extends State<ClaimFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _peopleController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _needDelivery = false;

  @override
  void dispose() {
    _peopleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleClaim() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate claim process
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food claimed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Food', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5)),
      ),
      body: Container(
        color: const Color(0xFFF9FBFF),
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primary.withOpacity(0.12)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_rounded, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please provide accurate information to help us serve you better.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Number of People
              CustomTextField(
                label: 'Number of People',
                hint: 'How many people will this feed?',
                controller: _peopleController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.people_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of people';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Delivery Option
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                  border: Border.all(color: Colors.grey.withOpacity(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Option',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RadioListTile<bool>(
                      value: false,
                      groupValue: _needDelivery,
                      onChanged: (value) {
                        setState(() => _needDelivery = value!);
                      },
                      title: const Text('I will pick it up'),
                      subtitle: const Text('You will collect the food yourself'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    RadioListTile<bool>(
                      value: true,
                      groupValue: _needDelivery,
                      onChanged: (value) {
                        setState(() => _needDelivery = value!);
                      },
                      title: const Text('Request volunteer delivery'),
                      subtitle: const Text('A volunteer will deliver to you'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Additional Notes
              CustomTextField(
                label: 'Additional Notes (Optional)',
                hint: 'Any special requirements...',
                controller: _notesController,
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              // Important Notice
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.warning.withOpacity(0.15)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_rounded, color: AppColors.warning),
                        SizedBox(width: 8),
                        Text(
                          'Important',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Please arrive within the pickup window\n'
                      '• Bring appropriate containers\n'
                      '• Call if you\'re running late\n'
                      '• Cancel if you can\'t make it',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Claim Button
              CustomButton(
                text: 'Confirm Claim',
                onPressed: _handleClaim,
                isLoading: _isLoading,
                icon: Icons.check_circle_rounded,
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
