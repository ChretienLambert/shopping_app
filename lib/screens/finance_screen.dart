import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/weekly_checkup.dart';
import '../providers/expense_provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/weekly_checkup_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localization.dart';
import '../utils/currency_utils.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  static const _initialCapitalKey = 'finance_initial_capital';
  static const _injectionsKey = 'finance_capital_injections';

  double _initialCapital = 0;
  List<_CapitalInjection> _injections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFinanceSettings();
  }

  Future<void> _loadFinanceSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_injectionsKey) ?? [];
    setState(() {
      _initialCapital = prefs.getDouble(_initialCapitalKey) ?? 0;
      _injections = raw
          .map((e) => _CapitalInjection.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
      _loading = false;
    });
  }

  Future<void> _saveFinanceSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_initialCapitalKey, _initialCapital);
    await prefs.setStringList(
      _injectionsKey,
      _injections.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sales = ref.watch(saleProvider);
    final expenses = ref.watch(expenseProvider);
    final products = ref.watch(productProvider);

    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalRevenue = sales.fold(0.0, (sum, item) => sum + item.totalAmount);
    final stockExpenses = expenses
        .where((e) => e.category == ExpenseCategory.stock)
        .fold(0.0, (sum, e) => sum + e.amount);
    final businessExpenses = expenses
        .where((e) => e.category == ExpenseCategory.business)
        .fold(0.0, (sum, e) => sum + e.amount);
    final personalPayouts = expenses
        .where((e) => e.category == ExpenseCategory.personalPayout)
        .fold(0.0, (sum, e) => sum + e.amount);

    final injectedCapital = _injections.fold(0.0, (sum, i) => sum + i.amount);
    final capitalPool = _initialCapital + injectedCapital;
    
    // Profit is NOT automatically reinjected - only during weekly checkup
    // Capital recovery only happens when user chooses to reinject profit in checkup
    final capitalRecovered = 0.0; // No automatic recovery from sales
    final remainingCapital = capitalPool - stockExpenses;
    final capitalCompletion = capitalPool <= 0 ? 0.0 : max(0.0, min(1.0, (capitalPool - remainingCapital) / capitalPool));
    
    // Profit calculation: Sales - Stock - Business - Personal (no automatic capital refill)
    final realizedProfit = max<double>(0, totalRevenue - stockExpenses) - businessExpenses - personalPayouts;
    
    final grossMargin = totalRevenue <= 0 ? 0.0 : ((totalRevenue - stockExpenses) / totalRevenue);
    final operatingMargin = totalRevenue <= 0 ? 0.0 : (realizedProfit / totalRevenue);
    final payoutRatio = realizedProfit <= 0 ? 0.0 : (personalPayouts / (realizedProfit + personalPayouts));
    final businessCostRatio = totalRevenue <= 0 ? 0.0 : (businessExpenses / totalRevenue);
    final assetsCapital = products.fold<double>(
      0,
      (sum, p) => sum + (p.purchasePrice * p.stockQuantity),
    );
    // Cash capital = Initial capital + injections - stock spent + sales revenue - expenses
    final cashCapital = max<double>(
      0,
      capitalPool - stockExpenses + totalRevenue - businessExpenses - personalPayouts,
    );
    final profitAvailableToSpend = max<double>(0, realizedProfit);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions Section (Top)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showQuickResume(
                      capitalCompletion: capitalCompletion,
                      remainingCapital: remainingCapital,
                      realizedProfit: realizedProfit,
                    ),
                    icon: const Icon(Icons.summarize_outlined),
                    label: Text(tr(ref, 'quick_resume')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addInjection,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: Text(tr(ref, 'inject_capital')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showWeeklyCheckupDialog(
                      stockExpenses: stockExpenses,
                      totalRevenue: totalRevenue,
                      businessExpenses: businessExpenses,
                      personalPayouts: personalPayouts,
                      capitalRecovered: capitalRecovered,
                      remainingCapital: remainingCapital,
                      realizedProfit: realizedProfit,
                    ),
                    icon: const Icon(Icons.calendar_today_rounded),
                    label: Text(tr(ref, 'weekly_checkup')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 230,
                  child: _buildStatCard(
                    'Capital Pool',
                    CurrencyUtils.format(capitalPool),
                    Icons.account_balance_wallet_rounded,
                    AppTheme.primaryBlue,
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: _buildStatCard(
                    'Cash Capital',
                    CurrencyUtils.format(cashCapital),
                    Icons.payments_rounded,
                    Colors.green,
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: _buildStatCard(
                    'Assets Capital',
                    CurrencyUtils.format(assetsCapital),
                    Icons.inventory_2_rounded,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCapitalProgressCard(
              stockExpenses: stockExpenses,
              capitalRecovered: capitalRecovered,
              remainingCapital: remainingCapital,
              completion: capitalCompletion,
              realizedProfit: realizedProfit,
            ),
            const SizedBox(height: 16),
            _buildProfitControlCards(
              profitAvailableToSpend: profitAvailableToSpend,
              businessExpenses: businessExpenses,
              personalPayouts: personalPayouts,
            ),
            const SizedBox(height: 16),
            _buildFinancialSummaryCard(
              revenue: totalRevenue,
              stockExpenses: stockExpenses,
              businessExpenses: businessExpenses,
              personalPayouts: personalPayouts,
              grossMargin: grossMargin,
              operatingMargin: operatingMargin,
              payoutRatio: payoutRatio,
              businessCostRatio: businessCostRatio,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 12),
            _buildInjectionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCapitalProgressCard({
    required double stockExpenses,
    required double capitalRecovered,
    required double remainingCapital,
    required double completion,
    required double realizedProfit,
  }) {
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
              Text(tr(ref, 'capital_energy'), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Tooltip(
                message:
                    'This bar shows how much of your initial capital has been recovered by sales. Profit only starts after capital is fully recovered.',
                child: Icon(Icons.help_outline_rounded, color: AppTheme.slate500, size: 16),
              ),
              const Spacer(),
              Text('${(completion * 100).toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 8),
          Text('${tr(ref, 'stock_deployed')} ${CurrencyUtils.format(stockExpenses)}'),
          Text('${tr(ref, 'recovered_from_sales')} ${CurrencyUtils.format(capitalRecovered)}'),
          Text('${tr(ref, 'remaining_to_recover')} ${CurrencyUtils.format(remainingCapital)}'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: completion.clamp(0, 1)),
          const SizedBox(height: 8),
          Text(
            'Realized Profit: ${CurrencyUtils.format(realizedProfit)}',
            style: TextStyle(
              color: realizedProfit >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitControlCards({
    required double profitAvailableToSpend,
    required double businessExpenses,
    required double personalPayouts,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            tr(ref, 'available_profit'),
            CurrencyUtils.format(profitAvailableToSpend),
            Icons.savings_rounded,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Business from Profit',
            CurrencyUtils.format(businessExpenses),
            Icons.business_center_rounded,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Salary from Profit',
            CurrencyUtils.format(personalPayouts),
            Icons.payments_rounded,
            AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummaryCard({
    required double revenue,
    required double stockExpenses,
    required double businessExpenses,
    required double personalPayouts,
    required double grossMargin,
    required double operatingMargin,
    required double payoutRatio,
    required double businessCostRatio,
  }) {
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
          Text(tr(ref, 'finance_summary'), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSummaryRow('Revenue', CurrencyUtils.format(revenue)),
          _buildSummaryRow('Stock Cost', CurrencyUtils.format(stockExpenses)),
          _buildSummaryRow('Business Expenses', CurrencyUtils.format(businessExpenses)),
          _buildSummaryRow('Owner Salary (Payout)', CurrencyUtils.format(personalPayouts)),
          const Divider(height: 22),
          _buildSummaryRow('Gross Margin', '${(grossMargin * 100).toStringAsFixed(1)}%'),
          _buildSummaryRow('Operating Margin', '${(operatingMargin * 100).toStringAsFixed(1)}%'),
          _buildSummaryRow('Salary Ratio', '${(payoutRatio * 100).toStringAsFixed(1)}%'),
          _buildSummaryRow(
            'Business Cost Ratio',
            '${(businessCostRatio * 100).toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.slate500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
          Text(title, style: TextStyle(color: AppTheme.slate500, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInjectionsList() {
    if (_injections.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr(ref, 'capital_injections'), style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...List.generate(_injections.length, (index) {
          final i = _injections[_injections.length - 1 - index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.add_circle_outline_rounded),
            title: Text(i.description),
            subtitle: Text('${i.date.day}/${i.date.month}/${i.date.year}'),
            trailing: Text(
              CurrencyUtils.format(i.amount),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () => _showInjectionDetail(i, _injections.length - 1 - index),
          );
        }),
      ],
    );
  }

  void _showInjectionDetail(_CapitalInjection injection, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'capital_injection_details')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Description', injection.description),
            _buildDetailRow('Amount', CurrencyUtils.format(injection.amount)),
            _buildDetailRow('Date', '${injection.date.day}/${injection.date.month}/${injection.date.year}'),
            _buildDetailRow('Time', '${injection.date.hour.toString().padLeft(2, '0')}:${injection.date.minute.toString().padLeft(2, '0')}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _injections.removeAt(_injections.length - 1 - index));
              _saveFinanceSettings();
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
          Text(label, style: TextStyle(color: AppTheme.slate500, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _addInjection() async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final result = await showDialog<_CapitalInjection>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'inject_capital')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount (XAF)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr(ref, 'cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              _CapitalInjection(
                amount: double.tryParse(amountController.text) ?? 0,
                description: descriptionController.text.isEmpty
                    ? 'Capital Injection'
                    : descriptionController.text,
                date: DateTime.now(),
              ),
            ),
            child: Text(tr(ref, 'add')),
          ),
        ],
      ),
    );
    if (result == null || result.amount <= 0) return;
    setState(() => _injections.add(result));
    await _saveFinanceSettings();
  }

  void _showQuickResume({
    required double capitalCompletion,
    required double remainingCapital,
    required double realizedProfit,
  }) {
    final sales = ref.read(saleProvider);
    final expenses = ref.read(expenseProvider);
    final totalRevenue = sales.fold(0.0, (sum, item) => sum + item.totalAmount);
    final stockExpenses = expenses
        .where((e) => e.category == ExpenseCategory.stock)
        .fold(0.0, (sum, e) => sum + e.amount);
    final businessExpenses = expenses
        .where((e) => e.category == ExpenseCategory.business)
        .fold(0.0, (sum, e) => sum + e.amount);
    final personalPayouts = expenses
        .where((e) => e.category == ExpenseCategory.personalPayout)
        .fold(0.0, (sum, e) => sum + e.amount);
    final injectedCapital = _injections.fold(0.0, (sum, i) => sum + i.amount);
    final capitalPool = _initialCapital + injectedCapital;
    final cashCapital = max<double>(
      0,
      capitalPool - stockExpenses + totalRevenue - businessExpenses - personalPayouts,
    );

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
              // Capital Overview Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.08),
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
                    _buildResumeRow('Capital Pool', CurrencyUtils.format(capitalPool)),
                    _buildResumeRow('Cash Capital', CurrencyUtils.format(cashCapital)),
                    _buildResumeRow('Capital Covered', '${(capitalCompletion * 100).toStringAsFixed(1)}%'),
                    _buildResumeRow('Remaining to Cover', CurrencyUtils.format(remainingCapital)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Profit Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: realizedProfit >= 0 
                      ? Colors.green.withValues(alpha: 0.08)
                      : Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          realizedProfit >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 16,
                          color: realizedProfit >= 0 ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(tr(ref, 'profit_analysis'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildResumeRow('Realized Profit', CurrencyUtils.format(realizedProfit), isHighlight: true),
                    _buildResumeRow('Total Revenue', CurrencyUtils.format(totalRevenue)),
                    _buildResumeRow('Stock Cost', CurrencyUtils.format(stockExpenses)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Expenses Breakdown
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 16, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(tr(ref, 'expenses_breakdown'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildResumeRow('Business Expenses', CurrencyUtils.format(businessExpenses)),
                    _buildResumeRow('Personal Payouts', CurrencyUtils.format(personalPayouts)),
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

  Widget _buildResumeRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.slate500, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
              color: isHighlight ? (value.startsWith('-') ? Colors.red : Colors.green) : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWeeklyCheckupDialog({
    required double stockExpenses,
    required double totalRevenue,
    required double businessExpenses,
    required double personalPayouts,
    required double capitalRecovered,
    required double remainingCapital,
    required double realizedProfit,
  }) async {
    final notesController = TextEditingController();
    final payoutController = TextEditingController(text: '0');
    final reinjectController = TextEditingController(text: '0');

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
                      color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(ref, 'this_week_summary'), style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildResumeRow('Stock Purchased', CurrencyUtils.format(stockExpenses)),
                        _buildResumeRow('Sales Revenue', CurrencyUtils.format(totalRevenue)),
                        _buildResumeRow('Business Expenses', CurrencyUtils.format(businessExpenses)),
                        _buildResumeRow('Personal Payouts', CurrencyUtils.format(personalPayouts)),
                        const SizedBox(height: 4),
                        _buildResumeRow('Capital Recovered', CurrencyUtils.format(capitalRecovered), isHighlight: true),
                        _buildResumeRow('Remaining to Recover', CurrencyUtils.format(remainingCapital)),
                        _buildResumeRow('Realized Profit', CurrencyUtils.format(realizedProfit), isHighlight: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(tr(ref, 'profit_distribution'), style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: payoutController,
                    decoration: const InputDecoration(
                      labelText: 'Profit Payout (take as salary)',
                      border: OutlineInputBorder(),
                      suffixText: 'XAF',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: reinjectController,
                    decoration: const InputDecoration(
                      labelText: 'Reinject as Capital',
                      border: OutlineInputBorder(),
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
                      color: Colors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Available profit: ${CurrencyUtils.format(realizedProfit)}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
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
                final reinject = double.tryParse(reinjectController.text) ?? 0;
                
                if (payout + reinject > realizedProfit) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr(ref, 'payout_reinject_exceed'))),
                  );
                  return;
                }

                // Create weekly checkup record
                final now = DateTime.now();
                final weekStart = WeeklyCheckup.getWeekStartDate(now);
                final weekEnd = WeeklyCheckup.getWeekEndDate(now);
                
                final checkup = WeeklyCheckup()
                  ..weekStartDate = weekStart
                  ..weekEndDate = weekEnd
                  ..totalStockPurchased = stockExpenses
                  ..totalSalesRevenue = totalRevenue
                  ..totalBusinessExpenses = businessExpenses
                  ..totalPersonalPayouts = personalPayouts
                  ..capitalRecovered = capitalRecovered
                  ..capitalRemaining = remainingCapital
                  ..realizedProfit = realizedProfit
                  ..profitPayoutTaken = payout
                  ..profitReinjected = reinject
                  ..notes = notesController.text;

                await ref.read(weeklyCheckupProvider.notifier).addCheckup(checkup);

                // If reinjecting capital, add to injections
                if (reinject > 0) {
                  final prefs = await SharedPreferences.getInstance();
                  final injectionsJson = prefs.getStringList(_injectionsKey) ?? [];
                  final newInjection = _CapitalInjection(
                    amount: reinject,
                    description: 'Weekly checkup reinjection',
                    date: now,
                  );
                  injectionsJson.add(jsonEncode(newInjection.toJson()));
                  await prefs.setStringList(_injectionsKey, injectionsJson);
                  setState(() {
                    _injections.add(newInjection);
                  });
                }

                // If taking payout, create a personalPayout expense
                if (payout > 0) {
                  final payoutExpense = Expense()
                    ..description = 'Weekly checkup payout'
                    ..amount = payout
                    ..category = ExpenseCategory.personalPayout
                    ..notes = notesController.text
                    ..operationId = const Uuid().v4();
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

class _CapitalInjection {
  final double amount;
  final String description;
  final DateTime date;

  _CapitalInjection({
    required this.amount,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'description': description,
        'date': date.toIso8601String(),
      };

  factory _CapitalInjection.fromJson(Map<String, dynamic> json) => _CapitalInjection(
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String? ?? 'Capital Injection',
        date: DateTime.parse(json['date'] as String),
      );
}
