import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../models/expense.dart';
import 'expense_provider.dart';
import 'product_provider.dart';
import 'sale_provider.dart';
import 'initial_capital_provider.dart';

class FinancialStats {
  final double revenue;
  final double stockDeployed;
  final double businessCost;
  final double payout;
  final double recoveredFromSales;
  final double remainingToRecover;
  final double salesAfterRecovery;
  final double availableProfit;
  final double netProfit;
  final double coverage;
  final double cashCapital;
  final double assetsCapital;
  final double capitalPool;
  final int salesCount;
  
  // All-time Metrics
  final double totalRevenue;
  final double totalStockDeployed;
  final double totalBusinessCost;
  final double totalPayout;
  final int totalSalesCount;
  final double totalRecoveredFromSales;
  final double totalRemainingToRecover;
  final double totalNetProfit;
  final double totalCoverage;

  final int pendingDeliveries;
  final int lowStock;
  final List<Map<String, dynamic>> recentActivity;

  FinancialStats({
    required this.revenue,
    required this.stockDeployed,
    required this.businessCost,
    required this.payout,
    required this.recoveredFromSales,
    required this.remainingToRecover,
    required this.salesAfterRecovery,
    required this.availableProfit,
    required this.netProfit,
    required this.coverage,
    required this.cashCapital,
    required this.assetsCapital,
    required this.capitalPool,
    required this.salesCount,
    required this.totalRevenue,
    required this.totalStockDeployed,
    required this.totalBusinessCost,
    required this.totalPayout,
    required this.totalSalesCount,
    required this.totalRecoveredFromSales,
    required this.totalRemainingToRecover,
    required this.totalNetProfit,
    required this.totalCoverage,
    required this.pendingDeliveries,
    required this.lowStock,
    required this.recentActivity,
  });
}

final financialStatsProvider = Provider<FinancialStats>((ref) {
  final rawSales = ref.watch(saleProvider);
  final allPaidSales = rawSales.where((s) => s.isPaid && s.deletedAt == null).toList();
  final allExpenses = ref.watch(expenseProvider).where((e) => e.deletedAt == null).toList();
  final products = ref.watch(productProvider);
  final initialCapital = ref.watch(initialCapitalProvider);

  // Get start of the current week (Monday)
  final now = DateTime.now();
  final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

  // Current Week Data
  final weekSales = rawSales.where((s) => (s.saleDate.isAfter(startOfWeek) || s.saleDate.isAtSameMomentAs(startOfWeek)) && s.deletedAt == null).toList();
  final weekExpenses = allExpenses.where((e) => e.expenseDate.isAfter(startOfWeek) || e.expenseDate.isAtSameMomentAs(startOfWeek)).toList();

  final revenue = weekSales.where((s) => s.isPaid).fold<double>(0, (sum, s) => sum + s.totalAmount);
  
  final weekStockExpenses = weekExpenses.where((e) => e.category == ExpenseCategory.stock);
  final weekBusinessExpenses = weekExpenses.where((e) => e.category == ExpenseCategory.business);
  final weekPayouts = weekExpenses.where((e) => e.category == ExpenseCategory.personalPayout);

  final stockDeployed = weekStockExpenses.fold<double>(0, (sum, e) => sum + e.amount);
  final businessCost = weekBusinessExpenses.fold<double>(0, (sum, e) => sum + e.amount);
  final payout = weekPayouts.fold<double>(0, (sum, e) => sum + e.amount);

  final recoveredFromSales = stockDeployed <= 0 ? 0.0 : min(revenue, stockDeployed);
  final remainingToRecover = max(0.0, stockDeployed - recoveredFromSales);
  final salesAfterRecovery = max(0.0, revenue - recoveredFromSales);
  final availableProfit = max(0.0, revenue - stockDeployed) - businessCost - payout;
  final netProfit = (revenue - stockDeployed - businessCost - payout);
  final coverage = stockDeployed <= 0 ? 1.0 : (recoveredFromSales / stockDeployed).clamp(0, 1).toDouble();
  final salesCount = weekSales.where((s) => s.isPaid).length;

  // All-time Metrics Logic
  final totalRevenue = allPaidSales.fold<double>(0, (sum, s) => sum + s.totalAmount);
  final totalStockDeployed = allExpenses.where((e) => e.category == ExpenseCategory.stock).fold<double>(0, (sum, e) => sum + e.amount);
  final totalBusinessCost = allExpenses.where((e) => e.category == ExpenseCategory.business).fold<double>(0, (sum, e) => sum + e.amount);
  final totalPayout = allExpenses.where((e) => e.category == ExpenseCategory.personalPayout).fold<double>(0, (sum, e) => sum + e.amount);
  final totalInjections = allExpenses.where((e) => e.category == ExpenseCategory.capitalInjection).fold<double>(0, (sum, e) => sum + e.amount);
  final totalSalesCount = allPaidSales.length;

  final totalRecoveredFromSales = totalStockDeployed <= 0 ? 0.0 : min(totalRevenue, totalStockDeployed);
  final totalRemainingToRecover = max(0.0, totalStockDeployed - totalRecoveredFromSales);
  final totalNetProfit = totalRevenue - totalStockDeployed - totalBusinessCost - totalPayout;
  final totalCoverage = totalStockDeployed <= 0 ? 1.0 : (totalRecoveredFromSales / totalStockDeployed).clamp(0, 1).toDouble();

  // Capital Pool (Cumulative)
  final assetsCapital = products.fold<double>(0, (sum, p) => sum + (p.price * p.stockQuantity));
  // Cash Capital = Initial Capital + Injections - Stock + Revenue - Business - Payout
  final cashCapital = initialCapital + totalInjections - totalStockDeployed + totalRevenue - totalBusinessCost - totalPayout;
  final capitalPool = assetsCapital + cashCapital;

  final pendingDeliveries = rawSales.where((s) => s.isDelivery && !s.isPaid && s.deletedAt == null).length;
  final lowStock = products.where((p) => p.stockQuantity < 10).length;

  final recentActivity = [
    ...rawSales.where((s) => s.deletedAt == null).map((s) => {'date': s.saleDate, 'label': s.isPaid ? 'Sale' : 'Pending Sale', 'amount': s.totalAmount, 'type': 'sale', 'id': s.id}),
    ...allExpenses.map((e) => {'date': e.expenseDate, 'label': e.description, 'amount': -e.amount, 'type': 'expense', 'id': e.id}),
  ]..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

  return FinancialStats(
    revenue: revenue,
    stockDeployed: stockDeployed,
    businessCost: businessCost,
    payout: payout,
    recoveredFromSales: recoveredFromSales,
    remainingToRecover: remainingToRecover,
    salesAfterRecovery: salesAfterRecovery,
    availableProfit: availableProfit,
    netProfit: netProfit,
    coverage: coverage,
    cashCapital: cashCapital,
    assetsCapital: assetsCapital,
    capitalPool: capitalPool,
    salesCount: salesCount,
    totalRevenue: totalRevenue,
    totalStockDeployed: totalStockDeployed,
    totalBusinessCost: totalBusinessCost,
    totalPayout: totalPayout,
    totalSalesCount: totalSalesCount,
    totalRecoveredFromSales: totalRecoveredFromSales,
    totalRemainingToRecover: totalRemainingToRecover,
    totalNetProfit: totalNetProfit,
    totalCoverage: totalCoverage,
    pendingDeliveries: pendingDeliveries,
    lowStock: lowStock,
    recentActivity: recentActivity,
  );
});
