import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; 
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_stats.dart';
import '../common/qr_scanner_screen.dart'; 

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
  String _restaurantName = "Partner";

  @override
  void initState() {
    super.initState();
    _loadData();
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
                height: 150,
                decoration: const BoxDecoration(
                  color: Colors.grey, 
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Stack(
                  children: [
                    const Center(child: Icon(Icons.map_rounded, size: 60, color: Colors.white54)),
                    Positioned(bottom: 10, right: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: Colors.black54, child: Text("Lat: ${details['latitude']}, Lng: ${details['longitude']}", style: const TextStyle(color: Colors.white, fontSize: 10)))),
                    Positioned(top: 10, right: 10, child: CircleAvatar(backgroundColor: Colors.white, radius: 16, child: IconButton(icon: const Icon(Icons.close, size: 16, color: Colors.black), onPressed: () => Navigator.pop(ctx)))),
                    
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
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.9),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _handleScan,
          label: const Text(
            "Scan QR",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          icon: const Icon(Icons.qr_code_scanner, size: 24),
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary.withOpacity(0.05), Colors.white, AppColors.secondary.withOpacity(0.03)],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(),
                      
                      const SizedBox(height: 32),
                      const Text('Your Impact 🌟', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      Row(children: [Expanded(child: _StatCard(title: 'Total Donations', value: stats.totalDonations.toString(), icon: Icons.volunteer_activism_rounded, color: AppColors.primary)), const SizedBox(width: 12), Expanded(child: _StatCard(title: 'People Fed', value: stats.peopleFed.toString(), icon: Icons.people_rounded, color: AppColors.secondary))]),
                      const SizedBox(height: 12),
                      Row(children: [Expanded(child: _StatCard(title: 'Active', value: stats.activeDonations.toString(), icon: Icons.schedule_rounded, color: AppColors.info)), const SizedBox(width: 12), Expanded(child: FutureBuilder<int>(future: _monthlyStatsFuture, builder: (context, monthSnapshot) { return _StatCard(title: 'This Month', value: monthSnapshot.hasData ? monthSnapshot.data.toString() : "...", icon: Icons.calendar_today_rounded, color: AppColors.volunteer); }))]),
                      
                      const SizedBox(height: 32),
                      const Text('Monthly Trends 📊', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      _buildGraphSection(),

                      const SizedBox(height: 20),
                      _buildPredictionCard(),

                      const SizedBox(height: 32),
                      const Text('Quick Actions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      _ActionCard(title: 'My Donations', subtitle: 'View all your active and past donations', icon: Icons.list_alt_rounded, color: AppColors.primary, onTap: () => Navigator.pushNamed(context, AppRoutes.myDonations)),
                      const SizedBox(height: 12),
                      _ActionCard(title: 'Donation History', subtitle: 'Track your impact over time', icon: Icons.history_rounded, color: AppColors.secondary, onTap: () => Navigator.pushNamed(context, AppRoutes.donorHistory)),

                      const SizedBox(height: 32),
                      const Text('Pending Pickups', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      const Text('Volunteers on the way. Use the Scan button when they arrive.', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),

                      _buildPendingList(),
                      
                      const SizedBox(height: 80),
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2575FC).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AI Insight 🤖",
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Predicted waste for tomorrow",
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${predictedValue.toStringAsFixed(2)} kg",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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
          padding: const EdgeInsets.all(20),
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: sortedData.map((item) {
              final double height = (item['totalWeight'] / maxWeight) * 160;
              final String monthShort = item['month'].substring(0, 3);
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: "${item['totalWeight']} kg",
                    child: Container(
                      width: 20,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: [AppColors.primary.withOpacity(0.6), AppColors.primary],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        )
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    monthShort,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
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
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.delivery_dining, color: Colors.white)),
                title: Text(item['foodDescription'] ?? "Food Package", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Volunteer Assigned"),
                trailing: const Icon(Icons.hourglass_bottom, color: Colors.orange),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
      return TweenAnimationBuilder<double>(tween: Tween(begin: 0.0, end: 1.0), duration: const Duration(milliseconds: 600), builder: (context, value, child) { return Transform.scale(scale: 0.9 + (0.1 * value), child: Opacity(opacity: value, child: Container(width: double.infinity, padding: const EdgeInsets.all(28), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.secondary]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10), spreadRadius: 2)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text('Welcome Back,\n$_restaurantName!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))), const Text('👋', style: TextStyle(fontSize: 28))]), const SizedBox(height: 12), const Text('Ready to make a difference today?', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w400)), const SizedBox(height: 24), ElevatedButton(onPressed: () async { await Navigator.pushNamed(context, AppRoutes.postFood); _loadData(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_rounded, size: 24), SizedBox(width: 12), Text('Post Food', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]))])))); });
  }
}

class _ProfileRow extends StatelessWidget { final IconData icon; final String text; const _ProfileRow({required this.icon, required this.text}); @override Widget build(BuildContext context) { return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Icon(icon, size: 20, color: AppColors.primary), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(fontSize: 16)))])); }}
class _StatCard extends StatelessWidget { final String title; final String value; final IconData icon; final Color color; const _StatCard({required this.title, required this.value, required this.icon, required this.color}); @override Widget build(BuildContext context) { return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withOpacity(0.15), color.withOpacity(0.05)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]), child: Icon(icon, color: Colors.white, size: 28)), const SizedBox(height: 16), Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color, shadows: [Shadow(color: color.withOpacity(0.3), blurRadius: 8)])), const SizedBox(height: 6), Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600))])); }}
class _ActionCard extends StatefulWidget { final String title; final String subtitle; final IconData icon; final Color color; final VoidCallback onTap; const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap}); @override State<_ActionCard> createState() => _ActionCardState(); }
class _ActionCardState extends State<_ActionCard> { bool _isPressed = false; @override Widget build(BuildContext context) { return GestureDetector(onTapDown: (_) => setState(() => _isPressed = true), onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); }, onTapCancel: () => setState(() => _isPressed = false), child: AnimatedContainer(duration: const Duration(milliseconds: 150), transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0), padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: _isPressed ? LinearGradient(colors: [widget.color.withOpacity(0.1), widget.color.withOpacity(0.05)]) : null, color: _isPressed ? null : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _isPressed ? widget.color : AppColors.border, width: _isPressed ? 2 : 1.5), boxShadow: [BoxShadow(color: _isPressed ? widget.color.withOpacity(0.2) : Colors.black.withOpacity(0.08), blurRadius: _isPressed ? 16 : 10, offset: Offset(0, _isPressed ? 6 : 4))]), child: Row(children: [Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.color, widget.color.withOpacity(0.8)]), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]), child: Icon(widget.icon, color: Colors.white, size: 26)), const SizedBox(width: 18), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)), const SizedBox(height: 6), Text(widget.subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))])), Icon(Icons.arrow_forward_ios_rounded, color: widget.color, size: 20)]))); }}