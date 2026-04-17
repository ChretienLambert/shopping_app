import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../models/weekly_checkup.dart';
import '../providers/expense_provider.dart';
import '../providers/financial_stats_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/weekly_checkup_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localization.dart';
import '../utils/currency_utils.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(financialStatsProvider);

    final profitControlCards = Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            tr(ref, 'available_profit'),
            CurrencyUtils.format(stats.totalNetProfit),
            Icons.savings_rounded,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            tr(ref, 'salary_from_profit'),
            CurrencyUtils.format(stats.totalPayout),
            Icons.payments_rounded,
            AppTheme.primaryBlue,
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Navigation / Actions
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth > 600 ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth,
                      child: OutlinedButton.icon(
                        onPressed: () => _showQuickResume(
                          context,
                          ref,
                          stats: stats,
                        ),
                        icon: const Icon(Icons.summarize_outlined),
                        label: FittedBox(fit: BoxFit.scaleDown, child: Text(tr(ref, 'quick_resume'))),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth > 600 ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth,
                      child: OutlinedButton.icon(
                        onPressed: () => _addInjection(context, ref),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: FittedBox(fit: BoxFit.scaleDown, child: Text(tr(ref, 'inject_capital'))),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth > 600 ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth,
                      child: OutlinedButton.icon(
                        onPressed: () => _showWeeklyCheckupDialog(
                          context,
                          ref,
                          stats: stats,
                        ),
                        icon: const Icon(Icons.calendar_today_rounded),
                        label: FittedBox(fit: BoxFit.scaleDown, child: Text(tr(ref, 'weekly_checkup'))),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Key Stats Wrap
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 220,
                  child: _buildStatCard(
                    context,
                    tr(ref, 'capital_pool'),
                    CurrencyUtils.format(stats.capitalPool),
                    Icons.account_balance_wallet_rounded,
                    AppTheme.primaryBlue,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _buildStatCard(
                    context,
                    tr(ref, 'cash_capital'),
                    CurrencyUtils.format(stats.cashCapital),
                    Icons.payments_rounded,
                    Colors.green,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _buildStatCard(
                    context,
                    tr(ref, 'assets_capital'),
                    CurrencyUtils.format(stats.assetsCapital),
                    Icons.inventory_2_rounded,
                    Colors.orange,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _buildStatCard(
                    context,
                    tr(ref, 'stock_deployed'),
                    CurrencyUtils.format(stats.totalStockDeployed),
                    Icons.inventory_2_outlined,
                    AppTheme.primary,
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _buildStatCard(
                    context,
                    tr(ref, 'sales_count'),
                    '${stats.totalSalesCount}',
                    Icons.shopping_bag_rounded,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCapitalProgressCard(
              context,
              ref,
              stockDeployed: stats.totalStockDeployed,
              recoveredFromSales: stats.totalRecoveredFromSales,
              remainingToRecover: stats.totalRemainingToRecover,
              completion: stats.totalCoverage,
              realizedProfit: stats.totalNetProfit,
            ),
            const SizedBox(height: 16),
            profitControlCards,
            const SizedBox(height: 16),
            _buildFinancialSummaryCard(
              context,
              ref,
              revenue: stats.totalRevenue,
              stockDeployed: stats.totalStockDeployed,
              businessExpenses: stats.totalBusinessCost,
              personalPayouts: stats.totalPayout,
            ),
            const SizedBox(height: 16),
            _buildInjectionsList(context, ref),
            const SizedBox(height: 24),
            _buildMonthlyWeeklyResume(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyWeeklyResume(BuildContext context, WidgetRef ref) {
    final rawSales = ref.watch(saleProvider);
    final allExpenses = ref.watch(expenseProvider);
    
    // Get all sales and expenses
    final sales = rawSales.where((s) => s.deletedAt == null).toList();
    final expenses = allExpenses.where((e) => e.deletedAt == null).toList();
    
    // Group by month
    final monthlyData = <String, List<Map<String, dynamic>>>{};
    
    for (final sale in sales) {
      final monthKey = '${sale.saleDate.year}-${sale.saleDate.month.toString().padLeft(2, '0')}';
      monthlyData.putIfAbsent(monthKey, () => []);
      monthlyData[monthKey]!.add({
        'type': 'sale',
        'date': sale.saleDate,
        'amount': sale.totalAmount,
        'isPaid': sale.isPaid,
      });
    }
    
    for (final expense in expenses) {
      final monthKey = '${expense.expenseDate.year}-${expense.expenseDate.month.toString().padLeft(2, '0')}';
      monthlyData.putIfAbsent(monthKey, () => []);
      monthlyData[monthKey]!.add({
        'type': 'expense',
        'date': expense.expenseDate,
        'amount': expense.amount,
        'category': expense.category,
      });
    }
    
    // Sort months in descending order
    final sortedMonths = monthlyData.keys.toList()..sort((a, b) => b.compareTo(a));
    
    if (sortedMonths.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(ref, 'monthly_weekly_resume'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 16),
          ...sortedMonths.take(6).map((monthKey) {
            final year = int.parse(monthKey.split('-')[0]);
            final month = int.parse(monthKey.split('-')[1]);
            final monthName = _getMonthName(month);
            final weekData = _calculateWeeklyStats(monthlyData[monthKey]!, year, month);
            
            return ExpansionTile(
              title: Text('$monthName $year', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
              tilePadding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ...weekData.entries.map((entry) {
                        final weekNum = entry.key;
                        final stats = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppTheme.slate800 : AppTheme.slate50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Week $weekNum', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                              const SizedBox(height: 8),
                              _buildResumeRow(tr(ref, 'revenue'), CurrencyUtils.format(stats['revenue'] ?? 0), isDarkMode: isDarkMode),
                              _buildResumeRow(tr(ref, 'stock_deployed'), CurrencyUtils.format(stats['stockDeployed'] ?? 0), isDarkMode: isDarkMode),
                              _buildResumeRow(tr(ref, 'business_expenses'), CurrencyUtils.format(stats['businessExpenses'] ?? 0), isDarkMode: isDarkMode),
                              _buildResumeRow(tr(ref, 'personal_payout'), CurrencyUtils.format(stats['personalPayout'] ?? 0), isDarkMode: isDarkMode),
                              _buildResumeRow(tr(ref, 'net_profit'), CurrencyUtils.format(stats['netProfit'] ?? 0), isHighlight: true, isDarkMode: isDarkMode),
                              _buildResumeRow(tr(ref, 'sales_count'), '${stats['salesCount'] ?? 0}', isDarkMode: isDarkMode),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Map<int, Map<String, double>> _calculateWeeklyStats(List<Map<String, dynamic>> monthData, int year, int month) {
    final weeklyStats = <int, Map<String, double>>{};
    
    for (int week = 1; week <= 5; week++) {
      weeklyStats[week] = {
        'revenue': 0,
        'stockDeployed': 0,
        'businessExpenses': 0,
        'personalPayout': 0,
        'netProfit': 0,
        'salesCount': 0,
      };
    }
    
    for (final item in monthData) {
      final date = item['date'] as DateTime;
      if (date.year != year || date.month != month) continue;
      
      final weekNum = _getWeekOfMonth(date);
      final stats = weeklyStats[weekNum]!;
      
      if (item['type'] == 'sale') {
        if (item['isPaid'] == true) {
          stats['revenue'] = stats['revenue']! + item['amount'] as double;
          stats['salesCount'] = stats['salesCount']! + 1;
        }
      } else if (item['type'] == 'expense') {
        final category = item['category'] as ExpenseCategory;
        if (category == ExpenseCategory.stock) {
          stats['stockDeployed'] = stats['stockDeployed']! + item['amount'] as double;
        } else if (category == ExpenseCategory.business) {
          stats['businessExpenses'] = stats['businessExpenses']! + item['amount'] as double;
        } else if (category == ExpenseCategory.personalPayout) {
          stats['personalPayout'] = stats['personalPayout']! + item['amount'] as double;
        }
      }
      
      stats['netProfit'] = stats['revenue']! - stats['stockDeployed']! - stats['businessExpenses']! - stats['personalPayout']!;
    }
    
    return weeklyStats;
  }

  int _getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final dayOfMonth = date.day;
    return ((dayOfMonth - 1 + firstDayOfMonth.weekday - 1) / 7).floor() + 1;
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  Widget _buildCapitalProgressCard(
    BuildContext context,
    WidgetRef ref, {
    required double stockDeployed,
    required double recoveredFromSales,
    required double remainingToRecover,
    required double completion,
    required double realizedProfit,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final positiveColor = isDarkMode ? AppTheme.chart5 : Colors.green;
    final negativeColor = isDarkMode ? AppTheme.chart3 : Colors.red;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(tr(ref, 'capital_energy'), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(width: 6),
              Tooltip(
                message: tr(ref, 'capital_energy_desc'),
                child: Icon(Icons.help_outline_rounded, color: isDarkMode ? AppTheme.slate400 : AppTheme.slate500, size: 16),
              ),
              const Spacer(),
              Text('${(completion * 100).toStringAsFixed(1)}%', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 8),
          Text('${tr(ref, 'stock_deployed')} ${CurrencyUtils.format(stockDeployed)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          Text('${tr(ref, 'recovered_from_sales')} ${CurrencyUtils.format(recoveredFromSales)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          Text('${tr(ref, 'remaining_to_recover')} ${CurrencyUtils.format(remainingToRecover)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completion.clamp(0, 1),
            backgroundColor: isDarkMode ? AppTheme.slate800 : AppTheme.slate200,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
          const SizedBox(height: 8),
          Text(
            '${tr(ref, 'realized_profit')}: ${CurrencyUtils.format(realizedProfit)}',
            style: TextStyle(
              color: realizedProfit >= 0 ? positiveColor : negativeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCard(
    BuildContext context,
    WidgetRef ref, {
    required double revenue,
    required double stockDeployed,
    required double businessExpenses,
    required double personalPayouts,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final grossMargin = revenue <= 0 ? 0.0 : ((revenue - stockDeployed) / revenue);
    final operatingMargin = revenue <= 0 ? 0.0 : ((revenue - stockDeployed - businessExpenses - personalPayouts) / revenue);
    final payoutRatio = (revenue - stockDeployed - businessExpenses) <= 0 ? 0.0 : (personalPayouts / (revenue - stockDeployed - businessExpenses));
    final businessCostRatio = revenue <= 0 ? 0.0 : (businessExpenses / revenue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(ref, 'finance_summary'), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 10),
          _buildSummaryRow(tr(ref, 'revenue'), CurrencyUtils.format(revenue)),
          _buildSummaryRow(tr(ref, 'stock_deployed'), CurrencyUtils.format(stockDeployed)),
          _buildSummaryRow(tr(ref, 'business_expenses'), CurrencyUtils.format(businessExpenses)),
          _buildSummaryRow(tr(ref, 'owner_salary'), CurrencyUtils.format(personalPayouts)),
          Divider(height: 22, color: isDarkMode ? AppTheme.slate700 : AppTheme.slate200),
          _buildSummaryRow(tr(ref, 'gross_margin'), '${(grossMargin * 100).toStringAsFixed(1)}%', tooltip: tr(ref, 'gross_margin_help')),
          _buildSummaryRow(tr(ref, 'operating_margin'), '${(operatingMargin * 100).toStringAsFixed(1)}%', tooltip: tr(ref, 'operating_margin_help')),
          _buildSummaryRow(tr(ref, 'salary_ratio'), '${(payoutRatio * 100).toStringAsFixed(1)}%', tooltip: tr(ref, 'salary_ratio_help')),
          _buildSummaryRow(
            tr(ref, 'business_cost_ratio'),
            '${(businessCostRatio * 100).toStringAsFixed(1)}%',
            tooltip: tr(ref, 'business_cost_ratio_help'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {String? tooltip}) {
    final valueWidget = Text(value, style: const TextStyle(fontWeight: FontWeight.w600));
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(color: AppTheme.slate400), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          tooltip != null
              ? Tooltip(
                  message: tooltip,
                  child: valueWidget,
                )
              : valueWidget,
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title, 
            style: TextStyle(color: isDarkMode ? AppTheme.slate400 : AppTheme.slate500, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }

  Widget _buildInjectionsList(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final injections = expenses
        .where((e) => e.category == ExpenseCategory.capitalInjection)
        .toList();
        
    if (injections.isEmpty) {
      return const SizedBox.shrink();
    }
    
    injections.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr(ref, 'capital_injections'), style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...injections.map((i) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.add_circle_outline_rounded),
            title: Text(i.description),
            subtitle: Text('${i.expenseDate.day}/${i.expenseDate.month}/${i.expenseDate.year}'),
            trailing: Text(
              CurrencyUtils.format(i.amount),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () => _showInjectionDetail(context, ref, i),
          );
        }),
      ],
    );
  }

  void _showInjectionDetail(BuildContext context, WidgetRef ref, Expense injection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'capital_injection_details')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(tr(ref, 'description'), injection.description),
            _buildDetailRow(tr(ref, 'amount'), CurrencyUtils.format(injection.amount)),
            _buildDetailRow(tr(ref, 'date'), '${injection.expenseDate.day}/${injection.expenseDate.month}/${injection.expenseDate.year}'),
            _buildDetailRow(tr(ref, 'time'), '${injection.expenseDate.hour.toString().padLeft(2, '0')}:${injection.expenseDate.minute.toString().padLeft(2, '0')}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(expenseProvider.notifier).deleteExpense(injection);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(tr(ref, 'delete')),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr(ref, 'close'))),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label, 
              style: TextStyle(color: AppTheme.slate400, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _addInjection(BuildContext context, WidgetRef ref) async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final result = await showDialog<Expense>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'inject_capital')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: tr(ref, 'amount_xaf')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: tr(ref, 'description')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr(ref, 'cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              Expense(
                amount: double.tryParse(amountController.text) ?? 0,
                description: descriptionController.text.isEmpty
                    ? tr(ref, 'cash_capital_injection')
                    : descriptionController.text,
                category: ExpenseCategory.capitalInjection,
                expenseDate: DateTime.now(),
              ),
            ),
            child: Text(tr(ref, 'add')),
          ),
        ],
      ),
    );
    if (result == null || result.amount <= 0) return;
    await ref.read(expenseProvider.notifier).addExpense(result);
  }

  void _showQuickResume(
    BuildContext context,
    WidgetRef ref, {
    required FinancialStats stats,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final positiveColor = isDarkMode ? AppTheme.chart5 : Colors.green;
    final negativeColor = isDarkMode ? AppTheme.chart3 : Colors.red;
    final orangeColor = isDarkMode ? AppTheme.chart4 : Colors.orange;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.summarize_outlined, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Text(tr(ref, 'financial_resume')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.primaryBlue.withValues(alpha: 0.2) : AppTheme.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_rounded, size: 16, color: AppTheme.primaryBlue),
                        const SizedBox(width: 6),
                        Text(tr(ref, 'capital_overview'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildResumeRow(tr(ref, 'capital_pool'), CurrencyUtils.format(stats.capitalPool), isDarkMode: isDarkMode),
                    _buildResumeRow(tr(ref, 'cash_capital'), CurrencyUtils.format(stats.cashCapital), isDarkMode: isDarkMode),
                    _buildResumeRow(tr(ref, 'capital_covered'), '${(stats.totalCoverage * 100).toStringAsFixed(1)}%', tooltip: tr(ref, 'capital_covered_help'), isDarkMode: isDarkMode),
                    _buildResumeRow(tr(ref, 'remaining_to_recover'), CurrencyUtils.format(stats.totalRemainingToRecover), isDarkMode: isDarkMode),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: stats.totalNetProfit >= 0 
                      ? (isDarkMode ? positiveColor.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.08))
                      : (isDarkMode ? negativeColor.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          stats.totalNetProfit >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 16,
                          color: stats.totalNetProfit >= 0 ? positiveColor : negativeColor,
                        ),
                        const SizedBox(width: 6),
                        Text(tr(ref, 'profit_analysis'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildResumeRow(tr(ref, 'realized_profit'), CurrencyUtils.format(stats.totalNetProfit), isHighlight: true, isDarkMode: isDarkMode),
                    _buildResumeRow(tr(ref, 'total_revenue'), CurrencyUtils.format(stats.totalRevenue), isDarkMode: isDarkMode),
                    _buildResumeRow(tr(ref, 'stock_cost'), CurrencyUtils.format(stats.totalStockDeployed), isDarkMode: isDarkMode),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? orangeColor.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 16, color: orangeColor),
                        const SizedBox(width: 6),
                        Text(tr(ref, 'expenses_breakdown'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildResumeRow(tr(ref, 'business_expenses'), CurrencyUtils.format(stats.totalBusinessCost), isDarkMode: isDarkMode),
                    _buildResumeRow(tr(ref, 'personal_payout'), CurrencyUtils.format(stats.totalPayout), isDarkMode: isDarkMode),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr(ref, 'close'))),
        ],
      ),
    );
  }

  Widget _buildResumeRow(String label, String value, {bool isHighlight = false, String? tooltip, required bool isDarkMode}) {
    final positiveColor = isDarkMode ? AppTheme.chart5 : Colors.green;
    final negativeColor = isDarkMode ? AppTheme.chart3 : Colors.red;
    
    final valueWidget = Text(
      value,
      style: TextStyle(
        fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
        fontSize: 13,
        color: isHighlight ? (value.startsWith('-') ? negativeColor : positiveColor) : null,
      ),
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label, 
              style: TextStyle(color: AppTheme.slate400, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          tooltip != null
              ? Tooltip(
                  message: tooltip,
                  child: valueWidget,
                )
              : valueWidget,
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showWeeklyCheckupDialog(
    BuildContext context,
    WidgetRef ref, {
    required FinancialStats stats,
  }) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final orangeColor = isDarkMode ? AppTheme.chart4 : Colors.orange;
    final notesController = TextEditingController();
    final payoutController = TextEditingController(text: '0');

    // Calculate previous week's stats
    final now = DateTime.now();
    final previousWeekEnd = WeeklyCheckup.getWeekStartDate(now).subtract(const Duration(days: 1));
    final previousWeekStart = WeeklyCheckup.getWeekStartDate(previousWeekEnd);
    
    final rawSales = ref.read(saleProvider);
    final allExpenses = ref.read(expenseProvider);
    
    final weekSales = rawSales.where((s) => 
      (s.saleDate.isAfter(previousWeekStart) || s.saleDate.isAtSameMomentAs(previousWeekStart)) &&
      s.saleDate.isBefore(previousWeekEnd.add(const Duration(days: 1))) &&
      s.deletedAt == null
    ).toList();
    
    final weekExpenses = allExpenses.where((e) => 
      e.expenseDate.isAfter(previousWeekStart) || e.expenseDate.isAtSameMomentAs(previousWeekStart)
    ).toList();

    final revenue = weekSales.where((s) => s.isPaid).fold<double>(0, (sum, s) => sum + s.totalAmount);
    final weekStockExpenses = weekExpenses.where((e) => e.category == ExpenseCategory.stock);
    final weekBusinessExpenses = weekExpenses.where((e) => e.category == ExpenseCategory.business);
    final weekPayouts = weekExpenses.where((e) => e.category == ExpenseCategory.personalPayout);

    final stockDeployed = weekStockExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final businessCost = weekBusinessExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final payout = weekPayouts.fold<double>(0, (sum, e) => sum + e.amount);

    final recoveredFromSales = stockDeployed <= 0 ? 0.0 : (revenue < stockDeployed ? revenue : stockDeployed);
    final remainingToRecover = stockDeployed - recoveredFromSales;
    final netProfit = revenue - stockDeployed - businessCost - payout;
    final salesCount = weekSales.where((s) => s.isPaid).length;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(tr(ref, 'weekly_checkup')),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.primaryBlue.withValues(alpha: 0.2) : AppTheme.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${tr(ref, 'previous_week')} (${_formatDate(previousWeekStart)} - ${_formatDate(previousWeekEnd)})', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        _buildResumeRow(tr(ref, 'stock_purchased'), CurrencyUtils.format(stockDeployed), isDarkMode: isDarkMode),
                        _buildResumeRow(tr(ref, 'sales_revenue'), CurrencyUtils.format(revenue), isDarkMode: isDarkMode),
                        _buildResumeRow(tr(ref, 'business_expenses'), CurrencyUtils.format(businessCost), isDarkMode: isDarkMode),
                        _buildResumeRow(tr(ref, 'personal_payout'), CurrencyUtils.format(payout), isDarkMode: isDarkMode),
                        const SizedBox(height: 4),
                        _buildResumeRow(tr(ref, 'recovered_from_sales'), CurrencyUtils.format(recoveredFromSales), isHighlight: true, isDarkMode: isDarkMode),
                        _buildResumeRow(tr(ref, 'remaining_to_recover'), CurrencyUtils.format(remainingToRecover), isDarkMode: isDarkMode),
                        _buildResumeRow(tr(ref, 'realized_profit'), CurrencyUtils.format(netProfit), isHighlight: true, isDarkMode: isDarkMode),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(tr(ref, 'profit_distribution'), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: payoutController,
                    decoration: InputDecoration(
                      labelText: tr(ref, 'profit_payout'),
                      border: const OutlineInputBorder(),
                      suffixText: 'XAF',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode ? orangeColor.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: orangeColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${tr(ref, 'available_profit')}: ${CurrencyUtils.format(netProfit)}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: '${tr(ref, 'notes')} (${tr(ref, 'optional')})',
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr(ref, 'cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final payout = double.tryParse(payoutController.text) ?? 0;
                
                if (payout > netProfit) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr(ref, 'payout_exceed_profit'))),
                  );
                  return;
                }

                final checkup = WeeklyCheckup()
                  ..weekStartDate = previousWeekStart
                  ..weekEndDate = previousWeekEnd
                  ..totalStockPurchased = stockDeployed
                  ..totalSalesRevenue = revenue
                  ..totalBusinessExpenses = businessCost
                  ..totalPersonalPayouts = payout
                  ..capitalRecovered = recoveredFromSales
                  ..capitalRemaining = remainingToRecover
                  ..realizedProfit = netProfit
                  ..profitPayoutTaken = payout
                  ..profitReinjected = 0
                  ..salesCount = salesCount
                  ..notes = notesController.text;

                await ref.read(weeklyCheckupProvider.notifier).addCheckup(checkup);

                if (payout > 0) {
                  final payoutExpense = Expense()
                    ..description = tr(ref, 'weekly_payout_desc')
                    ..amount = payout
                    ..category = ExpenseCategory.personalPayout
                    ..notes = notesController.text;
                  await ref.read(expenseProvider.notifier).addExpense(payoutExpense);
                }

                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
              child: Text(tr(ref, 'complete_checkup')),
            ),
          ],
        ),
      ),
    );
  }
}
