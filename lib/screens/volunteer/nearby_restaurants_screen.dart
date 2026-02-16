import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import '../../services/websocket_service.dart';
import '../../theme/colors.dart';

class NearbyRestaurantsScreen extends StatefulWidget {
  final bool embedded;

  const NearbyRestaurantsScreen({super.key, this.embedded = false});

  @override
  State<NearbyRestaurantsScreen> createState() =>
      _NearbyRestaurantsScreenState();
}

class _NearbyRestaurantsScreenState extends State<NearbyRestaurantsScreen> {
  final ApiService _apiService = ApiService();

  GoogleMapController? _mapController;
  bool _isLoading = true;
  String? _error;

  LatLng _volunteerLocation = const LatLng(6.9271, 79.8612);
  List<Map<String, dynamic>> _restaurants = [];
  int? _selectedRestaurantId;

  @override
  void initState() {
    super.initState();
    _loadNearbyRestaurants();
  }

  Future<void> _loadNearbyRestaurants() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('You are not logged in. Please login again.');
      }

      final position = await _resolveCurrentPosition();
      final nearby = await _apiService.getNearbyRestaurants(
        token,
        position.latitude,
        position.longitude,
      );

      final parsed = nearby
          .whereType<Map>()
          .map((raw) => Map<String, dynamic>.from(raw))
          .map((restaurant) {
            final id = _toInt(
              restaurant['id'] ?? restaurant['restaurantId'] ?? restaurant['rId'],
            );
            final lat = _toDouble(
              restaurant['latitude'] ?? restaurant['lat'] ?? restaurant['locationLat'],
            );
            final lng = _toDouble(
              restaurant['longitude'] ?? restaurant['lng'] ?? restaurant['locationLng'],
            );

            return {
              ...restaurant,
              'id': id,
              'latitude': lat,
              'longitude': lng,
              'name': _toNullableString(
                restaurant['businessName'] ??
                    restaurant['name'] ??
                    restaurant['restaurantName'] ??
                    restaurant['organizationName'],
              ),
              'contactNumber': _toNullableString(
                restaurant['phoneNumber'] ??
                    restaurant['contactNumber'] ??
                    restaurant['mobileNumber'] ??
                    restaurant['phone'],
              ),
              'address': _toNullableString(
                restaurant['address'] ?? restaurant['location'],
              ),
            };
          })
          .where(
            (restaurant) =>
                (restaurant['id'] as int) > 0 &&
                restaurant['latitude'] != null &&
                restaurant['longitude'] != null,
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _volunteerLocation = LatLng(position.latitude, position.longitude);
        _restaurants = parsed;
        _selectedRestaurantId = parsed.isNotEmpty ? parsed.first['id'] as int : null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<Position> _resolveCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is disabled. Please enable GPS.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied for volunteer location.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> _claimDonation(int donationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('userId');
      if (token == null || userId == null) {
        throw Exception('Missing login session. Please login again.');
      }

      await _apiService.claimDonation(token, donationId, userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation claimed! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      var error = msg.replaceAll('Exception: ', '');
      if (msg.contains('error1')) {
        error = 'Already picked up by someone else.';
      } else if (msg.contains('error2')) {
        error = 'You are not approved yet. Contact admin.';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }

  void _openRestaurantDonations(Map<String, dynamic> restaurant) {
    final restaurantId = restaurant['id'] as int;
    final restaurantName = restaurant['name']?.toString() ?? '';
    final contact = restaurant['contactNumber']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.store_rounded, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            restaurantName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (contact.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.call_rounded,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            contact,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: _RestaurantDonationsSheet(
                  restaurantId: restaurantId,
                  onClaimDonation: _claimDonation,
                  toInt: _toInt,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('volunteer'),
        position: _volunteerLocation,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };

    for (final restaurant in _restaurants) {
      final lat = restaurant['latitude'] as double;
      final lng = restaurant['longitude'] as double;
      final id = restaurant['id'] as int;

      markers.add(
        Marker(
          markerId: MarkerId('restaurant-$id'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: restaurant['name']?.toString() ?? '',
            snippet: restaurant['contactNumber']?.toString() ?? '',
          ),
          onTap: () {
            if (!mounted) return;
            setState(() => _selectedRestaurantId = id);
          },
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_off_rounded,
                    color: AppColors.textSecondary,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _loadNearbyRestaurants,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          )
        : Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _volunteerLocation,
                  zoom: 13.8,
                ),
                markers: _buildMarkers(),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: (controller) => _mapController = controller,
                onTap: (_) {
                  if (!mounted) return;
                  setState(() => _selectedRestaurantId = null);
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.my_location_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(_volunteerLocation, 13.8),
                      );
                    },
                  ),
                ),
              ),
              if (_selectedRestaurantId != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: _SelectedRestaurantCard(
                    restaurant: _restaurants.firstWhere(
                      (r) => r['id'] == _selectedRestaurantId,
                      orElse: () => <String, dynamic>{},
                    ),
                    onViewDonations: () {
                      final selected = _restaurants.firstWhere(
                        (r) => r['id'] == _selectedRestaurantId,
                        orElse: () => <String, dynamic>{},
                      );
                      if (selected.isNotEmpty) {
                        _openRestaurantDonations(selected);
                      }
                    },
                  ),
                ),
              if (_restaurants.isEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No nearby restaurants found for your current location.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          'Nearby Restaurants',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _loadNearbyRestaurants,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh nearby restaurants',
          ),
        ],
      ),
      body: body,
    );
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }
}

class _RestaurantDonationsSheet extends StatefulWidget {
  final int restaurantId;
  final Future<void> Function(int donationId) onClaimDonation;
  final int Function(dynamic value) toInt;

  const _RestaurantDonationsSheet({
    required this.restaurantId,
    required this.onClaimDonation,
    required this.toInt,
  });

  @override
  State<_RestaurantDonationsSheet> createState() =>
      _RestaurantDonationsSheetState();
}

class _RestaurantDonationsSheetState extends State<_RestaurantDonationsSheet> {
  final ApiService _apiService = ApiService();
  final WebSocketService _wsService = WebSocketService();

  List<Map<String, dynamic>> _donations = [];
  bool _isLoading = true;
  String? _error;
  bool _isWsConnected = false;

  @override
  void initState() {
    super.initState();
    _loadDonations();
    _connectWs();
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }

  Future<void> _loadDonations() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('You are not logged in.');

      final data = await _apiService.getRestaurantDonations(
        token,
        widget.restaurantId,
      );

      if (!mounted) return;
      setState(() {
        _donations = data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _connectWs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      _wsService.connect(token, (_) {
        if (!mounted) return;
        setState(() => _isWsConnected = true);
        _wsService.subscribeToRestaurant(widget.restaurantId, (_) async {
          await _loadDonations();
        });
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Failed to load restaurant donations.\n$_error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    if (_donations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No donations posted by this restaurant yet.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isWsConnected ? 'Listening for new donations…' : 'Connecting live updates…',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: _donations.length,
      itemBuilder: (context, index) {
        final donation = _donations[index];
        final donationId = widget.toInt(donation['id']);
        final status = donation['status']?.toString().toUpperCase() ?? 'UNKNOWN';
        final isAvailable = status == 'AVAILABLE';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.fastfood_rounded,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      donation['foodDescription']?.toString() ?? 'Food Donation',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.grey.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isAvailable ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Quantity: ${donation['quantityKg'] ?? 0} kg • Expires in ${donation['hoursValid'] ?? '-'}h',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isAvailable && donationId > 0) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await widget.onClaimDonation(donationId);
                      if (!mounted) return;
                      if (Navigator.of(this.context).canPop()) {
                        Navigator.of(this.context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text(
                      'Take Donation',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SelectedRestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onViewDonations;

  const _SelectedRestaurantCard({
    required this.restaurant,
    required this.onViewDonations,
  });

  @override
  Widget build(BuildContext context) {
    final name = restaurant['name']?.toString() ?? '';
    final contact = restaurant['contactNumber']?.toString() ?? '';
    final address = restaurant['address']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.store_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (contact.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        contact,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onViewDonations,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.fastfood_rounded),
              label: const Text(
                'View Restaurant Donations',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
