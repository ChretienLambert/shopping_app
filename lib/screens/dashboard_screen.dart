import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/sale_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/product_provider.dart';
import '../providers/customer_provider.dart';
import '../theme/app_theme.dart';
import '../models/expense.dart';
import '../utils/currency_utils.dart';

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
    await ref.read(customerProvider.notifier).loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final sales = ref.watch(saleProvider);
    final expenses = ref.watch(expenseProvider);
    final customers = ref.watch(customerProvider);

    // Calculate low stock products
    final lowStockProducts = products.where((p) => p.stockQuantity < 10).toList();
    
    // Calculate top selling products (by stock sold - this is a simplified metric)
    final topProducts = products.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder(
        future: Future.wait([
          ref.read(saleProvider.notifier).getTotalSales(),
          ref.read(saleProvider.notifier).getSalesToday(),
          ref.read(saleProvider.notifier).getSalesThisMonth(),
          ref.read(expenseProvider.notifier).getTotalExpenses(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalSales = snapshot.data![0];
          final salesToday = snapshot.data![1];
          final salesThisMonth = snapshot.data![2];
          final totalExpenses = snapshot.data![3];
          final netProfit = totalSales - totalExpenses;

          final isSmallScreen = MediaQuery.of(context).size.width < 1200;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildSummaryCards(
                    totalSales,
                    totalExpenses,
                    netProfit,
                    salesToday,
                    salesThisMonth,
                  ),
                  const SizedBox(height: 32),
                  if (isSmallScreen) ...[
                    _buildProfitChart(totalSales, totalExpenses),
                    const SizedBox(height: 24),
                    _buildSalesChart(sales),
                    const SizedBox(height: 24),
                    _buildExpenseChart(expenses),
                    const SizedBox(height: 24),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildProfitChart(totalSales, totalExpenses),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildSalesChart(sales),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildExpenseChart(expenses),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildTopProducts(topProducts),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildQuickStats(products.length, customers.length, sales.length, expenses.length),
                  const SizedBox(height: 24),
                  if (lowStockProducts.isNotEmpty) _buildLowStockAlert(lowStockProducts),
                  const SizedBox(height: 24),
                  _buildRecentActivity(sales, expenses),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // _buildHeader removed because it is handled by main_screen header

  Widget _buildSummaryCards(
    double totalSales,
    double totalExpenses,
    double netProfit,
    double salesToday,
    double salesThisMonth,
  ) {
    String formatXAF(double value) => CurrencyUtils.format(value);
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Sales',
                formatXAF(totalSales),
                Icons.trending_up,
                [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                'Overall revenue',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Total Expenses',
                formatXAF(totalExpenses),
                Icons.receipt_long,
                [const Color(0xFF475569), const Color(0xFF334155)],
                'Operational costs',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Net Profit',
                formatXAF(netProfit),
                Icons.account_balance_wallet,
                netProfit >= 0 
                  ? [const Color(0xFFB76E79), const Color(0xFFC9868E)]
                  : [const Color(0xFFEF4444), const Color(0xFFF87171)],
                'Your take-home',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Sales Today',
                formatXAF(salesToday),
                Icons.today,
                [const Color(0xFF64748B), const Color(0xFF475569)],
                'Last 24 hours',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, List<Color> colors, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const Icon(Icons.more_horiz, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitChart(double sales, double expenses) {
    String formatXAF(double value) => CurrencyUtils.formatShort(value);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: sales,
                      title: 'Sales\n${formatXAF(sales)}',
                      color: AppTheme.chart2,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: expenses,
                      title: 'Expenses\n${formatXAF(expenses)}',
                      color: AppTheme.destructive,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(int productCount, int customerCount, int salesCount, int expenseCount) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Products', productCount.toString(), Icons.inventory_2),
                ),
                Expanded(
                  child: _buildStatItem('Customers', customerCount.toString(), Icons.people),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Sales', salesCount.toString(), Icons.receipt_long),
                ),
                Expanded(
                  child: _buildStatItem('Expenses', expenseCount.toString(), Icons.receipt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart(List sales) {
    final now = DateTime.now();
    final salesByDay = <String, double>{};
    
    // Initialize last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateFormat('EEE').format(date);
      salesByDay[key] = 0.0;
    }
    
    // Aggregate sales by day
    for (var sale in sales) {
      final diff = now.difference(sale.saleDate).inDays;
      if (diff <= 6 && diff >= 0) {
        final key = DateFormat('EEE').format(sale.saleDate);
        salesByDay[key] = (salesByDay[key] ?? 0.0) + sale.totalAmount;
      }
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Over Time',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: salesByDay.values.isEmpty ? 100 : salesByDay.values.reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = salesByDay.keys.toList();
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[value.toInt()],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.mutedForeground,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: salesByDay.entries.map((entry) {
                    final index = salesByDay.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: AppTheme.chart2,
                          width: 20,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseChart(List expenses) {
    final expensesByCategory = <ExpenseCategory, double>{};
    for (var category in ExpenseCategory.values) {
      expensesByCategory[category] = 0.0;
    }
    
    for (var expense in expenses) {
      expensesByCategory[expense.category] = (expensesByCategory[expense.category] ?? 0.0) + expense.amount;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expenses by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: expensesByCategory.values.isEmpty ? 100 : expensesByCategory.values.reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final categories = ExpenseCategory.values;
                          if (value.toInt() >= 0 && value.toInt() < categories.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getCategoryShortName(categories[value.toInt()]),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.mutedForeground,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: ExpenseCategory.values.map((category) {
                    final index = ExpenseCategory.values.indexOf(category);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: expensesByCategory[category] ?? 0.0,
                          color: _getCategoryColor(category),
                          width: 16,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts(List products) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Products',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...products.take(5).map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.inventory_2, size: 20, color: AppTheme.secondaryForeground),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            CurrencyUtils.format(product.price),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Stock: ${product.stockQuantity}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: product.stockQuantity < 10 ? AppTheme.destructive : AppTheme.chart4,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlert(List lowStockProducts) {
    return Card(
      elevation: 2,
      color: AppTheme.destructive.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: AppTheme.destructive),
                const SizedBox(width: 8),
                Text(
                  'Low Stock Alert',
                  style: TextStyle(
                    color: AppTheme.destructive,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...lowStockProducts.take(5).map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.destructive,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${product.stockQuantity} left',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(List sales, List expenses) {
    final allTransactions = [
      ...sales.map((s) => {'type': 'sale', 'data': s, 'date': s.saleDate}),
      ...expenses.map((e) => {'type': 'expense', 'data': e, 'date': e.expenseDate}),
    ];
    
    allTransactions.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    final recent = allTransactions.take(5).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (recent.isEmpty)
              Text(
                'No recent activity',
                style: TextStyle(color: AppTheme.mutedForeground),
              )
            else
              ...recent.map((item) {
                if (item['type'] == 'sale') {
                  final sale = item['data'] as dynamic;
                  return _buildActivityItem(
                    icon: Icons.sell,
                    iconColor: AppTheme.chart4,
                    title: 'Sale',
                    subtitle: CurrencyUtils.format(sale.totalAmount),
                    date: _formatDate(sale.saleDate),
                  );
                } else {
                  final expense = item['data'] as Expense;
                  return _buildActivityItem(
                    icon: Icons.shopping_cart,
                    iconColor: AppTheme.destructive,
                    title: expense.description,
                    subtitle: '-${CurrencyUtils.format(expense.amount)}',
                    date: _formatDate(expense.expenseDate),
                  );
                }
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryShortName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.socialMedia:
        return 'Social';
      case ExpenseCategory.stand:
        return 'Stand';
      case ExpenseCategory.transportation:
        return 'Trans';
      case ExpenseCategory.supplies:
        return 'Supply';
      case ExpenseCategory.utilities:
        return 'Util';
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.marketing:
        return 'Mkt';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.socialMedia:
        return AppTheme.chart3;
      case ExpenseCategory.stand:
        return AppTheme.chart5;
      case ExpenseCategory.transportation:
        return AppTheme.chart1;
      case ExpenseCategory.supplies:
        return AppTheme.chart2;
      case ExpenseCategory.utilities:
        return AppTheme.chart4;
      case ExpenseCategory.rent:
        return AppTheme.chart3;
      case ExpenseCategory.marketing:
        return AppTheme.chart5;
      case ExpenseCategory.other:
        return AppTheme.mutedForeground;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return DateFormat('MMM d').format(date);
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
