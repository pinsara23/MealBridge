import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'package:http/http.dart' as http;
import '../../theme/colors.dart';
import '../../services/api_service.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerDashboardScreen> createState() => _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  final ApiService _apiService = ApiService();
  
  // State Variables
  Map<String, dynamic>? _volunteerDetails;
  String _organizationName = "Volunteer"; 

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');

    if (token != null && userId != null) {
      try {
        final details = await _apiService.getVolunteerDetails(token, userId);
        if (mounted) {
          setState(() {
            _volunteerDetails = details;
            _organizationName = details['organizationName'] ?? "Volunteer Group";
          });
        }
      } catch (e) {
        print("Error loading profile: $e");
      }
    }
  }

  // --- PASSWORD CHANGE LOGIC ---
  Future<void> _changePassword(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');

    if (token == null || userId == null) return;

    try {
      final url = Uri.parse(
        '${_apiService.baseUrl}/volunteer/update/password/$userId?oldPassword=$oldPassword&newPassword=$newPassword'
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.trim() == 'true') {
          if (!mounted) return;
          Navigator.pop(context); // Close the password dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password has changed successfully"), 
              backgroundColor: Colors.green
            )
          );
        } else {
           if (!mounted) return;
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update password. Check old password."), backgroundColor: Colors.red)
          );
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
      );
    }
  }

  // --- CHANGE PASSWORD DIALOG ---
  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Change Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: oldPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Old Password", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isLoading ? null : () => Navigator.pop(ctx),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          if(oldPassCtrl.text.isEmpty || newPassCtrl.text.isEmpty) {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fields cannot be empty")));
                             return;
                          }
                          setStateDialog(() => isLoading = true);
                          await _changePassword(oldPassCtrl.text, newPassCtrl.text);
                          setStateDialog(() => isLoading = false);
                        },
                        child: isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) 
                          : const Text("Update"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- SHOW PROFILE DIALOG ---
  void _showProfileDialog() {
    // FIX 1: Capture data in a local variable for null safety
    final details = _volunteerDetails; 
    
    if (details == null) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Icon(Icons.volunteer_activism_rounded, size: 60, color: AppColors.primary),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.grey),
                    onPressed: () {
                      Navigator.pop(ctx); 
                      _showEditDialog(); 
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _organizationName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // FIX 1 (Continued): Use local 'details' variable
              _ProfileRow(
                icon: Icons.person, 
                label: "President", 
                value: details['presidentFullName']?.toString()
              ),
              _ProfileRow(
                icon: Icons.email, 
                label: "Email", 
                value: details['email']?.toString()
              ),
              _ProfileRow(
                icon: Icons.phone, 
                label: "Phone", 
                value: details['phoneNumber']?.toString()
              ),
              
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))),
            ],
          ),
        ),
      ),
    );
  }

  // --- EDIT PROFILE DIALOG ---
  void _showEditDialog() {
    final orgNameCtrl = TextEditingController(text: _volunteerDetails?['organizationName']);
    final presNameCtrl = TextEditingController(text: _volunteerDetails?['presidentFullName']);
    final phoneCtrl = TextEditingController(text: _volunteerDetails?['phoneNumber']);
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Edit Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(controller: orgNameCtrl, decoration: const InputDecoration(labelText: "Org Name", border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: presNameCtrl, decoration: const InputDecoration(labelText: "President Name", border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder())),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.lock_reset),
                      label: const Text("Change Password"),
                      onPressed: () {
                        _showChangePasswordDialog();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent)
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: isLoading ? null : () => Navigator.pop(ctx), child: const Text("Cancel")),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          setStateDialog(() => isLoading = true);
                          try {
                            await _updateProfile(orgNameCtrl.text, presNameCtrl.text, phoneCtrl.text);
                            Navigator.pop(ctx);
                          } catch (e) {
                            setStateDialog(() => isLoading = false);
                          }
                        },
                        child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("Save"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateProfile(String org, String pres, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');
    if (token != null && userId != null) {
      await _apiService.updateVolunteerProfile(token, userId, {
        "organizationName": org,
        "presidentFullName": pres,
        "phoneNumber": phone,
        "email": _volunteerDetails?['email']
      });
      await _loadProfile(); 
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!"), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, 
      initialIndex: 1, 
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Volunteer Dashboard', style: TextStyle(fontSize: 18)),
              Text(
                'Hello, $_organizationName',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle_rounded, size: 30, color: AppColors.primary),
              onPressed: _showProfileDialog, 
            ),
            const SizedBox(width: 12),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Available Tasks'),
              Tab(text: 'My Tasks'),
              Tab(text: 'Impact'),
            ],
          ),
        ),
        // FIX 2: Removed 'const' keyword here
        body: TabBarView(
          children: [
            _AvailableTasksTab(),
            _AssignedTasksTab(),
            _StatsTab(),
          ],
        ),
      ),
    );
  }
}

// --- TAB 1: AVAILABLE DONATIONS ---
class _AvailableTasksTab extends StatefulWidget {
  const _AvailableTasksTab({Key? key}) : super(key: key);
  @override
  State<_AvailableTasksTab> createState() => _AvailableTasksTabState();
}

class _AvailableTasksTabState extends State<_AvailableTasksTab> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  void _loadFeed() { 
    setState(() {
      _feedFuture = _fetchFeed();
    });
  }

  Future<List<dynamic>> _fetchFeed() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) return _apiService.getAllDonationsFeed(token);
    throw Exception("Not logged in");
  }

  Future<void> _claimTask(int donationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('userId');
      if (token != null && userId != null) {
        await _apiService.claimDonation(token, donationId, userId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task Claimed!'), backgroundColor: Colors.green));
        _loadFeed();
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains("error1")) {
        _showError("Unavailable", "Already picked up by someone else.");
        _loadFeed();
      } else if (errorMsg.contains("error2")) {
        _showError("Approval Required", "You are not approved yet. Contact admin.");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${errorMsg.replaceAll("Exception:", "")}'), backgroundColor: Colors.red));
      }
    }
  }

  void _showError(String title, String msg) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(title, style: const TextStyle(color: Colors.red)), content: Text(msg), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]));
  }

  void _confirmClaim(int id, String name) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Confirm"), content: Text("Claim this task?\nItem: $name"), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")), ElevatedButton(onPressed: () { Navigator.pop(ctx); _claimTask(id); }, child: const Text("Yes"))]));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No tasks available."));
        
        final tasks = snapshot.data!.where((t) => t['status'] == 'AVAILABLE').toList();
        if (tasks.isEmpty) return const Center(child: Text("No available tasks."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(task['restaurantName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(task['foodDescription'] ?? ''),
                  Text("Qty: ${task['quantityKg']} kg"),
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _confirmClaim(task['id'], task['foodDescription']), child: const Text("Claim Task")))
                ]),
              ),
            );
          },
        );
      },
    );
  }
}

// --- TAB 2: ASSIGNED TASKS ---
class _AssignedTasksTab extends StatefulWidget {
  const _AssignedTasksTab({Key? key}) : super(key: key);
  @override
  State<_AssignedTasksTab> createState() => _AssignedTasksTabState();
}

class _AssignedTasksTabState extends State<_AssignedTasksTab> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _tasksFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() { 
    setState(() {
      _tasksFuture = _fetchTasks();
    });
  }

  Future<List<dynamic>> _fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');
    if (token != null && userId != null) return _apiService.getVolunteerTasks(token, userId);
    throw Exception("Not logged in");
  }

  // --- ACTIONS ---
  Future<void> _openRestaurantMap(int restaurantId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      // 1. Get the restaurant details (which contains lat/lng)
      final details = await _apiService.getRestaurantDetails(token, restaurantId);
      
      // 2. Extract coordinates
      final lat = details['latitude'];
      final lng = details['longitude'];

      // 3. Open Google Maps with the real coordinates
      if (lat != null && lng != null) {
        final googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
        
        if (await canLaunchUrl(googleMapsUrl)) {
          await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch maps application';
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coordinates not found for this restaurant'))
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening map: $e'))
      );
    }
  }

  Future<void> _callRestaurant(int restaurantId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final details = await _apiService.getRestaurantDetails(token, restaurantId);
      final phone = details['phoneNumber'];
      
      if (phone != null) {
        final Uri launchUri = Uri(scheme: 'tel', path: phone);
        await launchUrl(launchUri);
      } else {
        throw "No phone number available";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _distributeWithoutPhoto(String pickupToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final url = Uri.parse('${ApiService().baseUrl}/donations/distribute/withoutphoto?token=$pickupToken');
      final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        Navigator.pop(context); // Close details
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Distribution confirmed!')));
        _loadTasks(); // Refresh list
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _distributeWithPhoto(String pickupToken, ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo == null) return; // User cancelled

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final url = Uri.parse('${ApiService().baseUrl}/donations/distribute');
      var request = http.MultipartRequest('POST', url);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['token'] = pickupToken;
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading proof...')));

      var response = await request.send();

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context); // Close details
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proof submitted successfully! ✅')));
        _loadTasks();
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showDetails(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), 
      builder: (context) {
        final String token = task['pickupToken'] ?? '';
        final String date = DateFormat('MMM dd, hh:mm a').format(DateTime.parse(task['mustPickupBy']));
        final int restaurantId = task['restaurantId'] ?? 0;
        
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.85, // Taller for buttons
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 20),
                const Center(child: Text("Task Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
                const SizedBox(height: 20),
                
                // QR Code Area
                Center(
                  child: token.isNotEmpty 
                    ? QrImageView(data: token, version: QrVersions.auto, size: 180.0) 
                    : const Text("No Token", style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 10),
                const Center(child: Text("Show to Restaurant for Pickup", style: TextStyle(color: Colors.grey))),
                
                const SizedBox(height: 24),
                const Divider(),
                
                _ProfileRow(icon: Icons.info_outline, label: "Status", value: task['status']),
                _ProfileRow(icon: Icons.restaurant, label: "Restaurant", value: task['restaurantName']),
                _ProfileRow(icon: Icons.fastfood, label: "Item", value: task['foodDescription']),
                _ProfileRow(icon: Icons.access_time, label: "Pickup By", value: date),
                
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openRestaurantMap(restaurantId),
                        icon: const Icon(Icons.map),
                        label: const Text("Map"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _callRestaurant(restaurantId),
                        icon: const Icon(Icons.call),
                        label: const Text("Call"),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Text("Distribution", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                
                if (task['status'] == 'PICKED_UP') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _distributeWithoutPhoto(token),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    icon: const Icon(Icons.check),
                    label: const Text("Distribute (No Photo)"),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(context: context, builder: (ctx) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(leading: const Icon(Icons.camera_alt), title: const Text("Camera"), onTap: () { Navigator.pop(ctx); _distributeWithPhoto(token, ImageSource.camera); }),
                          ListTile(leading: const Icon(Icons.photo_library), title: const Text("Gallery"), onTap: () { Navigator.pop(ctx); _distributeWithPhoto(token, ImageSource.gallery); }),
                        ],
                      ));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Distribute with Photo Proof"),
                  ),
                ),
                ],
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No assigned tasks."));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final task = snapshot.data![index];
            return Card(margin: const EdgeInsets.only(bottom: 16), child: ListTile(
              title: Text(task['foodDescription'] ?? 'Food', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("From: ${task['restaurantName']}"),
                  Text("Status: ${task['status']}", style: TextStyle(color: task['status'] == 'COMPLETED' ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: const Icon(Icons.qr_code_2, color: AppColors.primary),
              onTap: () => _showDetails(task),
            ));
          },
        );
      },
    );
  }
}

// --- TAB 3: IMPACT STATS ---
class _StatsTab extends StatefulWidget {
  const _StatsTab({Key? key}) : super(key: key);
  @override
  State<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab> {
  final ApiService _apiService = ApiService();
  int creditScore = 0;
  int monthCount = 0;
  int totalCount = 0;
  int activeCount = 0;
  int finishedCount = 0; 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');
    if (token != null && userId != null) {
      try {
        final results = await Future.wait([
          _apiService.getVolunteerCreditScore(token, userId),
          _apiService.getVolunteerMonthCount(token, userId),
          _apiService.getVolunteerTotalCount(token, userId),
          _apiService.getVolunteerActiveCount(token, userId),
          _apiService.getVolunteerFinishedCount(token, userId), 
        ]);
        if (mounted) {
          setState(() {
            creditScore = results[0];
            monthCount = results[1];
            totalCount = results[2];
            activeCount = results[3];
            finishedCount = results[4];
            isLoading = false; 
          });
        }
      } catch (e) {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Your Reliability Score", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]), borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Credit Score", style: TextStyle(color: Colors.white, fontSize: 14)),
              Text("$creditScore", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
            ]),
            const Icon(Icons.shield_rounded, color: Colors.white, size: 60)
          ]),
        ),
        const SizedBox(height: 32),
        const Text("Contribution Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _StatCard(label: "Total", value: totalCount, color: Colors.pink)),
          const SizedBox(width: 16),
          Expanded(child: _StatCard(label: "This Month", value: monthCount, color: Colors.orange)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _StatCard(label: "Active", value: activeCount, color: Colors.blue)),
          const SizedBox(width: 16),
          Expanded(child: _StatCard(label: "Finished", value: finishedCount, color: Colors.green)), 
        ]),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool isWide;
  const _StatCard({required this.label, required this.value, required this.color, this.isWide = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("$value", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ]),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  const _ProfileRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(children: [
      Icon(icon, color: Colors.grey, size: 20),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ]),
    ]));
  }
}