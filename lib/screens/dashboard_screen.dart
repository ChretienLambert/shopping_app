import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weekly_checkup.dart';
import '../models/expense.dart';
import '../repositories/weekly_checkup_repository.dart';
import '../providers/expense_provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/financial_stats_provider.dart';
import '../services/financial_stats_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localization.dart';
import '../utils/currency_utils.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  WeeklyCheckup? _lastWeek;
  final _checkupRepo = WeeklyCheckupRepository();
  bool _showWeekly = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await ref.read(saleProvider.notifier).loadSales();
    await ref.read(expenseProvider.notifier).loadExpenses();
    await ref.read(productProvider.notifier).loadProducts();
    
    final reports = await _checkupRepo.getAll();
    if (mounted) {
      setState(() {
        _lastWeek = reports.isNotEmpty ? reports.first : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(financialStatsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          children: [
            // Top Welcome Header
            if (!isMobile) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(ref, 'financial_health'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        tr(ref, 'real_time_performance'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  _buildToggle(),
                ],
              ),
              const SizedBox(height: 32),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr(ref, 'financial_health'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  _buildToggle(),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Financial Resume Section
            _buildFinancialResumeSection(stats, isMobile),
            const SizedBox(height: 24),

            // KPI Grid
            GridView.count(
              crossAxisCount: screenWidth > 1200 ? 4 : (screenWidth > 600 ? 2 : 1),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isMobile ? (screenWidth < 350 ? 2.5 : 3.5) : (screenWidth > 1200 ? 2.5 : 1.8),
              children: [
                _buildModernKPI(
                  tr(ref, 'total_revenue'), 
                  CurrencyUtils.format(_showWeekly ? stats.revenue : stats.totalRevenue), 
                  Icons.arrow_upward_rounded,
                  isDarkMode ? AppTheme.chart5 : Colors.green,
                  subtitle: _showWeekly ? tr(ref, 'this_week') : tr(ref, 'all_time'),
                  description: _showWeekly ? 'Total income generated from all paid sales this week.' : 'Total income generated from all paid sales since the beginning.',
                ),
                _buildModernKPI(
                  tr(ref, 'sales_count'), 
                  '${_showWeekly ? stats.salesCount : stats.totalSalesCount} ${tr(ref, 'unit_sales')}', 
                  Icons.shopping_cart_outlined,
                  isDarkMode ? AppTheme.chart4 : Colors.orange,
                  subtitle: stats.pendingDeliveries > 0 ? '${stats.pendingDeliveries} ${tr(ref, 'pending')}' : (_showWeekly ? tr(ref, 'this_week') : tr(ref, 'all_time')),
                  description: _showWeekly ? 'Total number of sales completed this week.' : 'Total number of sales completed since the beginning.',
                ),
                _buildModernKPI(
                  tr(ref, 'stock_deployed'), 
                  CurrencyUtils.format(_showWeekly ? stats.stockDeployed : stats.totalStockDeployed), 
                  Icons.inventory_2_outlined,
                  AppTheme.primary,
                  subtitle: _showWeekly ? tr(ref, 'this_week') : tr(ref, 'all_time'),
                  description: _showWeekly ? 'Total cost of stock inventory purchased this week.' : 'Total cost of stock inventory purchased since the beginning.',
                ),
                _buildModernKPI(
                  tr(ref, 'available_profit'), 
                  CurrencyUtils.format(_showWeekly ? stats.availableProfit : stats.totalAvailableProfit), 
                  Icons.account_balance_wallet_outlined,
                  AppTheme.primaryBlue,
                  subtitle: _showWeekly ? tr(ref, 'this_week') : tr(ref, 'all_time'),
                  description: _showWeekly ? 'Liquid profit available from this week\'s operations.' : 'Total liquid profit available since the beginning.',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Performance Section
            if (isMobile) ...[
              Text(tr(ref, 'capital_coverage'), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _buildCoverageCard(stats, isDarkMode),
              if (_lastWeek != null) ...[
                const SizedBox(height: 24),
                Text(tr(ref, 'previous_week'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _buildLastWeekSummary(isDarkMode),
              ],
            ] else 
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(ref, 'capital_coverage'), style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 16),
                        _buildCoverageCard(stats, isDarkMode),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  if (_lastWeek != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr(ref, 'previous_week'), style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          _buildLastWeekSummary(isDarkMode),
                        ],
                      ),
                    ),
                ],
              ),
            
            const SizedBox(height: 32),
            if (stats.lowStock > 0) ...[
              _buildLowStockAlert(stats),
              const SizedBox(height: 32),
            ],
            Text(tr(ref, 'recent_activity'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildRecentActivityList(stats.recentActivity),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(tr(ref, 'this_week'), _showWeekly, () => setState(() => _showWeekly = true)),
          _buildToggleButton(tr(ref, 'all_time'), !_showWeekly, () => setState(() => _showWeekly = false)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialResumeSection(FinancialStats stats, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr(ref, 'financial_resume'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              _buildResumeRow(tr(ref, 'capital_overview'), [
                {'label': tr(ref, 'capital_pool'), 'value': stats.capitalPool},
                {'label': tr(ref, 'cash_capital'), 'value': stats.cashCapital},
                {'label': tr(ref, 'assets_capital'), 'value': stats.assetsCapital},
              ]),
              const Divider(height: 24),
              _buildResumeRow(tr(ref, 'profit_analysis'), [
                {'label': tr(ref, 'sales_count'), 'value': _showWeekly ? stats.salesCount : stats.totalSalesCount, 'isRaw': true},
                {'label': tr(ref, 'revenue'), 'value': _showWeekly ? stats.revenue : stats.totalRevenue},
                {'label': tr(ref, 'stock_cost'), 'value': _showWeekly ? stats.stockDeployed : stats.totalStockDeployed},
                {'label': tr(ref, 'operational_expenses'), 'value': _showWeekly ? stats.businessCost : stats.totalBusinessCost},
                {'label': tr(ref, 'net_profit'), 'value': _showWeekly ? stats.netProfit : stats.totalNetProfit},
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoverageCard(FinancialStats stats, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          _buildProgressRow(tr(ref, 'stock_deployed'), _showWeekly ? stats.stockDeployed : stats.totalStockDeployed, isDarkMode ? AppTheme.slate400 : Colors.grey),
          const SizedBox(height: 12),
          _buildProgressRow(tr(ref, 'recovered'), _showWeekly ? stats.recoveredFromSales : stats.totalRecoveredFromSales, isDarkMode ? AppTheme.chart5 : Colors.green),
          const SizedBox(height: 24),
          Tooltip(
            message: tr(ref, 'capital_energy_desc'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _showWeekly ? stats.coverage : stats.totalCoverage,
                minHeight: 12,
                backgroundColor: isDarkMode ? AppTheme.slate800 : AppTheme.secondary,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${((_showWeekly ? stats.coverage : stats.totalCoverage) * 100).toStringAsFixed(1)}% ${tr(ref, 'recovered')}', 
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              Text('${tr(ref, 'remaining')}: ${CurrencyUtils.format(_showWeekly ? stats.remainingToRecover : stats.totalRemainingToRecover)}',
                style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumeRow(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Tooltip(
                      message: item['label'],
                      child: Text(item['label'], style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item['isRaw'] == true 
                      ? item['value'].toString() 
                      : CurrencyUtils.format(item['value']), 
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildModernKPI(String label, String value, IconData icon, Color color, {String? subtitle, String? description}) {
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setState) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final Widget kpi = MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: isHovered ? color.withValues(alpha: 0.5) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isHovered ? 0.1 : 0.05),
                  blurRadius: isHovered ? 15 : 10,
                  offset: Offset(0, isHovered ? 6 : 4),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDarkMode ? (isHovered ? 0.3 : 0.2) : (isHovered ? 0.2 : 0.1)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(label, 
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
                          maxLines: 1,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(value, 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                          maxLines: 1,
                        ),
                      ),
                      if (subtitle != null)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(subtitle, 
                              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        if (description != null) {
          return Tooltip(
            message: description,
            child: kpi,
          );
        }
        return kpi;
      }
    );
  }

  Widget _buildProgressRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label, 
            style: Theme.of(context).textTheme.bodyMedium, 
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(CurrencyUtils.format(amount), style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLastWeekSummary(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(tr(ref, 'week_summary'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _summaryItem(tr(ref, 'revenue'), CurrencyUtils.format(_lastWeek!.totalSalesRevenue)),
          const Divider(color: Colors.white24, height: 24),
          _summaryItem(tr(ref, 'profit'), CurrencyUtils.format(_lastWeek!.realizedProfit)),
          const Divider(color: Colors.white24, height: 24),
          _summaryItem(tr(ref, 'sales_count'), _lastWeek!.salesCount.toString()),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildLowStockAlert(FinancialStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.lowStock} ${tr(ref, 'low_stock_items')}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange),
                ),
                Text(
                  tr(ref, 'restock_suggestion'),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
               // Navigation to products screen or similar
            },
            child: Text(tr(ref, 'view'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList(List<Map<String, dynamic>> activities) {
    if (activities.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(tr(ref, 'no_activity'), style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: activities.take(5).map((activity) {
          final isSale = activity['type'] == 'sale';
          return _ActivityListTile(activity: activity, isSale: isSale);
        }).toList(),
      ),
    );
  }
}

class _ActivityListTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> activity;
  final bool isSale;

  const _ActivityListTile({required this.activity, required this.isSale});

  @override
  ConsumerState<_ActivityListTile> createState() => _ActivityListTileState();
}

class _ActivityListTileState extends ConsumerState<_ActivityListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final positiveColor = isDarkMode ? AppTheme.chart5 : Colors.green;
    final negativeColor = isDarkMode ? AppTheme.chart3 : Colors.red;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _isHovered ? AppTheme.primaryBlue.withValues(alpha: isDarkMode ? 0.15 : 0.05) : Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: isDarkMode ? AppTheme.slate700 : AppTheme.secondary,
            child: Icon(
              widget.isSale ? Icons.shopping_bag_outlined : Icons.receipt_long_outlined,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            widget.isSale 
              ? tr(ref, 'sale') 
              : (widget.activity['label'].toString().contains('Stock purchase') 
                  ? widget.activity['label'].toString().replaceFirst('Stock purchase', tr(ref, 'stock_purchased'))
                  : (widget.activity['label'] == 'Capital Injection' ? tr(ref, 'capital_injection_title') : widget.activity['label'].toString())),
            style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
          ),
          subtitle: Text(
            widget.isSale 
              ? '${(widget.activity['date'] as DateTime).day}/${(widget.activity['date'] as DateTime).month}/${(widget.activity['date'] as DateTime).year} • ${(widget.activity['date'] as DateTime).hour.toString().padLeft(2, '0')}:${(widget.activity['date'] as DateTime).minute.toString().padLeft(2, '0')}'
              : '${(widget.activity['date'] as DateTime).day}/${(widget.activity['date'] as DateTime).month}/${(widget.activity['date'] as DateTime).year}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          trailing: Text(
            CurrencyUtils.format((widget.activity['amount'] as num).toDouble()),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.isSale ? positiveColor : negativeColor,
            ),
          ),
          onTap: () {
             // Future: Navigate to detail
          },
        ),
      ),
    );
  }
}
