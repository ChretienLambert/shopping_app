import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'expense_provider.dart';
import 'product_provider.dart';
import 'sale_provider.dart';
import '../services/financial_stats_service.dart';

final financialStatsServiceProvider = Provider<FinancialStatsService>((ref) {
  return const FinancialStatsService();
});

final financialStatsProvider = Provider<FinancialStats>((ref) {
  return ref.watch(financialStatsServiceProvider).calculate(
    sales: ref.watch(saleProvider),
    expenses: ref.watch(expenseProvider),
    products: ref.watch(productProvider),
  );
});
