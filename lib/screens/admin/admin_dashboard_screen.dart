import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/colors.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  
  // Stats Variables
  Map<String, dynamic> _stats = {
    'foodRescued': '0',
    'activeUsers': '0',
    'activeDonations': '0',
    'completedDonations': '0',
    'totalDonations': '0',
    'totalRestaurants': '0',
    'totalVolunteers': '0',
  };
  
  Map<String, dynamic>? _adminProfile;
  bool _isLoading = true;
  bool _isSuperAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final adminId = prefs.getInt('userId');

    if (token != null && adminId != null) {
      try {
        // 1. Fetch Stats
        final statsData = await _apiService.getAdminStats(token);
        
        // --- FIX: Round Food Rescued to 2 Decimal Points ---
        if (statsData['foodRescued'] != null) {
          double val = double.tryParse(statsData['foodRescued'].toString()) ?? 0.0;
          statsData['foodRescued'] = val.toStringAsFixed(2);
        }

        // 2. Fetch Admin Profile
        final profile = await _apiService.getAdminDetails(token, adminId);
        
        // 3. Check Role (Superadmin check)
        String role = (profile['role'] ?? '').toString().toUpperCase();
        bool isSuper = role == 'SUPERADMIN' || role == 'SUPER_ADMIN';

        if (mounted) {
          setState(() {
            _stats = statsData;
            _adminProfile = profile;
            _isSuperAdmin = isSuper;
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error loading admin data: $e");
        if(mounted) setState(() => _isLoading = false);
      }
    }
  }

  // --- ACTIONS ---

  // 1. Profile Dialog (Updated to show userName & role)
  void _showProfileDialog() {
    if (_adminProfile == null) return;
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Admin Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileDetailRow(label: "Username", value: _adminProfile!['userName']),
            _ProfileDetailRow(label: "Role", value: _adminProfile!['role']),
            _ProfileDetailRow(label: "ID", value: _adminProfile!['id'].toString()),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Enter New Password"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');
              if (token != null && passwordCtrl.text.isNotEmpty) {
                await _apiService.updateAdminPassword(token, _adminProfile!['id'], passwordCtrl.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Updated!")));
              }
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  // 2. Add Admin Dialog (Superadmin only)
  void _showAddAdminDialog() {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Register New Admin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email / Username")),
            TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');
              if (token != null) {
                try {
                  await _apiService.registerNewAdmin(token, emailCtrl.text, passCtrl.text);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Admin Added Successfully!"), backgroundColor: Colors.green));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to add admin"), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text("Register"),
          )
        ],
      ),
    );
  }

  // 3. Volunteer Details Dialog (Shows Organization, President, Email, Phone)
  void _showVolunteerDetails(Map<String, dynamic> volunteer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(volunteer['organizationName'] ?? "Volunteer Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileDetailRow(label: "Organization", value: volunteer['organizationName']),
            _ProfileDetailRow(label: "President", value: volunteer['presidentFullName']),
            _ProfileDetailRow(label: "Email", value: volunteer['email']),
            _ProfileDetailRow(label: "Phone", value: volunteer['phoneNumber']),
            // Password and Message are explicitly excluded here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  // 4. Generic List Viewer
  void _showListSheet(String title, Function fetcher, Widget Function(Map<String, dynamic>) itemBuilder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => FutureBuilder(
          future: _fetchList(fetcher),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || (snapshot.data as List).isEmpty) return Center(child: Text("No $title found."));
            
            final list = snapshot.data as List;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("$title (${list.length})", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: list.length,
                    itemBuilder: (ctx, idx) => itemBuilder(list[idx]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<List<dynamic>> _fetchList(Function fetcher) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) return await fetcher(token);
    return [];
  }

  // 5. Map & Call Logic
  Future<void> _launchMap(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng"); // General map intent
    // Note: To open specific lat/lng, use: Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng")
    // I'll use the specific query for better accuracy:
    final Uri specificMapUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    
    if (await canLaunchUrl(specificMapUrl)) {
      await launchUrl(specificMapUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open maps")));
    }
  }

  Future<void> _approveVolunteer(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        await _apiService.approveVolunteer(token, id);
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Volunteer Approved!"), backgroundColor: Colors.green));
        _loadAllData(); // Refresh stats
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Approval Failed"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAllData,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_rounded, size: 28),
            onPressed: _showProfileDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.admin, AppColors.admin.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('System Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Total Donations: ${_stats['totalDonations']}', style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // --- KEY METRICS ---
              Row(
                children: [
                  // Food Rescued (Rounded 2 Decimals)
                  Expanded(child: _MetricCard(title: 'Food Rescued (kg)', value: '${_stats['foodRescued']}', icon: Icons.scale, color: Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(title: 'Active Users', value: '${_stats['activeUsers']}', icon: Icons.people, color: Colors.blue)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _MetricCard(title: 'Active Donations', value: '${_stats['activeDonations']}', icon: Icons.volunteer_activism, color: Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(title: 'Completed', value: '${_stats['completedDonations']}', icon: Icons.check_circle, color: Colors.purple)),
                ],
              ),

              const SizedBox(height: 24),
              const Text('Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),

              // 1. Manage Restaurants
              _ActionButton(
                icon: Icons.restaurant, 
                label: "Restaurants (${_stats['totalRestaurants']})", 
                onTap: () => _showListSheet("Restaurants", _apiService.getAdminRestaurants, (item) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(item['businessName'] ?? 'No Name'),
                      subtitle: Text("${item['email']}\n${item['phoneNumber'] ?? ''}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.map, color: Colors.blue),
                        onPressed: () => _launchMap(item['latitude'], item['longitude']),
                      ),
                      onTap: () {
                        // Restaurant Details Dialog
                        showDialog(context: context, builder: (ctx) => AlertDialog(
                          title: Text(item['businessName']),
                          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _ProfileDetailRow(label: "Email", value: item['email']),
                            _ProfileDetailRow(label: "Phone", value: item['phoneNumber']),
                            _ProfileDetailRow(label: "Hours", value: "${item['openTime']} - ${item['closeTime']}"),
                          ]),
                          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
                        ));
                      },
                    ),
                  );
                })
              ),
              const SizedBox(height: 12),

              // 2. Manage Volunteers (Updated for specific details)
              _ActionButton(
                icon: Icons.people_outline, 
                label: "Volunteers (${_stats['totalVolunteers']})", 
                onTap: () => _showListSheet("Volunteers", _apiService.getAdminVolunteers, (item) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)),
                      title: Text(item['organizationName'] ?? item['presidentFullName'] ?? 'Volunteer'),
                      subtitle: Text(item['email'] ?? ''),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () => _showVolunteerDetails(item), // Opens detail dialog
                    ),
                  );
                })
              ),
              const SizedBox(height: 12),

              // 3. Pending Approvals
              _ActionButton(
                icon: Icons.verified_user_outlined, 
                label: "Pending Approvals", 
                onTap: () => _showListSheet("Unapproved Volunteers", _apiService.getUnapprovedVolunteers, (item) {
                  return Card(
                    color: Colors.orange.shade50,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(item['organizationName'] ?? item['email']),
                      subtitle: Text(item['phoneNumber'] ?? ''),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => _approveVolunteer(item['id']),
                        child: const Text("Approve"),
                      ),
                      onTap: () => _showVolunteerDetails(item), // View details before approving
                    ),
                  );
                })
              ),

              // --- SUPERADMIN SECTION ---
              if (_isSuperAdmin) ...[
                const SizedBox(height: 24),
                const Text('Super Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.admin_panel_settings, 
                        label: "Add Admin", 
                        onTap: _showAddAdminDialog
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.list_alt, 
                        label: "List Admins", 
                        onTap: () => _showListSheet("Admins", _apiService.getAllAdmins, (item) {
                          return ListTile(
                            leading: const Icon(Icons.security),
                            title: Text(item['userName'] ?? 'Admin'),
                            subtitle: Text("ID: ${item['id']} | Role: ${item['role']}"),
                          );
                        })
                      ),
                    ),
                  ],
                )
              ]
            ],
          ),
        ),
    );
  }
}

// --- REUSABLE WIDGETS ---

class _ProfileDetailRow extends StatelessWidget {
  final String label;
  final String? value;
  const _ProfileDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.admin, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}