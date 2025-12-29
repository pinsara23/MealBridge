import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/status_chip.dart';

class VolunteerDashboardScreen extends StatelessWidget {
  const VolunteerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Volunteer Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_rounded),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Assigned Tasks'),
              Tab(text: 'Available Tasks'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AssignedTasksTab(),
            _AvailableTasksTab(),
          ],
        ),
      ),
    );
  }
}

class _AssignedTasksTab extends StatelessWidget {
  final List<Map<String, dynamic>> assignedTasks = [
    {
      'id': '1',
      'donorName': 'Green Valley Restaurant',
      'recipientName': 'Community Center ABC',
      'foodItem': 'Rice and Curry',
      'pickupAddress': '123 Main Street',
      'dropAddress': '456 Oak Avenue',
      'status': 'In Progress',
      'distance': '2.5 km',
      'time': 'Pickup: 5:00 PM',
    },
    {
      'id': '2',
      'donorName': 'City Bakery',
      'recipientName': 'Hope Shelter',
      'foodItem': 'Bread and Pastries',
      'pickupAddress': '789 Pine Road',
      'dropAddress': '321 Elm Street',
      'status': 'Pending',
      'distance': '3.2 km',
      'time': 'Pickup: 6:00 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignedTasks.length,
      itemBuilder: (context, index) {
        final task = assignedTasks[index];
        return _TaskCard(
          task: task,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.taskDetails,
              arguments: task,
            );
          },
        );
      },
    );
  }
}

class _AvailableTasksTab extends StatelessWidget {
  final List<Map<String, dynamic>> availableTasks = [
    {
      'id': '3',
      'donorName': 'Farm Fresh Market',
      'recipientName': 'St. Mary\'s Church',
      'foodItem': 'Fresh Vegetables',
      'pickupAddress': '555 Garden Lane',
      'dropAddress': '777 Church Street',
      'status': 'Available',
      'distance': '4.1 km',
      'time': 'Pickup: 7:00 PM',
    },
    {
      'id': '4',
      'donorName': 'Spice Garden',
      'recipientName': 'Family Services Center',
      'foodItem': 'Chicken Biryani',
      'pickupAddress': '888 Food Court',
      'dropAddress': '999 Help Avenue',
      'status': 'Available',
      'distance': '5.5 km',
      'time': 'Pickup: 8:00 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableTasks.length,
      itemBuilder: (context, index) {
        final task = availableTasks[index];
        return _AvailableTaskCard(
          task: task,
          onAccept: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task accepted!'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                      task['foodItem'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  StatusChip(status: task['status']),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Pickup Location
              _LocationRow(
                icon: Icons.store_rounded,
                label: 'Pickup',
                value: task['donorName'],
                address: task['pickupAddress'],
              ),
              
              const SizedBox(height: 8),
              
              // Drop Location
              _LocationRow(
                icon: Icons.location_on_rounded,
                label: 'Drop',
                value: task['recipientName'],
                address: task['dropAddress'],
              ),
              
              const SizedBox(height: 12),
              
              // Info Row
              Row(
                children: [
                  const Icon(Icons.directions_car_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    task['distance'],
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    task['time'],
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailableTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onAccept;

  const _AvailableTaskCard({
    required this.task,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              task['foodItem'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Pickup Location
            _LocationRow(
              icon: Icons.store_rounded,
              label: 'Pickup',
              value: task['donorName'],
              address: task['pickupAddress'],
            ),
            
            const SizedBox(height: 8),
            
            // Drop Location
            _LocationRow(
              icon: Icons.location_on_rounded,
              label: 'Drop',
              value: task['recipientName'],
              address: task['dropAddress'],
            ),
            
            const SizedBox(height: 12),
            
            // Info Row
            Row(
              children: [
                const Icon(Icons.directions_car_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  task['distance'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  task['time'],
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Accept Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Accept Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String address;

  const _LocationRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label: $value',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
