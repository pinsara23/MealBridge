import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/urgency_badge.dart';

class RecipientHomeScreen extends StatefulWidget {
  const RecipientHomeScreen({Key? key}) : super(key: key);

  @override
  State<RecipientHomeScreen> createState() => _RecipientHomeScreenState();
}

class _RecipientHomeScreenState extends State<RecipientHomeScreen> {
  bool _isMapView = false;
  final String _selectedFilter = 'All';

  GoogleMapController? _mapController;
  int? _selectedMarkerIndex;

  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _donations = [];
  bool _isLoading = true;
  String? _errorMsg;
  LatLng _currentCenter = const LatLng(6.9271, 79.8612); // default Colombo

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Not logged in');

      final feed = await _apiService.getAllDonationsFeed(token);
      final List<Map<String, dynamic>> enriched = [];

      for (final item in feed) {
        final int restaurantId = item['restaurantId'] ?? 0;
        double? lat;
        double? lng;
        String? phone;
        String? address;

        // Fetch restaurant details for lat/lng
        if (restaurantId > 0) {
          try {
            final details = await _apiService.getRestaurantDetails(token, restaurantId);
            lat = (details['latitude'] as num?)?.toDouble();
            lng = (details['longitude'] as num?)?.toDouble();
            phone = details['phoneNumber'] as String?;
            address = details['address'] as String?;
          } catch (_) {}
        }

        // Derive urgency label from hoursValid
        final int hours = item['hoursValid'] ?? 6;
        String urgency;
        if (hours <= 1) {
          urgency = 'Urgent (Within 1 hour)';
        } else if (hours <= 3) {
          urgency = 'Moderate (Within $hours hours)';
        } else {
          urgency = 'Low (Within $hours hours)';
        }

        // Format pickup time
        String pickup = '';
        if (item['mustPickupBy'] != null) {
          try {
            final dt = DateTime.parse(item['mustPickupBy']);
            pickup = DateFormat('MMM dd, hh:mm a').format(dt);
          } catch (_) {
            pickup = item['mustPickupBy'].toString();
          }
        }

        enriched.add({
          'id': item['id']?.toString() ?? '0',
          'name': item['foodDescription'] ?? 'Food Donation',
          'quantity': '${item['quantityKg'] ?? 0} kg',
          'pickup': pickup,
          'urgency': urgency,
          'donor': item['restaurantName'] ?? 'Restaurant',
          'restaurantId': restaurantId,
          'latitude': lat,
          'longitude': lng,
          'donorPhone': phone ?? '',
          'location': address ?? '',
          'status': item['status'] ?? 'AVAILABLE',
          'description': item['foodDescription'] ?? '',
          'hoursValid': hours,
        });
      }

      // Calculate map center from first available donation with coordinates
      final withCoords = enriched.where((d) => d['latitude'] != null && d['longitude'] != null).toList();
      if (withCoords.isNotEmpty) {
        _currentCenter = LatLng(withCoords.first['latitude'], withCoords.first['longitude']);
      }

      // Try user GPS for center
      try {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium).timeout(const Duration(seconds: 5));
        _currentCenter = LatLng(pos.latitude, pos.longitude);
      } catch (_) {}

      if (!mounted) return;
      setState(() { _donations = enriched; _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMsg = e.toString(); });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      if (token != null) {
        await _apiService.logout(token);
      }
    } catch (_) {}

    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('role');
    await prefs.remove('displayName');

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Food', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(_isMapView ? Icons.list_rounded : Icons.map_rounded, size: 20),
              onPressed: () {
                setState(() {
                  _isMapView = !_isMapView;
                });
              },
              color: AppColors.primary,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, size: 20),
              onPressed: _showFilterBottomSheet,
              color: AppColors.primary,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20),
              onPressed: _logout,
              color: Colors.red,
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF9FBFF),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMsg != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text('Could not load donations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          Text(_errorMsg!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _loadDonations,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
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

  Set<Marker> _buildMarkers() {
    final withCoords = _donations.where((d) => d['latitude'] != null && d['longitude'] != null).toList();
    return withCoords.asMap().entries.map((entry) {
      final index = _donations.indexOf(entry.value);
      final donation = entry.value;
      final isUrgent = (donation['urgency'] as String).toLowerCase().contains('urgent');
      return Marker(
        markerId: MarkerId(donation['id']),
        position: LatLng(
          (donation['latitude'] as num).toDouble(),
          (donation['longitude'] as num).toDouble(),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isUrgent ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
        ),
        infoWindow: InfoWindow(
          title: donation['name'],
          snippet: donation['donor'],
        ),
        onTap: () {
          setState(() => _selectedMarkerIndex = index);
        },
      );
    }).toSet();
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // Real Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentCenter,
            zoom: 14.5,
          ),
          markers: _buildMarkers(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onTap: (_) {
            setState(() => _selectedMarkerIndex = null);
          },
          style: _mapStyle,
        ),

        // My Location button
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentCenter, 14.5),
                );
              },
            ),
          ),
        ),

        // Legend
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Urgent', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Available', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),

        // Bottom card when marker tapped
        if (_selectedMarkerIndex != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, -4)),
                ],
              ),
              child: _FoodDonationCard(
                donation: _donations[_selectedMarkerIndex!],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.foodDetails,
                    arguments: _donations[_selectedMarkerIndex!],
                  );
                },
              ),
            ),
          ),
        
        // Bottom Sheet with all donation cards (when no marker selected)
        if (_selectedMarkerIndex == null)
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4)),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.restaurant_menu_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            '${_donations.length} nearby donations',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
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
                              Navigator.pushNamed(context, AppRoutes.foodDetails, arguments: donation);
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

  // Subtle map style
  static const String _mapStyle = '[]';

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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.12),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
          ] : null,
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
                fontSize: 13,
                fontWeight: FontWeight.w700,
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
    final isUrgent = (donation['urgency'] as String? ?? '').toLowerCase().contains('urgent');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isUrgent ? AppColors.urgent.withOpacity(0.08) : Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isUrgent ? AppColors.urgent.withOpacity(0.3) : Colors.grey.withOpacity(0.08),
          width: isUrgent ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      donation['name'] ?? 'Food Donation',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Donor
              Text(
                donation['donor'] ?? '',
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
                    donation['quantity'] ?? '',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  if (donation['latitude'] != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    const Text(
                      'Location available',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Pickup Time
              if ((donation['pickup'] as String? ?? '').isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      donation['pickup'] ?? '',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              
              const SizedBox(height: 12),
              
              // Urgency Badge
              UrgencyBadge(urgencyLevel: donation['urgency'] ?? 'Low'),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
