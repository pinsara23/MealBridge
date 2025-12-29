import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/food_type_chip.dart';
import '../../widgets/urgency_badge.dart';

class RecipientHomeScreen extends StatefulWidget {
  const RecipientHomeScreen({Key? key}) : super(key: key);

  @override
  State<RecipientHomeScreen> createState() => _RecipientHomeScreenState();
}

class _RecipientHomeScreenState extends State<RecipientHomeScreen> {
  bool _isMapView = false;
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _donations = [
    {
      'id': '1',
      'name': 'Rice and Curry',
      'quantity': 'Serves 10',
      'distance': '0.5 km',
      'pickup': '5:00 PM - 7:00 PM',
      'isVeg': true,
      'urgency': 'Urgent (Within 1 hour)',
      'donor': 'Green Valley Restaurant',
    },
    {
      'id': '2',
      'name': 'Fresh Vegetables',
      'quantity': '5 kg',
      'distance': '1.2 km',
      'pickup': '6:00 PM - 8:00 PM',
      'isVeg': true,
      'urgency': 'Moderate (Within 3 hours)',
      'donor': 'Farm Fresh Market',
    },
    {
      'id': '3',
      'name': 'Chicken Biryani',
      'quantity': 'Serves 15',
      'distance': '2.3 km',
      'pickup': '7:00 PM - 9:00 PM',
      'isVeg': false,
      'urgency': 'Low (Within 6 hours)',
      'donor': 'Spice Garden',
    },
    {
      'id': '4',
      'name': 'Bread and Pastries',
      'quantity': '20 pieces',
      'distance': '0.8 km',
      'pickup': '5:30 PM - 6:30 PM',
      'isVeg': true,
      'urgency': 'Urgent (Within 1 hour)',
      'donor': 'City Bakery',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Food'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list_rounded : Icons.map_rounded),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for food...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location_rounded),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          
          // View Toggle Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _ViewToggleChip(
                    label: 'List View',
                    icon: Icons.list_rounded,
                    isSelected: !_isMapView,
                    onTap: () => setState(() => _isMapView = false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ViewToggleChip(
                    label: 'Map View',
                    icon: Icons.map_rounded,
                    isSelected: _isMapView,
                    onTap: () => setState(() => _isMapView = true),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Content
          Expanded(
            child: _isMapView ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_rounded),
            label: 'My Claims',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.myClaimedFood);
          }
        },
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _donations.length,
      itemBuilder: (context, index) {
        final donation = _donations[index];
        return _FoodDonationCard(
          donation: donation,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.foodDetails,
              arguments: donation,
            );
          },
        );
      },
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // Map placeholder
        Container(
          color: AppColors.surfaceLight,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_rounded,
                  size: 80,
                  color: AppColors.textHint,
                ),
                SizedBox(height: 16),
                Text(
                  'Map View',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Google Maps integration here',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Bottom Sheet with donation cards
        DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.1,
          maxChildSize: 0.7,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // List
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _donations.length,
                      itemBuilder: (context, index) {
                        final donation = _donations[index];
                        return _FoodDonationCard(
                          donation: donation,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.foodDetails,
                              arguments: donation,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              
              const Text('Food Type', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(label: const Text('All'), onSelected: (val) {}),
                  FilterChip(label: const Text('Veg'), onSelected: (val) {}),
                  FilterChip(label: const Text('Non-Veg'), onSelected: (val) {}),
                ],
              ),
              
              const SizedBox(height: 16),
              
              const Text('Distance', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(label: const Text('< 1 km'), onSelected: (val) {}),
                  FilterChip(label: const Text('< 5 km'), onSelected: (val) {}),
                  FilterChip(label: const Text('< 10 km'), onSelected: (val) {}),
                ],
              ),
              
              const SizedBox(height: 16),
              
              const Text('Urgency', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(label: const Text('Urgent'), onSelected: (val) {}),
                  FilterChip(label: const Text('Moderate'), onSelected: (val) {}),
                  FilterChip(label: const Text('Low'), onSelected: (val) {}),
                ],
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _ViewToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleChip({
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
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
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodDonationCard extends StatelessWidget {
  final Map<String, dynamic> donation;
  final VoidCallback onTap;

  const _FoodDonationCard({
    required this.donation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = (donation['urgency'] as String).toLowerCase().contains('urgent');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isUrgent
            ? const BorderSide(color: AppColors.urgent, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      donation['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  FoodTypeChip(isVeg: donation['isVeg']),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Donor
              Text(
                donation['donor'],
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Info Row
              Row(
                children: [
                  const Icon(Icons.restaurant_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    donation['quantity'],
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    donation['distance'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Pickup Time
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    donation['pickup'],
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Urgency Badge
              UrgencyBadge(urgencyLevel: donation['urgency']),
            ],
          ),
        ),
      ),
    );
  }
}
