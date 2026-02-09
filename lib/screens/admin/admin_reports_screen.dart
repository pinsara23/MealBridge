import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_button.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.admin.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.file_download_rounded, size: 20),
              onPressed: () {},
              color: AppColors.admin,
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF9FBFF),
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Selector
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.admin.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: AppColors.admin.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.admin.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.date_range_rounded, color: AppColors.admin, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report Period',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Last 30 Days',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Impact Summary
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.insights_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Impact Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _ChartCard(
              title: 'Donations Over Time',
              subtitle: 'Daily donation trends',
              icon: Icons.show_chart_rounded,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Chart: Line graph showing donations',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            _ChartCard(
              title: 'Food Category Distribution',
              subtitle: 'Types of food donated',
              icon: Icons.pie_chart_rounded,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Chart: Pie chart of food categories',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Performance Metrics
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.admin.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.speed_rounded, color: AppColors.admin, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Performance Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  _MetricRow(
                    label: 'Total Donations',
                    value: '1,245',
                    trend: '+18%',
                    isPositive: true,
                  ),
                  const Divider(height: 24),
                  _MetricRow(
                    label: 'Completed Deliveries',
                    value: '1,187',
                    trend: '+22%',
                    isPositive: true,
                  ),
                  const Divider(height: 24),
                  _MetricRow(
                    label: 'Average Response Time',
                    value: '12 mins',
                    trend: '-8%',
                    isPositive: true,
                  ),
                  const Divider(height: 24),
                  _MetricRow(
                    label: 'Success Rate',
                    value: '95.3%',
                    trend: '+2.1%',
                    isPositive: true,
                  ),
                  const Divider(height: 24),
                  _MetricRow(
                    label: 'Food Waste Prevented',
                    value: '8,234 kg',
                    trend: '+25%',
                    isPositive: true,
                  ),
                  const Divider(height: 24),
                  _MetricRow(
                    label: 'CO₂ Emissions Saved',
                    value: '12.5 tons',
                    trend: '+19%',
                    isPositive: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Top Performers
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: AppColors.warning, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Top Performers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _TopPerformerCard(
              title: 'Top Donors',
              items: [
                {'name': 'Green Valley Restaurant', 'count': '156'},
                {'name': 'City Bakery', 'count': '134'},
                {'name': 'Farm Fresh Market', 'count': '98'},
              ],
            ),
            
            const SizedBox(height: 16),
            
            _TopPerformerCard(
              title: 'Top Volunteers',
              items: [
                {'name': 'Jane Smith', 'count': '87'},
                {'name': 'John Doe', 'count': '76'},
                {'name': 'Sarah Johnson', 'count': '65'},
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Export Options
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.upload_file_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Export Reports',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'PDF Report',
                    onPressed: () {},
                    icon: Icons.picture_as_pdf_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Excel Report',
                    onPressed: () {},
                    icon: Icons.table_chart_rounded,
                    isOutlined: true,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            CustomButton(
              text: 'Email Report',
              onPressed: () {},
              icon: Icons.email_rounded,
              isOutlined: true,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPositive
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                trend,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TopPerformerCard extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;

  const _TopPerformerCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.warning.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: AppColors.warning.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: index == 0
                          ? const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFA726)])
                          : null,
                      color: index != 0 ? AppColors.primary.withOpacity(0.1) : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: index == 0
                          ? const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 18)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['count']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
