import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class PostFoodScreen extends StatefulWidget {
  const PostFoodScreen({Key? key}) : super(key: key);

  @override
  State<PostFoodScreen> createState() => _PostFoodScreenState();
}

class _PostFoodScreenState extends State<PostFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedFoodType = AppConstants.foodTypes[0];
  String _selectedUrgency = AppConstants.urgentWithin1Hour;
  bool _isVeg = true;
  bool _isCooked = true;
  
  // Food Safety Checklist
  bool _properlyStored = false;
  bool _notExpired = false;
  bool _properPackaging = false;
  bool _goodQuality = false;
  
  TimeOfDay? _pickupTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _pickupTime = picked;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (!_properlyStored || !_notExpired || !_properPackaging || !_goodQuality) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete the food safety checklist'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      setState(() => _isLoading = true);
      
      // Simulate post submission
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food posted successfully!'),
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
        title: const Text('Post Food'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Section
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 2, strokeAlign: BorderSide.strokeAlignInside),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add Food Photos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Choose from Gallery'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Food Name
              CustomTextField(
                label: 'Food Name',
                hint: 'e.g., Rice and Curry',
                controller: _foodNameController,
                prefixIcon: Icons.fastfood_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter food name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Food Type Dropdown
              const Text(
                'Food Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedFoodType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: AppConstants.foodTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFoodType = value!;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Quantity
              CustomTextField(
                label: 'Quantity',
                hint: 'e.g., Serves 10 people',
                controller: _quantityController,
                prefixIcon: Icons.people_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Veg/Non-Veg Toggle
              const Text(
                'Food Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
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
              
              const SizedBox(height: 20),
              
              // Pickup Time
              const Text(
                'Pickup Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectPickupTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _pickupTime != null
                            ? _pickupTime!.format(context)
                            : 'Select pickup time',
                        style: TextStyle(
                          fontSize: 16,
                          color: _pickupTime != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Urgency Level
              const Text(
                'Urgency Level',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedUrgency,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.warning_rounded),
                ),
                items: [
                  AppConstants.urgentWithin1Hour,
                  AppConstants.moderateWithin3Hours,
                  AppConstants.lowWithin6Hours,
                ].map((urgency) {
                  return DropdownMenuItem(
                    value: urgency,
                    child: Text(urgency),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUrgency = value!;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // Location
              CustomTextField(
                label: 'Pickup Location',
                hint: 'Enter pickup address',
                controller: _locationController,
                prefixIcon: Icons.location_on_rounded,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location_rounded),
                  onPressed: () {
                    // Get current location
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pickup location';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Food Safety Checklist
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.security_rounded, color: AppColors.info),
                        SizedBox(width: 8),
                        Text(
                          'Food Safety Checklist',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ChecklistItem(
                      text: 'Food has been properly stored',
                      value: _properlyStored,
                      onChanged: (value) => setState(() => _properlyStored = value),
                    ),
                    _ChecklistItem(
                      text: 'Food is not expired',
                      value: _notExpired,
                      onChanged: (value) => setState(() => _notExpired = value),
                    ),
                    _ChecklistItem(
                      text: 'Food is in proper packaging',
                      value: _properPackaging,
                      onChanged: (value) => setState(() => _properPackaging = value),
                    ),
                    _ChecklistItem(
                      text: 'Food is of good quality',
                      value: _goodQuality,
                      onChanged: (value) => setState(() => _goodQuality = value),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Additional Notes
              CustomTextField(
                label: 'Additional Notes (Optional)',
                hint: 'Any special instructions...',
                controller: _notesController,
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              CustomButton(
                text: 'Post Food',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
                icon: Icons.check_rounded,
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;
  final bool value;
  final Function(bool) onChanged;

  const _ChecklistItem({
    required this.text,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (val) => onChanged(val ?? false),
      title: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
