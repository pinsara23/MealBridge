import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_button.dart';

class DonorHistoryScreen extends StatefulWidget {
  const DonorHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DonorHistoryScreen> createState() => _DonorHistoryScreenState();
}

class _DonorHistoryScreenState extends State<DonorHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Certificates'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Certificates'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HistoryTab(),
          _CertificatesTab(),
        ],
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> history = [
    {
      'name': 'Chicken Biryani',
      'date': 'Dec 28, 2025',
      'quantity': 'Serves 15',
      'status': 'Completed',
      'peopleFed': 15,
    },
    {
      'name': 'Vegetable Curry',
      'date': 'Dec 25, 2025',
      'quantity': 'Serves 10',
      'status': 'Completed',
      'peopleFed': 10,
    },
    {
      'name': 'Fresh Bread',
      'date': 'Dec 22, 2025',
      'quantity': '20 pieces',
      'status': 'Completed',
      'peopleFed': 8,
    },
    {
      'name': 'Rice and Dal',
      'date': 'Dec 20, 2025',
      'quantity': 'Serves 20',
      'status': 'Cancelled',
      'peopleFed': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item['status'] == 'Completed'
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: item['status'] == 'Completed'
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      item['date'],
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.restaurant_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      item['quantity'],
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (item['status'] == 'Completed') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${item['peopleFed']} people fed',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CertificatesTab extends StatelessWidget {
  final List<Map<String, String>> certificates = [
    {
      'month': 'December 2025',
      'donations': '8',
      'peopleFed': '87',
      'co2Saved': '45 kg',
    },
    {
      'month': 'November 2025',
      'donations': '12',
      'peopleFed': '124',
      'co2Saved': '67 kg',
    },
    {
      'month': 'October 2025',
      'donations': '6',
      'peopleFed': '58',
      'co2Saved': '32 kg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: certificates.length,
      itemBuilder: (context, index) {
        final cert = certificates[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Impact Certificate',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            cert['month']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _CertStat(
                        icon: Icons.volunteer_activism_rounded,
                        label: 'Donations',
                        value: cert['donations']!,
                      ),
                    ),
                    Expanded(
                      child: _CertStat(
                        icon: Icons.people_rounded,
                        label: 'People Fed',
                        value: cert['peopleFed']!,
                      ),
                    ),
                    Expanded(
                      child: _CertStat(
                        icon: Icons.eco_rounded,
                        label: 'CO₂ Saved',
                        value: cert['co2Saved']!,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                const Divider(),
                
                const SizedBox(height: 12),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Download'),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.divider,
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Share'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CertStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CertStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
