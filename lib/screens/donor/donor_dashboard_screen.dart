import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../services/websocket_service.dart';
import '../../models/dashboard_stats.dart';
import '../common/qr_scanner_screen.dart'; 
import 'donation_details_screen.dart';

class DonorDashboardScreen extends StatefulWidget {
  const DonorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends State<DonorDashboardScreen> {
  // 1. Setup for API Data
  Future<DashboardStats>? _statsFuture;
  Future<Map<String, dynamic>>? _restaurantDetailsFuture;
  Future<int>? _monthlyStatsFuture;
  Future<List<dynamic>>? _activeDonationsFuture;
  Future<List<dynamic>>? _graphDataFuture;
  Future<double>? _predictionFuture;
  
  final ApiService _apiService = ApiService();
  final WebSocketService _wsService = WebSocketService();
  String _restaurantName = "Partner";

  @override
  void initState() {
    super.initState();
    _loadData();
    _initWebSocket();
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }

  // 2. Load Data
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? restaurantId = prefs.getInt('userId');

    if (token != null && restaurantId != null) {
      setState(() {
        _statsFuture = _apiService.getDonorStats(token, restaurantId);
        _monthlyStatsFuture = _apiService.getMonthlyDonations(token, restaurantId);
        _restaurantDetailsFuture = _apiService.getRestaurantDetails(token, restaurantId);
        _activeDonationsFuture = _apiService.getDonationHistory(token, restaurantId);
        _graphDataFuture = _apiService.getGraphData(token, restaurantId);
        _predictionFuture = _fetchPrediction(token, restaurantId);
      });

      try {
        final details = await _apiService.getRestaurantDetails(token, restaurantId);
        if (mounted) {
          setState(() {
            _restaurantName = details['businessName'] ?? "Partner";
          });
        }
      } catch (e) {
        print("Could not load name: $e");
      }
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

  // --- WEBSOCKET LOGIC ---
  Future<void> _initWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final restaurantId = prefs.getInt('userId');

    if (token != null && restaurantId != null) {
      _wsService.connect(token, (frame) {
        print("✅ Dashboard: WebSocket Connected");

        _wsService.subscribeToRestaurant(restaurantId, (newMessage) {
          print("📩 Restaurant Update: $newMessage");

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Status changed: $newMessage"),
                backgroundColor: Colors.blue,
                behavior: SnackBarBehavior.floating,
              ),
            );

            _loadData();
          }
        });
      });
    }
  }

  // --- FETCH PREDICTION ---
  Future<double> _fetchPrediction(String token, int restaurantId) async {
    final url = Uri.parse('${ApiService().baseUrl}/analytic/predict/$restaurantId');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return double.parse(response.body);
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // --- UPDATE PROFILE API ---
  Future<void> _updateRestaurantProfile(int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('${ApiService().baseUrl}/restaurants/update/$id');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context); // Close edit dialog
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!"), backgroundColor: Colors.green));
        _loadData(); // Refresh UI
      } else {
        throw Exception("Failed to update");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  // --- CHANGE PASSWORD API (UPDATED) ---
  Future<void> _changePassword(int id, String oldPass, String newPass) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final url = Uri.parse('${ApiService().baseUrl}/restaurants/update/password/$id?opass=$oldPass&npass=$newPass');

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      // Check for 200 OK AND body == "true"
      if (response.statusCode == 200) {
        final body = response.body.trim().toLowerCase(); // Normalize string
        
        if (body == 'true') {
          if (!mounted) return;
          Navigator.pop(context); // Close password dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password changed successfully"), backgroundColor: Colors.green)
          );
        } else {
          // Backend returned 200 but false (Old password likely wrong)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed: Incorrect Old Password"), backgroundColor: Colors.red)
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}"), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network Error: $e"), backgroundColor: Colors.red)
      );
    }
  }

  // --- SCANNING LOGIC ---
  Future<void> _handleScan() async {
    final scannedCode = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const QRScannerScreen())
    );

    if (scannedCode == null) return; 

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final int? restaurantId = prefs.getInt('userId');

      if (token != null && restaurantId != null) {
        showDialog(context: context, barrierDismissible: false, builder: (ctx) => const Center(child: CircularProgressIndicator()));

        final bool isSuccess = await _apiService.verifyPickupByRestaurant(token, restaurantId, scannedCode);
        
        Navigator.pop(context); 

        if (isSuccess) {
          _showResultDialog(true, "Donation is successfully picked up! ✅");
          _loadData(); 
        } else {
          _showResultDialog(false, "Verification Failed. Token is invalid.");
        }
      }
    } catch (e) {
      Navigator.pop(context); 
      _showResultDialog(false, "Error: ${e.toString()}");
    }
  }

  void _showResultDialog(bool isSuccess, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error, color: isSuccess ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Text(isSuccess ? "Success" : "Error"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  // --- DIALOGS ---

  void _showChangePasswordDialog(int restaurantId) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Old Password")),
            const SizedBox(height: 10),
            TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: "New Password")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => _changePassword(restaurantId, oldPassCtrl.text, newPassCtrl.text),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(Map<String, dynamic> details) {
    final nameCtrl = TextEditingController(text: details['businessName']);
    final phoneCtrl = TextEditingController(text: details['phoneNumber']);
    final openCtrl = TextEditingController(text: details['openTime']);
    final closeCtrl = TextEditingController(text: details['closeTime']);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Business Name", prefixIcon: Icon(Icons.store))),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: openCtrl, decoration: const InputDecoration(labelText: "Open Time (HH:mm:ss)"))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: closeCtrl, decoration: const InputDecoration(labelText: "Close Time"))),
                ],
              ),
              const SizedBox(height: 20),
              
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx); 
                  _showChangePasswordDialog(details['id']);
                }, 
                icon: const Icon(Icons.lock_reset), 
                label: const Text("Change Password"),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final updatedData = {
                "businessName": nameCtrl.text,
                "phoneNumber": phoneCtrl.text,
                "openTime": openCtrl.text,
                "closeTime": closeCtrl.text,
                "email": details['email'], 
                "latitude": details['latitude'],
                "longitude": details['longitude']
              };
              _updateRestaurantProfile(details['id'], updatedData);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(Map<String, dynamic> details) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Real Google Map showing restaurant location
                    if (details['latitude'] != null && details['longitude'] != null)
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            (details['latitude'] as num).toDouble(),
                            (details['longitude'] as num).toDouble(),
                          ),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('restaurant'),
                            position: LatLng(
                              (details['latitude'] as num).toDouble(),
                              (details['longitude'] as num).toDouble(),
                            ),
                            infoWindow: InfoWindow(title: details['businessName'] ?? 'Restaurant'),
                          ),
                        },
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                      )
                    else
                      Container(
                        color: Colors.grey.shade300,
                        child: const Center(child: Icon(Icons.map_rounded, size: 60, color: Colors.white54)),
                      ),

                    // Close button
                    Positioned(top: 10, right: 10, child: CircleAvatar(backgroundColor: Colors.white, radius: 16, child: IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.black), onPressed: () => Navigator.pop(ctx)))),

                    // Edit button
                    Positioned(
                      top: 10,
                      left: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16,
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showEditProfileDialog(details);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(details['businessName'] ?? "Restaurant", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    _ProfileRow(icon: Icons.email, text: details['email'] ?? "N/A"),
                    _ProfileRow(icon: Icons.phone, text: details['phoneNumber'] ?? "N/A"),
                    _ProfileRow(icon: Icons.access_time, text: "${details['openTime']} - ${details['closeTime']}"),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Close"))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Donor Dashboard',
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: _restaurantDetailsFuture,
            builder: (context, snapshot) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.store_rounded, color: Colors.white, size: 22),
                  onPressed: () {
                    if (snapshot.hasData) _showProfileDialog(snapshot.data!);
                  },
                ),
              );
            },
          ),
        ],
      ),
      
      floatingActionButton: Container(
        height: 64,
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _handleScan,
          elevation: 0,
          backgroundColor: Colors.transparent,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          label: const Text(
            "Scan QR",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          icon: const Icon(Icons.qr_code_scanner_rounded, size: 24, color: Colors.white),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: FutureBuilder<DashboardStats>(
          future: _statsFuture,
          builder: (context, snapshot) {
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            final stats = snapshot.data ?? DashboardStats(totalDonations: 0, thisMonthDonations: 0, activeDonations: 0, peopleFed: 0);

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBFF),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(),
                      
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Your Impact', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                          Icon(Icons.auto_graph_rounded, color: AppColors.primary.withOpacity(0.5)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(children: [Expanded(child: _StatCard(title: 'Total Donations', value: stats.totalDonations.toString(), icon: Icons.volunteer_activism_rounded, color: AppColors.primary)), const SizedBox(width: 16), Expanded(child: _StatCard(title: 'People Fed', value: stats.peopleFed.toString(), icon: Icons.people_rounded, color: AppColors.secondary))]),
                      const SizedBox(height: 16),
                      Row(children: [Expanded(child: _StatCard(title: 'Active', value: stats.activeDonations.toString(), icon: Icons.timer_rounded, color: AppColors.info)), const SizedBox(width: 16), Expanded(child: FutureBuilder<int>(future: _monthlyStatsFuture, builder: (context, monthSnapshot) { return _StatCard(title: 'This Month', value: monthSnapshot.hasData ? monthSnapshot.data.toString() : "...", icon: Icons.calendar_month_rounded, color: AppColors.volunteer); }))]),
                      
                      const SizedBox(height: 40),
                      const Text('Monthly Trends', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                      const SizedBox(height: 20),
                      _buildGraphSection(),

                      const SizedBox(height: 24),
                      _buildPredictionCard(),

                      const SizedBox(height: 40),
                      const Text('Quick Actions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                      const SizedBox(height: 20),
                      _ActionCard(title: 'My Donations', subtitle: 'View and manage your active postings', icon: Icons.inventory_2_rounded, color: AppColors.primary, onTap: () => Navigator.pushNamed(context, AppRoutes.myDonations)),
                      const SizedBox(height: 16),
                      _ActionCard(title: 'Donation History', subtitle: 'Track your past contributions', icon: Icons.history_rounded, color: AppColors.secondary, onTap: () => Navigator.pushNamed(context, AppRoutes.donorHistory)),

                      const SizedBox(height: 40),
                      Row(
                        children: [
                          const Text('Pending Pickups', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Text('Live', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Volunteers are on their way to pick up food.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 20),

                      _buildPendingList(),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildPredictionCard() {
    return FutureBuilder<double>(
      future: _predictionFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == 0.0) return const SizedBox.shrink();

        final double predictedValue = snapshot.data!;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI INSIGHT",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Predicted waste for tomorrow",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: predictedValue.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const TextSpan(
                            text: " kg",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGraphSection() {
    return FutureBuilder<List<dynamic>>(
      future: _graphDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("No data available yet.");

        final sortedData = List.from(snapshot.data!);
        sortedData.sort((a, b) {
          final months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
          return months.indexOf(a['month']) - months.indexOf(b['month']);
        });

        double maxWeight = 0;
        for (var item in sortedData) {
          if (item['totalWeight'] > maxWeight) maxWeight = item['totalWeight'].toDouble();
        }
        if (maxWeight == 0) maxWeight = 100;

        return Container(
          padding: const EdgeInsets.all(24),
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: sortedData.map((item) {
              final double height = (item['totalWeight'] / maxWeight) * 140;
              final String monthShort = item['month'].substring(0, 3);
              
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: "${item['totalWeight']} kg",
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 14,
                        height: height.clamp(10, 140),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          gradient: LinearGradient(
                            colors: [AppColors.primary.withOpacity(0.4), AppColors.primary],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          boxShadow: [
                            if (height > 20)
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      monthShort,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPendingList() {
    return FutureBuilder<List<dynamic>>(
      future: _activeDonationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("No pending pickups.");

        final activeList = snapshot.data!.where((item) => item['status'] == 'CLAIMED').toList();
        if (activeList.isEmpty) return const Text("No pending pickups.");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeList.length,
          itemBuilder: (context, index) {
            final item = activeList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delivery_dining_rounded, color: Colors.orange, size: 24),
                ),
                title: Text(
                  item['foodDescription'] ?? "Food Package",
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                ),
                subtitle: const Text("Volunteer Assigned", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonationDetailsScreen(
                        donationId: item['id'] ?? 0,
                        initialStatus: item['status'] ?? 'AVAILABLE',
                        foodDescription: item['foodDescription'] ?? 'Food Package',
                        quantity: item['quantityKg']?.toString() ?? 'N/A',
                        pickupTime: item['mustPickupBy']?.toString() ?? 'Anytime',
                        restaurantName: _restaurantName,
                        volunteerName: item['volunteerName'] ?? 'Not Assigned',
                        volunteerPhone: item['volunteerPhone'] ?? '',
                      ),
                    ),
                  ).then((_) => _loadData());
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                    spreadRadius: -5,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_restaurantName',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('👋', style: TextStyle(fontSize: 24)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ready to share your extra food and support the community?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, AppRoutes.postFood);
                      _loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 22),
                        SizedBox(width: 10),
                        Text('Post New Food', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileRow extends StatelessWidget { final IconData icon; final String text; const _ProfileRow({required this.icon, required this.text}); @override Widget build(BuildContext context) { return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(icon, size: 20, color: AppColors.primary), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(fontSize: 16)))])); }}
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: color.withOpacity(0.08), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.04 : 0.06),
              blurRadius: _isPressed ? 10 : 20,
              offset: Offset(0, _isPressed ? 4 : 8),
            )
          ],
          border: Border.all(
            color: _isPressed ? widget.color.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon, color: widget.color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}
