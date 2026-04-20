import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/models/expense.dart';
import 'package:shopping_app/models/product.dart';
import 'package:shopping_app/models/sale.dart';
import 'package:shopping_app/services/financial_stats_service.dart';

void main() {
  const service = FinancialStatsService();

  test('calculates weekly and all-time financial stats from purchase cost basis', () {
    final now = DateTime(2026, 4, 19);
    final sales = [
      Sale(
        id: 'sale-1',
        totalAmount: 150000,
        saleDate: DateTime(2026, 4, 16),
        isPaid: true,
      ),
      Sale(
        id: 'sale-2',
        totalAmount: 30000,
        saleDate: DateTime(2026, 4, 1),
        isPaid: true,
      ),
    ];

    final expenses = [
      Expense(
        id: 'exp-stock',
        amount: 80000,
        category: ExpenseCategory.stock,
        expenseDate: DateTime(2026, 4, 15),
      ),
      Expense(
        id: 'exp-biz',
        amount: 10000,
        category: ExpenseCategory.business,
        expenseDate: DateTime(2026, 4, 15),
      ),
      Expense(
        id: 'exp-pay',
        amount: 5000,
        category: ExpenseCategory.personalPayout,
        expenseDate: DateTime(2026, 4, 15),
      ),
      Expense(
        id: 'exp-cap',
        amount: 40000,
        category: ExpenseCategory.capitalInjection,
        expenseDate: DateTime(2026, 4, 1),
      ),
    ];

    final products = [
      Product(
        id: 'product-1',
        stockQuantity: 5,
        purchasePrice: 10000,
        price: 18000,
      ),
    ];

    final stats = service.calculate(
      sales: sales,
      expenses: expenses,
      products: products,
      now: now,
    );

    expect(stats.revenue, 150000);
    expect(stats.stockDeployed, 80000);
    expect(stats.businessCost, 10000);
    expect(stats.netProfit, 60000);
    expect(stats.availableProfit, 55000);
    expect(stats.assetsCapital, 50000);
    expect(stats.cashCapital, 125000);
    expect(stats.capitalPool, 175000);
    expect(stats.totalRevenue, 180000);
  });
}
