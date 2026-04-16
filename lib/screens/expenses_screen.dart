import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/product.dart';
import '../providers/expense_provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localization.dart';
import '../utils/currency_utils.dart';
import '../widgets/smart_image.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> _stockCategories = ['Dress', 'Blouse', 'Trouser', 'Set', 'Jacket', 'Skirt', 'Shirt', 'Pants', 'Other'];
  ExpenseCategory? _selectedFilterCategory;
  String? _validationError;

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseProvider);
    // Filter out personalPayout expenses from display
    final nonPayoutExpenses = expenses.where((e) => e.category != ExpenseCategory.personalPayout).toList();
    final filteredExpenses = _selectedFilterCategory == null
        ? nonPayoutExpenses
        : nonPayoutExpenses.where((e) => e.category == _selectedFilterCategory).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilterCategory == null ? 'No expenses yet' : 'No expenses in this category',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFilterCategory == null ? 'Tap + to add your first expense' : 'Select a different category',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return _buildExpenseCard(expense);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExpenseDialog(),
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tr(ref, 'all')),
              selected: _selectedFilterCategory == null,
              onSelected: (selected) {
                setState(() => _selectedFilterCategory = selected ? null : _selectedFilterCategory);
              },
            ),
          ),
          ...ExpenseCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_getCategoryName(category)),
                selected: _selectedFilterCategory == category,
                onSelected: (selected) {
                  setState(() => _selectedFilterCategory = selected ? category : null);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.slate200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCategoryColor(expense.category).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: _getCategoryColor(expense.category),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.description,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (expense.operationId != null)
              Text(
                expense.operationId!,
                style: TextStyle(color: AppTheme.slate400, fontSize: 11),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getCategoryName(expense.category),
              style: TextStyle(color: AppTheme.slate500, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              '${_formatDate(expense.expenseDate)} • ${_formatTime(expense.expenseDate)}',
              style: TextStyle(color: AppTheme.slate400, fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyUtils.format(expense.amount),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.redAccent,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(expense),
            ),
          ],
        ),
        onTap: () => _showExpenseDialog(expense: expense),
      ),
    );
  }

  Future<void> _confirmDelete(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tr(ref, 'delete')}?'),
        content: Text('${tr(ref, 'are_you_sure_delete')} "${expense.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(tr(ref, 'cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(tr(ref, 'delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(expenseProvider.notifier).deleteExpense(expense);
    }
  }

  String _getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.stock:
        return 'Stock Expense';
      case ExpenseCategory.business:
        return 'Business Expense';
      case ExpenseCategory.personalPayout:
        return 'Personal Payout (Salary)';
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.stock:
        return Icons.inventory_2_rounded;
      case ExpenseCategory.business:
        return Icons.business_center_rounded;
      case ExpenseCategory.personalPayout:
        return Icons.payments_rounded;
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.stock:
        return AppTheme.chart2;
      case ExpenseCategory.business:
        return AppTheme.chart5;
      case ExpenseCategory.personalPayout:
        return AppTheme.destructive;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _addNewStockCategory(TextEditingController controller) {
    final newCategoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'add_new_category')),
        content: TextField(
          controller: newCategoryController,
          decoration: InputDecoration(
            labelText: tr(ref, 'category_name'),
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr(ref, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final newCategory = newCategoryController.text.trim();
              if (newCategory.isNotEmpty && !_stockCategories.contains(newCategory)) {
                setState(() {
                  _stockCategories.add(newCategory);
                  controller.text = newCategory;
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            child: Text(tr(ref, 'add')),
          ),
        ],
      ),
    );
  }

  Future<void> _showExpenseDialog({Expense? expense}) async {
    final sales = ref.read(saleProvider);
    final allExpenses = ref.read(expenseProvider);
    final totalRevenue = sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final stockSpent = allExpenses
        .where((e) => e.category == ExpenseCategory.stock)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final alreadyUsedProfit = allExpenses
        .where((e) => e.category != ExpenseCategory.stock)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final availableProfit =
        ((totalRevenue - stockSpent) - alreadyUsedProfit).clamp(0, double.infinity).toDouble();
    
    // Load initial capital and injections
    final prefs = await SharedPreferences.getInstance();
    final initialCapital = prefs.getDouble('finance_initial_capital') ?? 0.0;
    final injectionsJson = prefs.getStringList('finance_capital_injections') ?? [];
    final injectedCapital = injectionsJson.fold<double>(0, (sum, json) {
      try {
        final data = jsonDecode(json) as Map<String, dynamic>;
        return sum + (data['amount'] as num).toDouble();
      } catch (_) {
        return sum;
      }
    });

    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController(text: expense?.description ?? '');
    final amountController = TextEditingController(text: expense?.amount.toString() ?? '');
    final notesController = TextEditingController(text: expense?.notes ?? '');
    final stockNameController = TextEditingController(text: expense?.stockProductName ?? '');
    final stockTypeController = TextEditingController(text: expense?.stockProductType ?? '');
    final stockDescriptionController = TextEditingController(
      text: expense?.notes ?? '',
    );
    final stockQuantityController = TextEditingController(text: expense?.stockQuantity?.toString() ?? '');
    final stockPurchasePriceController = TextEditingController(text: expense?.stockPurchasePrice?.toString() ?? '');
    final stockResalePriceController = TextEditingController(text: expense?.stockResalePrice?.toString() ?? '');
    ExpenseCategory selectedCategory = expense?.category ?? ExpenseCategory.business;
    String? receiptImagePath = expense?.receiptImagePath;
    String? stockImagePath = expense?.stockImagePath;
    String selectedStockQuality = expense?.stockQuality ?? 'Second-hand';

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          double projectedProfit = 0;
          if (selectedCategory == ExpenseCategory.stock) {
            final qty = int.tryParse(stockQuantityController.text) ?? 0;
            final cost = double.tryParse(stockPurchasePriceController.text) ?? 0;
            final resale = double.tryParse(stockResalePriceController.text) ?? 0;
            projectedProfit = (resale - cost) * qty;
          }
          
          // Recalculate capital pool inside StatefulBuilder
          final currentSales = ref.read(saleProvider);
          final currentExpenses = ref.read(expenseProvider);
          final currentRevenue = currentSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
          final currentStockSpent = currentExpenses
              .where((e) => e.category == ExpenseCategory.stock)
              .fold<double>(0, (sum, e) => sum + e.amount);
          final currentCapitalPool = initialCapital + injectedCapital + currentRevenue - currentStockSpent;
          
          return AlertDialog(
          title: Text(expense == null ? 'Add Expense' : 'Edit Expense'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: ExpenseCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(_getCategoryIcon(category), color: _getCategoryColor(category), size: 18),
                            const SizedBox(width: 8),
                            Text(_getCategoryName(category)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCategory = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedCategory == ExpenseCategory.stock) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 18),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Stock refill uses capital. Profit is estimated from resale margin.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Tooltip(
                            message: 'Projected margin = (resale - cost) x quantity',
                            child: Icon(Icons.help_outline_rounded, color: AppTheme.slate500, size: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stockNameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (selectedCategory == ExpenseCategory.stock &&
                            (value == null || value.isEmpty)) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: stockTypeController.text.isNotEmpty ? stockTypeController.text : null,
                            decoration: const InputDecoration(
                              labelText: 'Garment Category *',
                              border: OutlineInputBorder(),
                            ),
                            items: _stockCategories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                stockTypeController.text = value;
                                setState(() {});
                              }
                            },
                            validator: (value) {
                              if (selectedCategory == ExpenseCategory.stock &&
                                  (value == null || value.isEmpty)) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () => _addNewStockCategory(stockTypeController),
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStockQuality,
                      decoration: const InputDecoration(
                        labelText: 'Condition Tier *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Second-hand',
                          child: Text('Friperie'),
                        ),
                        DropdownMenuItem(
                          value: 'Brand-new',
                          child: Text('Boutique'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedStockQuality = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (selectedCategory == ExpenseCategory.stock) ...[
                    TextFormField(
                      controller: stockQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity *',
                        border: OutlineInputBorder(),
                        suffixText: 'units',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (selectedCategory == ExpenseCategory.stock &&
                            (value == null || value.isEmpty)) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Available capital: ${CurrencyUtils.format(currentCapitalPool)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Tooltip(
                            message: 'Capital pool = Initial capital + Injections + Sales revenue - Stock expenses spent',
                            child: Icon(Icons.help_outline_rounded, color: AppTheme.slate500, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stockPurchasePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Price (per unit) *',
                        border: OutlineInputBorder(),
                        suffixText: 'XAF',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (selectedCategory == ExpenseCategory.stock &&
                            (value == null || value.isEmpty)) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stockResalePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Resale Price (per unit) *',
                        border: OutlineInputBorder(),
                        suffixText: 'XAF',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (selectedCategory == ExpenseCategory.stock &&
                            (value == null || value.isEmpty)) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: projectedProfit >= 0
                            ? Colors.green.withValues(alpha: 0.10)
                            : Colors.red.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(projectedProfit >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Projected profit: ${CurrencyUtils.format(projectedProfit)}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: projectedProfit >= 0 ? Colors.green : Colors.red),
                            ),
                          ),
                          Tooltip(
                            message: 'Estimated profit if all units sell at resale price: (Resale - Purchase) × Quantity',
                            child: Icon(Icons.help_outline_rounded, color: AppTheme.slate500, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stockDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Product Details (fabric, size range, notes)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final pickedFile = await _imagePicker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null && mounted) {
                            setState(() {
                              stockImagePath = pickedFile.path;
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() {});
                          }
                        }
                      },
                      child: SmartImage(
                        imagePath: stockImagePath,
                        width: 320,
                        height: 150,
                        borderRadius: 12,
                      ),
                    ),
                  ],
                  if (selectedCategory != ExpenseCategory.stock) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Available profit to spend/withdraw: ${CurrencyUtils.format(availableProfit)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Tooltip(
                            message: 'Profit available for business expenses and personal withdrawals',
                            child: Icon(Icons.help_outline_rounded, color: AppTheme.slate500, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount *',
                        border: OutlineInputBorder(),
                        suffixText: 'XAF',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final pickedFile = await _imagePicker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null && mounted) {
                            setState(() {
                              receiptImagePath = pickedFile.path;
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() {});
                          }
                        }
                      },
                      child: SmartImage(
                        imagePath: receiptImagePath,
                        width: 320,
                        height: 150,
                        borderRadius: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            if (_validationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationError!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr(ref, 'cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final quantity = int.tryParse(stockQuantityController.text) ?? 0;
                  final purchasePrice = double.tryParse(stockPurchasePriceController.text) ?? 0;
                  final resalePrice = double.tryParse(stockResalePriceController.text) ?? 0;
                  final computedStockAmount = quantity * purchasePrice;
                  final isStock = selectedCategory == ExpenseCategory.stock;

                  // Validation: Stock expense must have profit
                  if (isStock && resalePrice <= purchasePrice) {
                    setState(() => _validationError = 'Resale price must be greater than purchase price to make a profit');
                    return;
                  }

                  // Validation: Expense amount must not exceed available profit (for business/personal only)
                  if (!isStock) {
                    final expenseAmount = double.tryParse(amountController.text) ?? 0;
                    if (expenseAmount > availableProfit) {
                      setState(() => _validationError = 'Insufficient profit: Available ${CurrencyUtils.format(availableProfit)}, trying to spend ${CurrencyUtils.format(expenseAmount)}');
                      return;
                    }
                  }

                  // Validation: Stock refill must have sufficient capital
                  if (isStock) {
                    if (computedStockAmount > currentCapitalPool) {
                      setState(() => _validationError = 'Insufficient capital: Available ${CurrencyUtils.format(currentCapitalPool)}, trying to spend ${CurrencyUtils.format(computedStockAmount.toDouble())}');
                      return;
                    }
                  }

                  final newExpense = Expense()
                    ..description = isStock
                        ? 'Stock purchase: ${stockNameController.text}'
                        : descriptionController.text
                    ..amount = isStock
                        ? computedStockAmount.toDouble()
                        : double.tryParse(amountController.text) ?? 0
                    ..category = selectedCategory
                    ..notes = isStock ? stockDescriptionController.text : notesController.text
                    ..receiptImagePath = receiptImagePath
                    ..stockProductName = isStock ? stockNameController.text : null
                    ..stockProductType = isStock ? stockTypeController.text : null
                    ..stockQuantity = isStock ? quantity : null
                    ..stockPurchasePrice = isStock ? purchasePrice : null
                    ..stockResalePrice = isStock ? resalePrice : null
                    ..stockQuality = isStock ? selectedStockQuality : null
                    ..stockImagePath = isStock ? stockImagePath : null
                    ..operationId = expense?.operationId ?? Uuid().v4();

                  if (expense != null) {
                    newExpense.id = expense.id;
                    newExpense.serverId = expense.serverId;
                    newExpense.operationId = expense.operationId;
                    await ref.read(expenseProvider.notifier).updateExpense(newExpense);
                  } else {
                    await ref.read(expenseProvider.notifier).addExpense(newExpense);
                    if (isStock) {
                      final product = Product()
                        ..name = stockNameController.text
                        ..description = stockDescriptionController.text
                        ..productType = stockTypeController.text
                        ..quality = selectedStockQuality
                        ..stockQuantity = quantity
                        ..purchasePrice = purchasePrice
                        ..price = resalePrice
                        ..imagePath = stockImagePath;
                      await ref.read(productProvider.notifier).addProduct(product);
                    }
                  }

                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
              child: Text(expense == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    ),
  );
  }
}
