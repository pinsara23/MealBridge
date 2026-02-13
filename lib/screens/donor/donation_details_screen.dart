
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/colors.dart';
import '../../services/api_service.dart';
import '../../services/websocket_service.dart';
import '../../widgets/custom_button.dart';

class DonationDetailsScreen extends StatefulWidget {
  final int donationId;
  final String initialStatus;
  final String foodDescription;
  final String quantity;
  final String pickupTime;
  final String volunteerName;
  final String volunteerPhone;
  final String restaurantName; // Added

  const DonationDetailsScreen({
    Key? key,
    required this.donationId,
    required this.initialStatus,
    required this.foodDescription,
    required this.quantity,
    required this.pickupTime,
    required this.restaurantName,
    this.volunteerName = "Not Assigned",
    this.volunteerPhone = "",
  }) : super(key: key);

  @override
  State<DonationDetailsScreen> createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  final WebSocketService _wsService = WebSocketService();
  final ApiService _apiService = ApiService();
  
  late String _currentStatus;
  late String _currentVolunteer;
  late String _currentVolunteerPhone;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
    _currentVolunteer = widget.volunteerName;
    _currentVolunteerPhone = widget.volunteerPhone;
    _initWebSocket();
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }

  // --- WEBSOCKET LOGIC ---
  Future<void> _initWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      _wsService.connect(token, (frame) {
        print("✅ Details: WebSocket Connected");

        // Listen for specific updates to THIS donation
        _wsService.subscribeToDonation(widget.donationId, (newMessage) {
          print("📩 Status Update: $newMessage");

          if (mounted) {
            setState(() {
              _currentStatus = newMessage; 
              // Note: If you want volunteer details to update live, 
              // your backend message should be a JSON object containing {status, volunteerName, phone}.
              // For now, we just update status.
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Status changed to: $newMessage"),
                backgroundColor: Colors.blue,
                behavior: SnackBarBehavior.floating,
              )
            );
          }
        });
      });
    }
  }

  // --- ACTIONS ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No phone number available")));
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch dialer")));
    }
  }

  Future<void> _cancelDonation() async {
    // API Call would go here
    try {
      // await _apiService.cancelDonation(token, widget.donationId);
      
      setState(() {
        _currentStatus = "CANCELLED";
      });
      Navigator.pop(context); // Go back
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Donation Cancelled")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors/icons based on status
    Color statusColor;
    int currentStep = 0;

    switch (_currentStatus) {
      case 'AVAILABLE':
        statusColor = Colors.green;
        currentStep = 0;
        break;
      case 'CLAIMED':
        statusColor = Colors.orange;
        currentStep = 1;
        break;
      case 'PICKED_UP':
        statusColor = Colors.blue;
        currentStep = 2;
        break;
      case 'COMPLETED':
      case 'DELIVERED':
        statusColor = Colors.purple;
        currentStep = 3;
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        currentStep = 0;
        break;
      default:
        statusColor = Colors.grey;
        currentStep = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image/Icon
            Container(
              width: double.infinity,
              height: 200,
              color: AppColors.primary.withOpacity(0.1),
              child: const Icon(
                Icons.fastfood_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.foodDescription,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          _currentStatus,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Live Status Tracker
                  if (_currentStatus != 'CANCELLED')
                    _StatusTracker(currentStep: currentStep),
                  
                  const SizedBox(height: 24),
                  
                  // Information Cards
                  _InfoSection(
                    title: 'Food Details',
                    items: [
                      _InfoItem(icon: Icons.scale, label: 'Quantity', value: "${widget.quantity} kg"),
                      _InfoItem(icon: Icons.access_time_filled, label: 'Pickup Time', value: widget.pickupTime),
                      _InfoItem(icon: Icons.store, label: 'Restaurant', value: widget.restaurantName),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Volunteer Section (Only show if claimed)
                  if (_currentStatus != 'AVAILABLE' && _currentStatus != 'CANCELLED')
                    _InfoSection(
                      title: 'Assigned Volunteer',
                      items: [
                        _InfoItem(icon: Icons.person, label: 'Name', value: _currentVolunteer),
                        _InfoItem(
                          icon: Icons.phone, 
                          label: 'Phone', 
                          value: _currentVolunteerPhone.isNotEmpty ? _currentVolunteerPhone : "Not Available",
                          actionIcon: Icons.call,
                          onAction: () => _makePhoneCall(_currentVolunteerPhone),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 40),
                  
                  // Buttons
                  if (_currentStatus == 'AVAILABLE')
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Cancel Donation',
                        onPressed: _cancelDonation,
                        isOutlined: true,
                        //backgroundColor: Colors.red,
                        textColor: Colors.red,
                        icon: Icons.cancel_presentation,
                      ),
                    ),

                  if (_currentStatus == 'CLAIMED')
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Contact Volunteer',
                        onPressed: () => _makePhoneCall(_currentVolunteerPhone),
                        icon: Icons.phone_in_talk,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _StatusTracker extends StatelessWidget {
  final int currentStep;
  const _StatusTracker({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'title': 'Posted', 'icon': Icons.add_circle},
      {'title': 'Claimed', 'icon': Icons.volunteer_activism},
      {'title': 'Picked Up', 'icon': Icons.local_shipping},
      {'title': 'Delivered', 'icon': Icons.check_circle},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Live Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length, (index) {
              final isCompleted = index <= currentStep;
              final isLast = index == steps.length - 1;
              return Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Icon(steps[index]['icon'] as IconData, 
                             color: isCompleted ? AppColors.primary : Colors.grey[300]),
                        const SizedBox(height: 4),
                        Text(steps[index]['title'] as String, 
                             style: TextStyle(fontSize: 10, color: isCompleted ? Colors.black : Colors.grey)),
                      ],
                    ),
                    if (!isLast)
                      Expanded(child: Container(height: 2, color: isCompleted ? AppColors.primary : Colors.grey[300])),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const _InfoItem({required this.icon, required this.label, required this.value, this.actionIcon, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (actionIcon != null)
            IconButton(icon: Icon(actionIcon, color: AppColors.primary), onPressed: onAction)
        ],
      ),
    );
  }
}