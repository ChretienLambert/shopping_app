import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sale_provider.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';
import 'package:fl_chart/fl_chart.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(saleProvider);
    final expenses = ref.watch(expenseProvider);

    final totalRevenue = sales.fold(0.0, (sum, item) => sum + item.totalAmount);
    final totalExpenses = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final netProfit = totalRevenue - totalExpenses;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(totalRevenue, totalExpenses, netProfit),
            const SizedBox(height: 32),
            _buildChartSection(totalRevenue, totalExpenses),
            const SizedBox(height: 32),
            _buildRecentMovements(sales, expenses),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double revenue, double expenses, double profit) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 3 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: constraints.maxWidth > 800 ? 2.5 : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard(
              'Total Revenue',
              CurrencyUtils.format(revenue),
              Icons.trending_up_rounded,
              Colors.green,
            ),
            _buildStatCard(
              'Total Expenses',
              CurrencyUtils.format(expenses),
              Icons.trending_down_rounded,
              Colors.red,
            ),
            _buildStatCard(
              'Net Profit',
              CurrencyUtils.format(profit),
              profit >= 0 ? Icons.account_balance_wallet_rounded : Icons.warning_rounded,
              profit >= 0 ? AppTheme.primaryBlue : Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppTheme.slate500, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(double revenue, double expenses) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (revenue > expenses ? revenue : expenses) * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: const FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: revenue,
                        color: Colors.green,
                        width: 40,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: expenses,
                        color: Colors.red,
                        width: 40,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMovements(List<dynamic> sales, List<dynamic> expenses) {
    final List<dynamic> combined = [...sales, ...expenses];
    combined.sort((a, b) {
      final dateA = a is DateTime ? a : (a.saleDate ?? a.expenseDate);
      final dateB = b is DateTime ? b : (b.saleDate ?? b.expenseDate);
      return dateB.compareTo(dateA);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transactions History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...combined.take(10).map((item) {
          final isSale = item.runtimeType.toString().contains('Sale');
          final date = isSale ? item.saleDate : item.expenseDate;
          final amount = isSale ? item.totalAmount : item.amount;
          final title = isSale ? 'Sale #${item.serverId.substring(0, 5)}' : item.description;

          return Card(
            elevation: 0,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.slate200),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isSale ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSale ? Icons.add_rounded : Icons.remove_rounded,
                  color: isSale ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${date.day}/${date.month}/${date.year}'),
              trailing: Text(
                '${isSale ? "+" : "-"}${CurrencyUtils.format(amount)}',
                style: TextStyle(
                  color: isSale ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
