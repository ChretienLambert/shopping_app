import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weekly_checkup.dart';
import '../repositories/weekly_checkup_repository.dart';
import '../utils/app_localization.dart';
import '../utils/currency_utils.dart';
import 'package:intl/intl.dart';

class WeeklyReportsScreen extends ConsumerStatefulWidget {
  const WeeklyReportsScreen({super.key});

  @override
  ConsumerState<WeeklyReportsScreen> createState() => _WeeklyReportsScreenState();
}

class _WeeklyReportsScreenState extends ConsumerState<WeeklyReportsScreen> {
  final _repository = WeeklyCheckupRepository();
  List<WeeklyCheckup> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    final reports = await _repository.getAll();
    setState(() {
      _reports = reports;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(ref, 'weekly_reports')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics_outlined, size: 48, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        tr(ref, 'no_reports_yet'),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return _buildReportCard(report);
                  },
                ),
    );
  }

  Widget _buildReportCard(WeeklyCheckup report) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final dateRange = '${dateFormat.format(report.weekStartDate)} - ${dateFormat.format(report.weekEndDate)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(
          dateRange,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          '${tr(ref, 'revenue')}: ${CurrencyUtils.format(report.totalSalesRevenue)}',
          style: theme.textTheme.bodyMedium,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow(tr(ref, 'total_revenue'), CurrencyUtils.format(report.totalSalesRevenue)),
                _buildStatRow(tr(ref, 'stock_deployed'), CurrencyUtils.format(report.totalStockPurchased)),
                _buildStatRow(tr(ref, 'realized_profit'), CurrencyUtils.format(report.realizedProfit), isHighlight: true),
                _buildStatRow(tr(ref, 'sales_count'), report.salesCount.toString()),
                const Divider(height: 24),
                if (report.categoryRevenue != null && report.categoryRevenue!.isNotEmpty) ...[
                  Text(
                    tr(ref, 'category_breakdown'),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  ...report.categoryRevenue!.entries.map((e) => _buildStatRow(tr(ref, e.key.toLowerCase()), CurrencyUtils.format(e.value))),
                  const Divider(height: 24),
                ],
                if (report.topProducts != null && report.topProducts!.isNotEmpty) ...[
                  Text(
                    tr(ref, 'top_products'),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  ...report.topProducts!.map((p) => _buildStatRow(p['name'] ?? 'Unknown', '${p['count']} ${tr(ref, 'unit_sales')}')),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value, 
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? Colors.green : null,
            )
          ),
        ],
      ),
    );
  }
}
