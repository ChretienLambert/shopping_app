import 'dart:math';

import '../models/expense.dart';
import '../models/product.dart';
import '../models/sale.dart';

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
  final double totalRevenue;
  final double totalStockDeployed;
  final double totalBusinessCost;
  final double totalPayout;
  final int totalSalesCount;
  final double totalRecoveredFromSales;
  final double totalRemainingToRecover;
  final double totalNetProfit;
  final double totalAvailableProfit;
  final double totalCoverage;
  final int pendingDeliveries;
  final int lowStock;
  final List<Map<String, dynamic>> recentActivity;

  const FinancialStats({
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
    required this.totalAvailableProfit,
    required this.totalCoverage,
    required this.pendingDeliveries,
    required this.lowStock,
    required this.recentActivity,
  });
}

class PeriodFinancialSummary {
  final double revenue;
  final double stockDeployed;
  final double businessCost;
  final double payout;
  final double recoveredFromSales;
  final double remainingToRecover;
  final double realizedProfit;
  final double availableProfit;
  final double coverage;
  final int salesCount;

  const PeriodFinancialSummary({
    required this.revenue,
    required this.stockDeployed,
    required this.businessCost,
    required this.payout,
    required this.recoveredFromSales,
    required this.remainingToRecover,
    required this.realizedProfit,
    required this.availableProfit,
    required this.coverage,
    required this.salesCount,
  });
}

class FinancialStatsService {
  const FinancialStatsService();

  PeriodFinancialSummary calculatePeriod({
    required Iterable<Sale> sales,
    required Iterable<Expense> expenses,
  }) {
    final activeSales = sales.where((sale) => sale.deletedAt == null).toList();
    final activeExpenses =
        expenses.where((expense) => expense.deletedAt == null).toList();

    final revenue =
        activeSales.where((sale) => sale.isPaid).fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final stockDeployed = activeExpenses
        .where((expense) => expense.category == ExpenseCategory.stock)
        .fold<double>(0, (sum, expense) => sum + expense.amount);
    final businessCost = activeExpenses
        .where((expense) => expense.category == ExpenseCategory.business)
        .fold<double>(0, (sum, expense) => sum + expense.amount);
    final payout = activeExpenses
        .where((expense) => expense.category == ExpenseCategory.personalPayout)
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    final recoveredFromSales =
        stockDeployed <= 0 ? 0.0 : min(revenue, stockDeployed);
    final remainingToRecover = max(0.0, stockDeployed - recoveredFromSales);
    // Realized Profit is now Gross Profit (Revenue - Stock Cost)
    final realizedProfit = revenue - stockDeployed;
    final availableProfit = realizedProfit - businessCost - payout;
    final coverage = stockDeployed <= 0
        ? 1.0
        : (recoveredFromSales / stockDeployed).clamp(0, 1).toDouble();

    return PeriodFinancialSummary(
      revenue: revenue,
      stockDeployed: stockDeployed,
      businessCost: businessCost,
      payout: payout,
      recoveredFromSales: recoveredFromSales,
      remainingToRecover: remainingToRecover,
      realizedProfit: realizedProfit,
      availableProfit: availableProfit,
      coverage: coverage,
      salesCount: activeSales.where((sale) => sale.isPaid).length,
    );
  }

  FinancialStats calculate({
    required List<Sale> sales,
    required List<Expense> expenses,
    required List<Product> products,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final activeSales = sales.where((s) => s.deletedAt == null).toList();
    final allPaidSales = activeSales.where((s) => s.isPaid).toList();
    final activeExpenses = expenses.where((e) => e.deletedAt == null).toList();
    final activeProducts =
        products.where((p) => p.deletedAt == null).toList(growable: false);

    final startOfWeek = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    ).subtract(Duration(days: currentTime.weekday - 1));

    final weekSales = activeSales
        .where(
          (s) =>
              s.saleDate.isAfter(startOfWeek) ||
              s.saleDate.isAtSameMomentAs(startOfWeek),
        )
        .toList();
    final weekExpenses = activeExpenses
        .where(
          (e) =>
              e.expenseDate.isAfter(startOfWeek) ||
              e.expenseDate.isAtSameMomentAs(startOfWeek),
        )
        .toList();

    final weeklySummary = calculatePeriod(
      sales: weekSales,
      expenses: weekExpenses,
    );

    final totalSummary = calculatePeriod(
      sales: allPaidSales,
      expenses: activeExpenses,
    );
    final totalInjections = activeExpenses
        .where((e) => e.category == ExpenseCategory.capitalInjection)
        .fold<double>(0, (sum, e) => sum + e.amount);

    final assetsCapital = activeProducts.fold<double>(
      0,
      (sum, product) => sum + (product.purchasePrice * product.stockQuantity),
    );
    final cashCapital = totalInjections -
        totalSummary.stockDeployed +
        totalSummary.revenue -
        totalSummary.businessCost -
        totalSummary.payout;
    final capitalPool = assetsCapital + cashCapital;

    final pendingDeliveries = activeSales
        .where((s) => s.isDelivery && !s.isPaid)
        .length;
    final lowStock = activeProducts.where((p) => p.stockQuantity < 10).length;

    final recentActivity = [
      ...activeSales.map(
        (s) => {
          'date': s.saleDate,
          'label': s.isPaid ? 'Sale' : 'Pending Sale',
          'amount': s.totalAmount,
          'type': 'sale',
          'id': s.id,
        },
      ),
      ...activeExpenses.map(
        (e) => {
          'date': e.expenseDate,
          'label': e.description,
          'amount': -e.amount,
          'type': 'expense',
          'id': e.id,
        },
      ),
    ]..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return FinancialStats(
      revenue: weeklySummary.revenue,
      stockDeployed: weeklySummary.stockDeployed,
      businessCost: weeklySummary.businessCost,
      payout: weeklySummary.payout,
      recoveredFromSales: weeklySummary.recoveredFromSales,
      remainingToRecover: weeklySummary.remainingToRecover,
      salesAfterRecovery: max(0.0, weeklySummary.revenue - weeklySummary.recoveredFromSales),
      availableProfit: weeklySummary.availableProfit,
      netProfit: weeklySummary.realizedProfit,
      coverage: weeklySummary.coverage,
      cashCapital: cashCapital,
      assetsCapital: assetsCapital,
      capitalPool: capitalPool,
      salesCount: weeklySummary.salesCount,
      totalRevenue: totalSummary.revenue,
      totalStockDeployed: totalSummary.stockDeployed,
      totalBusinessCost: totalSummary.businessCost,
      totalPayout: totalSummary.payout,
      totalSalesCount: totalSummary.salesCount,
      totalRecoveredFromSales: totalSummary.recoveredFromSales,
      totalRemainingToRecover: totalSummary.remainingToRecover,
      totalNetProfit: totalSummary.realizedProfit,
      totalAvailableProfit: totalSummary.availableProfit,
      totalCoverage: totalSummary.coverage,
      pendingDeliveries: pendingDeliveries,
      lowStock: lowStock,
      recentActivity: recentActivity,
    );
  }
}
