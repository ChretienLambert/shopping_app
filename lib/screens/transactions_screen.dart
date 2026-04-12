import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sale_provider.dart';
import '../providers/expense_provider.dart';
import '../models/sale.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final sales = ref.watch(saleProvider);
    final expenses = ref.watch(expenseProvider);

    List<dynamic> transactions = [];
    
    if (_filter == 'all' || _filter == 'sales') {
      transactions.addAll(sales.map((sale) => {'type': 'sale', 'data': sale}));
    }
    if (_filter == 'all' || _filter == 'expenses') {
      transactions.addAll(expenses.map((expense) => {'type': 'expense', 'data': expense}));
    }

    transactions.sort((a, b) {
      final aDate = a['type'] == 'sale' 
          ? (a['data'] as Sale).saleDate 
          : (a['data'] as Expense).expenseDate;
      final bDate = b['type'] == 'sale' 
          ? (b['data'] as Sale).saleDate 
          : (b['data'] as Expense).expenseDate;
      return bDate.compareTo(aDate);
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                PopupMenuButton<String>(
                  initialValue: _filter,
                  child: Row(
                    children: [
                      Text(_filter == 'all' ? 'All' : _filter == 'sales' ? 'Sales Only' : 'Expenses Only'),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  onSelected: (value) {
                    setState(() {
                      _filter = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'all', child: Text('All')),
                    const PopupMenuItem(value: 'sales', child: Text('Sales Only')),
                    const PopupMenuItem(value: 'expenses', child: Text('Expenses Only')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                if (transaction['type'] == 'sale') {
                  return _buildSaleCard(transaction['data'] as Sale);
                } else {
                  return _buildExpenseCard(transaction['data'] as Expense);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.chart4,
          child: const Icon(Icons.sell, color: Colors.white, size: 20),
        ),
        title: Text(
          'Sale',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_formatDate(sale.saleDate)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+${sale.totalAmount.toInt().toString()} XAF',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.chart4,
                fontSize: 16,
              ),
            ),
            if (sale.notes != null)
              Text(
                sale.notes!,
                style: const TextStyle(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.destructive,
          child: const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${_formatDate(expense.expenseDate)} • ${_getCategoryName(expense.category)}'),
        trailing: Text(
          '-${expense.amount.toInt().toString()} XAF',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.destructive,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.socialMedia:
        return 'Social Media';
      case ExpenseCategory.stand:
        return 'Stand';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.supplies:
        return 'Supplies';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.marketing:
        return 'Marketing';
      case ExpenseCategory.other:
        return 'Other';
    }
  }
}
