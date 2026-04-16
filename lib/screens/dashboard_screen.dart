import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localization.dart';
import '../utils/currency_utils.dart';
import 'finance_screen.dart';
import 'sales_screen.dart';
import 'expenses_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await ref.read(saleProvider.notifier).loadSales();
    await ref.read(expenseProvider.notifier).loadExpenses();
    await ref.read(productProvider.notifier).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final sales = ref.watch(saleProvider);
    final expenses = ref.watch(expenseProvider);
    final products = ref.watch(productProvider);

    final revenue = sales.fold<double>(0, (sum, s) => sum + s.totalAmount);
    final stockDeployed = expenses
        .where((e) => e.category == ExpenseCategory.stock)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final businessCost = expenses
        .where((e) => e.category == ExpenseCategory.business)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final payout = expenses
        .where((e) => e.category == ExpenseCategory.personalPayout)
        .fold<double>(0, (sum, e) => sum + e.amount);
    
    // Recovered from sales: sales revenue up to the amount of stock deployed
    final recoveredFromSales = revenue < stockDeployed ? revenue : stockDeployed;
    final remainingToRecover = stockDeployed - recoveredFromSales;
    
    // Profit only starts after stock deployed is fully recovered
    final salesAfterRecovery = revenue - recoveredFromSales;
    final availableProfit = (salesAfterRecovery - businessCost - payout).clamp(0, double.infinity).toDouble();
    
    // Coverage: % of stock deployed recovered from sales
    final coverage = stockDeployed <= 0 ? 0.0 : (recoveredFromSales / stockDeployed).clamp(0, 1).toDouble();
    final pendingDeliveries = sales.where((s) => s.isDelivery && !s.isPaid).length;
    final lowStock = products.where((p) => p.stockQuantity < 10).length;

    final recent = [
      ...sales.map((s) => {'date': s.saleDate, 'label': 'Sale', 'amount': s.totalAmount, 'type': 'sale', 'id': s.id}),
      ...expenses.map((e) => {'date': e.expenseDate, 'label': e.description, 'amount': -e.amount, 'type': 'expense', 'id': e.id}),
    ]..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Quick Actions Section (Top)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showQuickResume(availableProfit, coverage, revenue, stockDeployed, recoveredFromSales, remainingToRecover),
                    icon: const Icon(Icons.summarize_outlined),
                    label: Text(tr(ref, 'quick_resume')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceScreen())),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: Text(tr(ref, 'inject_capital')),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Text(
              tr(ref, 'financial_health'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _kpiCard(tr(ref, 'total_revenue'), CurrencyUtils.format(revenue), Icons.trending_up_rounded),
                _kpiCard(tr(ref, 'stock_deployed'), CurrencyUtils.format(stockDeployed), Icons.inventory_2_rounded),
                _kpiCard(tr(ref, 'available_profit'), CurrencyUtils.format(availableProfit), Icons.savings_rounded),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr(ref, 'capital_coverage'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('${tr(ref, 'stock_deployed')}: ${CurrencyUtils.format(stockDeployed)}'),
                  Text('${tr(ref, 'recovered_from_sales')}: ${CurrencyUtils.format(recoveredFromSales)}'),
                  Text('${tr(ref, 'remaining_to_recover')}: ${CurrencyUtils.format(remainingToRecover)}'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: coverage),
                  const SizedBox(height: 6),
                  Text('${(coverage * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _simpleCard(
                    tr(ref, 'pending_deliveries'),
                    pendingDeliveries.toString(),
                    Icons.local_shipping_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _simpleCard(
                    tr(ref, 'low_stock_items'),
                    lowStock.toString(),
                    Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tr(ref, 'recent_activity'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(tr(ref, 'no_activity')),
              )
            else
              ...recent.take(8).map(
                    (r) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(r['label'].toString()),
                      subtitle: Text((r['date'] as DateTime).toLocal().toString().split('.').first),
                      trailing: Text(
                        CurrencyUtils.format((r['amount'] as num).toDouble()),
                        style: TextStyle(
                          color: (r['amount'] as num) >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => _navigateToDetail(r['type'] as String, r['id'] as int),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(String type, int id) {
    // Navigate to appropriate screen and select the item
    // For now, navigate to the screen - detailed selection would require additional state management
    if (type == 'sale') {
      // Navigate to sales screen
      // Note: To highlight specific sale, you'd need to pass the sale ID to the sales screen
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesScreen()));
    } else if (type == 'expense') {
      // Navigate to expenses screen
      // Note: To highlight specific expense, you'd need to pass the expense ID to the expenses screen
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesScreen()));
    }
  }

  void _showQuickResume(double profit, double coverage, double revenue, double stockDeployed, double recoveredFromSales, double remainingToRecover) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'quick_resume')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${tr(ref, 'available_profit')}: ${CurrencyUtils.format(profit)}'),
            const SizedBox(height: 8),
            Text('${tr(ref, 'stock_deployed')}: ${CurrencyUtils.format(stockDeployed)}'),
            Text('${tr(ref, 'recovered_from_sales')}: ${CurrencyUtils.format(recoveredFromSales)}'),
            Text('${tr(ref, 'remaining_to_recover')}: ${CurrencyUtils.format(remainingToRecover)}'),
            Text('${tr(ref, 'capital_coverage')}: ${(coverage * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('${tr(ref, 'total_revenue')}: ${CurrencyUtils.format(revenue)}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr(ref, 'close'))),
        ],
      ),
    );
  }

  Widget _kpiCard(String title, String value, IconData icon) {
    return SizedBox(
      width: 230,
      child: _simpleCard(title, value, icon),
    );
  }

  Widget _simpleCard(String title, String value, IconData icon) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 20),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: AppTheme.slate500, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
