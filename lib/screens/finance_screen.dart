import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../models/weekly_checkup.dart';
import '../providers/expense_provider.dart';
import '../providers/financial_stats_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/weekly_checkup_provider.dart';
import '../services/financial_stats_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localization.dart';
import '../utils/currency_utils.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(financialStatsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    final profitControlCards = isMobile && screenWidth < 400
      ? Column(
          children: [
            _buildStatCard(
              context,
              ref,
              tr(ref, 'available_profit'),
              CurrencyUtils.format(stats.totalAvailableProfit),
              Icons.savings_rounded,
              Colors.green,
              description: tr(ref, 'available_profit_desc'),
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              context,
              ref,
              tr(ref, 'salary_from_profit'),
              CurrencyUtils.format(stats.totalPayout),
              Icons.payments_rounded,
              AppTheme.primaryBlue,
              description: tr(ref, 'salary_from_profit_desc'),
            ),
          ],
        )
      : Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                ref,
                tr(ref, 'available_profit'),
                CurrencyUtils.format(stats.totalAvailableProfit),
                Icons.savings_rounded,
                Colors.green,
                description: tr(ref, 'available_profit_desc'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                ref,
                tr(ref, 'salary_from_profit'),
                CurrencyUtils.format(stats.totalPayout),
                Icons.payments_rounded,
                AppTheme.primaryBlue,
                description: tr(ref, 'salary_from_profit_desc'),
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
                      width: constraints.maxWidth > 600 ? (constraints
                          .maxWidth - 24) / 3 : constraints.maxWidth,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showQuickResume(
                              context,
                              ref,
                              stats: stats,
                            ),
                        icon: const Icon(Icons.summarize_outlined),
                        label: FittedBox(fit: BoxFit.scaleDown, child: Text(
                            tr(ref, 'quick_resume'))),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth > 600 ? (constraints
                          .maxWidth - 36) / 4 : constraints.maxWidth,
                      child: OutlinedButton.icon(
                        onPressed: () => _addInjection(context, ref),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: FittedBox(fit: BoxFit.scaleDown, child: Text(
                            tr(ref, 'inject_capital'))),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth > 600 ? (constraints
                          .maxWidth - 36) / 4 : constraints.maxWidth,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showWeeklyCheckupDialog(
                              context,
                              ref,
                              stats: stats,
                            ),
                        icon: const Icon(Icons.calendar_today_rounded),
                        label: FittedBox(fit: BoxFit.scaleDown, child: Text(
                            tr(ref, 'weekly_checkup'))),
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
                  width: screenWidth < 500 ? (screenWidth - 60) / 2 : 220,
                  child: _buildStatCard(
                    context,
                    ref,
                    tr(ref, 'capital_pool'),
                    CurrencyUtils.format(stats.capitalPool),
                    Icons.account_balance_wallet_rounded,
                    AppTheme.primaryBlue,
                    description: tr(ref, 'capital_pool_desc'),
                  ),
                ),
                SizedBox(
                  width: screenWidth < 500 ? (screenWidth - 60) / 2 : 220,
                  child: _buildStatCard(
                    context,
                    ref,
                    tr(ref, 'cash_capital'),
                    CurrencyUtils.format(stats.cashCapital),
                    Icons.payments_rounded,
                    Colors.green,
                    description: tr(ref, 'cash_capital_desc'),
                  ),
                ),
                SizedBox(
                  width: screenWidth < 500 ? (screenWidth - 60) / 2 : 220,
                  child: _buildStatCard(
                    context,
                    ref,
                    tr(ref, 'assets_capital'),
                    CurrencyUtils.format(stats.assetsCapital),
                    Icons.inventory_2_rounded,
                    Colors.orange,
                    description: tr(ref, 'assets_capital_desc'),
                  ),
                ),
                SizedBox(
                  width: screenWidth < 500 ? (screenWidth - 60) / 2 : 220,
                  child: _buildStatCard(
                    context,
                    ref,
                    tr(ref, 'stock_deployed'),
                    CurrencyUtils.format(stats.totalStockDeployed),
                    Icons.inventory_2_outlined,
                    AppTheme.primary,
                    description: tr(ref, 'stock_deployed_desc'),
                  ),
                ),
                SizedBox(
                  width: screenWidth < 500 ? (screenWidth - 60) / 2 : 220,
                  child: _buildStatCard(
                    context,
                    ref,
                    tr(ref, 'sales_count'),
                    '${stats.totalSalesCount}',
                    Icons.shopping_bag_rounded,
                    Colors.purple,
                    description: tr(ref, 'sales_count_desc'),
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
    final checkups = ref.watch(weeklyCheckupProvider);
    final allSales = ref.watch(saleProvider);
    final allExpenses = ref.watch(expenseProvider);
    final statsService = ref.watch(financialStatsServiceProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Grouping by Month
    final Map<String, List<WeeklyCheckup>> monthlyGroups = {};
    for (var checkup in checkups) {
      final monthKey = '${checkup.weekEndDate.year}-${checkup.weekEndDate.month.toString().padLeft(2, '0')}';
      monthlyGroups.putIfAbsent(monthKey, () => []).add(checkup);
    }

    final sortedMonths = monthlyGroups.keys.toList()..sort((a, b) => b.compareTo(a));

    if (checkups.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(ref, 'monthly_performance'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.slate200),
            ),
            child: Column(
              children: [
                Icon(Icons.history_rounded, size: 48, color: AppTheme.slate300),
                const SizedBox(height: 12),
                Text(
                  tr(ref, 'complete_first_checkup_desc'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.slate500),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(ref, 'monthly_performance'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        ...sortedMonths.map((monthKey) {
          final monthCheckups = monthlyGroups[monthKey]!;
          final dateParts = monthKey.split('-');
          final year = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final monthStart = DateTime(year, month, 1);
          final monthEnd = DateTime(year, month + 1, 0).isBefore(DateTime.now()) 
              ? DateTime(year, month + 1, 0, 23, 59, 59) 
              : DateTime.now();

          // Calculate Month Stats from raw data
          final monthSales = allSales.where((s) => 
            s.isPaid && 
            s.saleDate.isAfter(monthStart.subtract(const Duration(seconds: 1))) && 
            s.saleDate.isBefore(monthEnd.add(const Duration(seconds: 1))) && 
            s.deletedAt == null
          ).toList();
          
          final monthExpenses = allExpenses.where((e) => 
            e.expenseDate.isAfter(monthStart.subtract(const Duration(seconds: 1))) && 
            e.expenseDate.isBefore(monthEnd.add(const Duration(seconds: 1))) && 
            e.deletedAt == null
          ).toList();

          final monthSummary = statsService.calculatePeriod(
            sales: monthSales,
            expenses: monthExpenses,
          );

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(
                '${_getMonthName(month, ref)} $year',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${tr(ref, 'available_profit')}: ${CurrencyUtils.format(monthSummary.availableProfit)}',
                style: TextStyle(
                  color: monthSummary.availableProfit >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildResumeRow(tr(ref, 'total_revenue'), CurrencyUtils.format(monthSummary.revenue), isDarkMode: isDarkMode),
                      _buildResumeRow(tr(ref, 'stock_purchased'), CurrencyUtils.format(monthSummary.stockDeployed), isDarkMode: isDarkMode),
                      _buildResumeRow(tr(ref, 'business_expenses'), CurrencyUtils.format(monthSummary.businessCost), isDarkMode: isDarkMode),
                      _buildResumeRow(tr(ref, 'personal_payout'), CurrencyUtils.format(monthSummary.payout), isDarkMode: isDarkMode),
                      _buildResumeRow(tr(ref, 'realized_profit'), CurrencyUtils.format(monthSummary.realizedProfit), isDarkMode: isDarkMode),
                      _buildResumeRow(tr(ref, 'available_profit'), CurrencyUtils.format(monthSummary.availableProfit), isDarkMode: isDarkMode),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr(ref, 'weekly_checkups'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${monthCheckups.length} ${tr(ref, 'completed')}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...monthCheckups.map((checkup) => Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_formatDate(checkup.weekStartDate)} - ${_formatDate(checkup.weekEndDate)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(tr(ref, 'completed'), style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(child: _buildMiniStat(tr(ref, 'revenue'), CurrencyUtils.format(checkup.totalSalesRevenue))),
                                Expanded(child: _buildMiniStat(tr(ref, 'net_profit'), CurrencyUtils.format(checkup.realizedProfit), color: checkup.realizedProfit >= 0 ? Colors.green : Colors.red)),
                                Expanded(child: _buildMiniStat(tr(ref, 'payout'), CurrencyUtils.format(checkup.profitPayoutTaken))),
                              ],
                            ),
                            if (checkup.notes != null && checkup.notes!.isNotEmpty) ...[
                              const Divider(height: 16),
                              Text(checkup.notes!, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getMonthName(int month, WidgetRef ref) {
    final months = [
      tr(ref, 'january'),
      tr(ref, 'february'),
      tr(ref, 'march'),
      tr(ref, 'april'),
      tr(ref, 'may'),
      tr(ref, 'june'),
      tr(ref, 'july'),
      tr(ref, 'august'),
      tr(ref, 'september'),
      tr(ref, 'october'),
      tr(ref, 'november'),
      tr(ref, 'december'),
    ];
    return months[month - 1];
  }

  Widget _buildMiniStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppTheme.slate400, fontSize: 11),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
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
          _buildSummaryRow(tr(ref, 'revenue'), CurrencyUtils.format(revenue), tooltip: tr(ref, 'revenue_help')),
          _buildSummaryRow(tr(ref, 'stock_deployed'), CurrencyUtils.format(stockDeployed), tooltip: tr(ref, 'stock_cost_help')),
          _buildSummaryRow(tr(ref, 'business_expenses'), CurrencyUtils.format(businessExpenses), tooltip: tr(ref, 'business_expenses_help')),
          _buildSummaryRow(tr(ref, 'owner_salary'), CurrencyUtils.format(personalPayouts), tooltip: tr(ref, 'owner_salary_help')),
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
          Expanded(
            child: Tooltip(
              message: tooltip ?? label,
              child: Text(label, style: TextStyle(color: AppTheme.slate400), overflow: TextOverflow.ellipsis),
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

  Widget _buildStatCard(BuildContext context, WidgetRef ref, String title, String value, IconData icon, Color color, {String? description}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
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

    if (description != null) {
      return Tooltip(
        message: description,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.slate900.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        child: card,
      );
    }
    return card;
  }

  Widget _buildInjectionsList(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);
    final injections = expenses
        .where((e) => e.category == ExpenseCategory.capitalInjection)
        .toList()
      ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
        
    if (injections.isEmpty) {
      return const SizedBox.shrink();
    }
    
    injections.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr(ref, 'capital_injections'), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...injections.map((i) {
          final description = i.description == 'Capital Injection' 
              ? tr(ref, 'capital_injection_title') 
              : i.description;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.add_circle_outline_rounded),
            title: Text(description),
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
    final description = injection.description == 'Capital Injection' 
        ? tr(ref, 'capital_injection_title') 
        : injection.description;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'capital_injection_details')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(tr(ref, 'description'), description),
            _buildDetailRow(tr(ref, 'amount'), CurrencyUtils.format(injection.amount)),
            _buildDetailRow(tr(ref, 'date'), '${injection.expenseDate.day}/${injection.expenseDate.month}/${injection.expenseDate.year}'),
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
    DateTime selectedDate = DateTime.now();
    
    final result = await showDialog<Expense>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: tr(ref, 'date'),
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                ),
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
                  expenseDate: selectedDate,
                ),
              ),
              child: Text(tr(ref, 'add')),
            ),
          ],
        ),
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
                    _buildResumeRow(tr(ref, 'available_profit'), CurrencyUtils.format(stats.totalAvailableProfit), isDarkMode: isDarkMode),
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

  void _showFinancialLogicDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enterprise Financial Logic'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How your data is calculated:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('• Revenue: Total from all paid sales (Direct or Delivery).'),
              Text('• Stock Deployed: Total cost of purchasing items in your inventory.'),
              Text('• Business Expenses: Operational costs (rent, transport, packaging).'),
              Text('• Realized Profit: (Revenue - Stock Deployed). This is your gross business performance.'),
              Text('• Available Profit: (Realized Profit - Business Expenses - Payouts). This is your actual spendable cash.'),
              SizedBox(height: 16),
              Text('Capital Definitions:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Cash Capital: Total Injections + Sales - (Expenses + Payouts). This is what you have in hand.'),
              Text('• Assets Capital: The value of all items currently in your stock.'),
              Text('• Capital Pool: Cash Capital + Assets Capital. Your total business worth.'),
              SizedBox(height: 16),
              Text('Consistency Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('The app syncs automatically every 3 minutes. On mobile, swipe down to refresh manually. The database is the master source; local changes are updated to match cloud state whenever you pull.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Understood')),
        ],
      ),
    );
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
    DateTime selectedWeekEnd = WeeklyCheckup.getWeekStartDate(now).subtract(const Duration(days: 1));
    DateTime selectedWeekStart = WeeklyCheckup.getWeekStartDate(selectedWeekEnd);

    return await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final rawSales = ref.read(saleProvider);
          final allExpenses = ref.read(expenseProvider);
          final statsService = ref.read(financialStatsServiceProvider);

          final weekSales = rawSales.where((s) =>
            (s.saleDate.isAfter(selectedWeekStart) || s.saleDate.isAtSameMomentAs(selectedWeekStart)) &&
            s.saleDate.isBefore(selectedWeekEnd.add(const Duration(days: 1))) &&
            s.deletedAt == null
          ).toList();

          final weekExpenses = allExpenses.where((e) =>
            (e.expenseDate.isAfter(selectedWeekStart) || e.expenseDate.isAtSameMomentAs(selectedWeekStart)) &&
            e.expenseDate.isBefore(selectedWeekEnd.add(const Duration(days: 1)))
          ).toList();

          final summary = statsService.calculatePeriod(
            sales: weekSales,
            expenses: weekExpenses,
          );

          return AlertDialog(
            title: Text(tr(ref, 'weekly_checkup')),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedWeekEnd,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedWeekEnd = WeeklyCheckup.getWeekEndDate(picked);
                            selectedWeekStart = WeeklyCheckup.getWeekStartDate(selectedWeekEnd);
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: tr(ref, 'week_end_date'),
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text('${_formatDate(selectedWeekStart)} - ${_formatDate(selectedWeekEnd)}'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppTheme.primaryBlue.withValues(alpha: 0.2) : AppTheme.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${tr(ref, 'summary')} (${_formatDate(selectedWeekStart)} - ${_formatDate(selectedWeekEnd)})', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 8),
                          _buildResumeRow(tr(ref, 'stock_purchased'), CurrencyUtils.format(summary.stockDeployed), isDarkMode: isDarkMode),
                          _buildResumeRow(tr(ref, 'sales_revenue'), CurrencyUtils.format(summary.revenue), isDarkMode: isDarkMode),
                          _buildResumeRow(tr(ref, 'business_expenses'), CurrencyUtils.format(summary.businessCost), isDarkMode: isDarkMode),
                          _buildResumeRow(tr(ref, 'personal_payout'), CurrencyUtils.format(summary.payout), isDarkMode: isDarkMode),
                          const SizedBox(height: 4),
          _buildResumeRow(tr(ref, 'recovered_from_sales'), CurrencyUtils.format(summary.recoveredFromSales), isDarkMode: isDarkMode),
          _buildResumeRow(tr(ref, 'remaining_to_recover'), CurrencyUtils.format(summary.remainingToRecover), isDarkMode: isDarkMode),
          _buildResumeRow(tr(ref, 'realized_profit'), CurrencyUtils.format(summary.realizedProfit), isHighlight: true, isDarkMode: isDarkMode),
          _buildResumeRow(tr(ref, 'available_profit'), CurrencyUtils.format(summary.availableProfit), isDarkMode: isDarkMode),
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
                            '${tr(ref, 'available_profit')}: ${CurrencyUtils.format(summary.availableProfit - (double.tryParse(payoutController.text) ?? 0))}',
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
                final requestedPayout = double.tryParse(payoutController.text) ?? 0;
                
                if (requestedPayout > summary.availableProfit) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr(ref, 'payout_exceed_profit'))),
                  );
                  return;
                }

                final checkup = WeeklyCheckup()
                  ..weekStartDate = selectedWeekStart
                  ..weekEndDate = selectedWeekEnd
                  ..totalStockPurchased = summary.stockDeployed
                  ..totalSalesRevenue = summary.revenue
                  ..totalBusinessExpenses = summary.businessCost
                  ..totalPersonalPayouts = summary.payout + requestedPayout
                  ..capitalRecovered = summary.recoveredFromSales
                  ..capitalRemaining = summary.remainingToRecover
                  ..realizedProfit = summary.realizedProfit
                  ..profitPayoutTaken = requestedPayout
                  ..profitReinjected = 0
                  ..salesCount = summary.salesCount
                  ..checkupDate = selectedWeekEnd // Sync checkup date with the end of the selected week
                  ..notes = notesController.text;

                await ref.read(weeklyCheckupProvider.notifier).addCheckup(checkup);

                if (requestedPayout > 0) {
                  final payoutExpense = Expense()
                    ..description = tr(ref, 'weekly_payout_desc')
                    ..amount = requestedPayout
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
        );
      },
    ),
  );
}
}
