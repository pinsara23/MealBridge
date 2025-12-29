import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_button.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Period',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Last 30 Days',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today_rounded),
                    onPressed: () {},
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Impact Summary
            const Text(
              'Impact Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
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
            const Text(
              'Performance Metrics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
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
            const Text(
              'Top Performers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
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
            const Text(
              'Export Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? AppColors.warning.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: index == 0 ? AppColors.warning : AppColors.primary,
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
