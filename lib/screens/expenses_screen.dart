import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localization.dart';
import '../utils/currency_utils.dart';
import '../widgets/smart_image.dart';
import '../services/logging_service.dart';
import '../services/storage_service.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> _stockCategories = ['dress', 'blouse', 'trouser', 'set', 'jacket', 'skirt', 'shirt', 'pants', 'other'];
  ExpenseCategory? _selectedFilterCategory;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _retrieveLostData();
  }

  Future<void> _retrieveLostData() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    final LostDataResponse response = await _imagePicker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      logger.info('Recovered image: ${response.file!.path}');
    } else {
      logger.error('Lost data error: ${response.exception}');
    }
  }

  Future<void> _pickImage(bool isStock, Function(String) onImagePicked) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(tr(ref, 'gallery')),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(tr(ref, 'camera')),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      try {
        final pickedFile = await _imagePicker.pickImage(
          source: source,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (pickedFile != null && mounted) {
          final category = isStock ? 'products' : 'receipts';
          final savedPath = await storageService.saveLocalImage(pickedFile.path, category);
          onImagePicked(savedPath);
        }
      } catch (e) {
        logger.error('Error picking image', e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr(ref, 'error_picking_image'))),
          );
        }
      }
    }
  }

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
                          _selectedFilterCategory == null ? tr(ref, 'no_expenses_yet') : tr(ref, 'no_expenses_category'),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFilterCategory == null ? tr(ref, 'tap_to_add_expense') : tr(ref, 'select_different_category'),
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
          ...ExpenseCategory.values.where((c) => c != ExpenseCategory.personalPayout).map((category) {
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
              '${expense.category == ExpenseCategory.capitalInjection ? "+" : ""}${CurrencyUtils.format(expense.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: expense.category == ExpenseCategory.capitalInjection ? Colors.green : Colors.redAccent,
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
        onTap: () => _showExpenseDetails(expense),
      ),
    );
  }

  void _showExpenseDetails(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'expense_details')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(tr(ref, 'description'), expense.description),
              _detailRow(tr(ref, 'amount'), CurrencyUtils.format(expense.amount)),
              _detailRow(tr(ref, 'category'), _getCategoryName(expense.category)),
              _detailRow(tr(ref, 'date'), '${_formatDate(expense.expenseDate)} ${_formatTime(expense.expenseDate)}'),
              if (expense.notes != null && expense.notes!.isNotEmpty)
                _detailRow(tr(ref, 'notes'), expense.notes!),
              if (expense.category == ExpenseCategory.stock) ...[
                const Divider(),
                _detailRow(tr(ref, 'product'), expense.stockProductName ?? ''),
                _detailRow(tr(ref, 'quantity'), '${expense.stockQuantity}'),
                _detailRow(tr(ref, 'purchase_price_unit'), CurrencyUtils.format(expense.stockPurchasePrice ?? 0)),
              ],
              if (expense.receiptImagePath != null || expense.stockImagePath != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: SmartImage(
                    imagePath: expense.receiptImagePath ?? expense.stockImagePath,
                    width: 200,
                    height: 150,
                    borderRadius: 8,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr(ref, 'close'))),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppTheme.slate500, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
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
        return tr(ref, 'stock_expense_title');
      case ExpenseCategory.business:
        return tr(ref, 'business_expense_title');
      case ExpenseCategory.personalPayout:
        return tr(ref, 'personal_payout_title');
      case ExpenseCategory.capitalInjection:
        return tr(ref, 'capital_injection_title');
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
      case ExpenseCategory.capitalInjection:
        return Icons.add_chart_rounded;
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
      case ExpenseCategory.capitalInjection:
        return Colors.green;
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
            border: const OutlineInputBorder(),
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

  Future<void> _showExpenseDialog() async {
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final stockNameController = TextEditingController();
    final stockTypeController = TextEditingController();
    final stockDescriptionController = TextEditingController();
    final stockQuantityController = TextEditingController();
    final stockPurchasePriceController = TextEditingController();
    final stockResalePriceController = TextEditingController();
    ExpenseCategory selectedCategory = ExpenseCategory.business;
    DateTime selectedDate = DateTime.now();
    String? receiptImagePath;
    String? stockImagePath;
    String selectedStockQuality = 'second_hand';
    bool isSaving = false;

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
          final totalInjections = currentExpenses
              .where((e) => e.category == ExpenseCategory.capitalInjection)
              .fold<double>(0, (sum, e) => sum + e.amount);
          final currentCapitalPool = totalInjections + currentRevenue - currentStockSpent;
          
          return AlertDialog(
          title: Text(tr(ref, 'add_expense')),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    DropdownButtonFormField<ExpenseCategory>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'category'),
                        border: const OutlineInputBorder(),
                      ),
                      items: ExpenseCategory.values
                          .where((c) => c != ExpenseCategory.personalPayout && c != ExpenseCategory.capitalInjection)
                          .map((category) {
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
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: tr(ref, 'date'),
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _formatDate(selectedDate),
                      ),
                    ),
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
                          Expanded(
                            child: Text(
                              tr(ref, 'stock_refill_info'),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Tooltip(
                            message: tr(ref, 'projected_margin_help'),
                            child: Icon(Icons.help_outline_rounded, color: AppTheme.slate500, size: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stockNameController,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'product_names'),
                        hintText: tr(ref, 'product_names_hint'),
                        border: const OutlineInputBorder(),
                        helperText: tr(ref, 'product_names_helper'),
                      ),
                      validator: (value) {
                        if (selectedCategory == ExpenseCategory.stock &&
                            (value == null || value.isEmpty)) {
                          return tr(ref, 'required');
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
                            decoration: InputDecoration(
                              labelText: tr(ref, 'garment_category'),
                              border: const OutlineInputBorder(),
                            ),
                            items: _stockCategories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(tr(ref, category)),
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
                                return tr(ref, 'required');
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
                      decoration: InputDecoration(
                        labelText: tr(ref, 'condition_tier'),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'second_hand',
                          child: Text(tr(ref, 'second_hand')),
                        ),
                        DropdownMenuItem(
                          value: 'new_condition',
                          child: Text(tr(ref, 'new_condition')),
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
                      decoration: InputDecoration(
                        labelText: tr(ref, 'stock_quantity'),
                        border: const OutlineInputBorder(),
                        suffixText: 'units',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (selectedCategory == ExpenseCategory.stock &&
                            (value == null || value.isEmpty)) {
                          return tr(ref, 'required');
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
                              '${tr(ref, 'available_capital')}: ${CurrencyUtils.format(currentCapitalPool)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Tooltip(
                            message: tr(ref, 'capital_pool_help'),
                            child: Icon(Icons.help_outline_rounded, color: AppTheme.slate500, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stockPurchasePriceController,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'purchase_price_unit'),
                        border: const OutlineInputBorder(),
                        suffixText: 'XAF',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (selectedCategory == ExpenseCategory.stock &&
                            (value == null || value.isEmpty)) {
                          return tr(ref, 'required');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stockResalePriceController,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'resale_price_unit'),
                        border: const OutlineInputBorder(),
                        suffixText: 'XAF',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (selectedCategory == ExpenseCategory.stock &&
                            (value == null || value.isEmpty)) {
                          return tr(ref, 'required');
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
                              '${tr(ref, 'projected_profit')}: ${CurrencyUtils.format(projectedProfit)}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: projectedProfit >= 0 ? Colors.green : Colors.red),
                            ),
                          ),
                          Tooltip(
                            message: tr(ref, 'projected_profit_help'),
                            child: Icon(Icons.help_outline_rounded, color: AppTheme.slate500, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stockDescriptionController,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'product_details_label'),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _pickImage(true, (path) => setState(() => stockImagePath = path)),
                      child: Center(
                        child: SmartImage(
                          imagePath: stockImagePath,
                          width: 320,
                          height: 150,
                          borderRadius: 12,
                        ),
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
                              '${tr(ref, 'available_capital')}: ${CurrencyUtils.format(currentCapitalPool)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Tooltip(
                            message: tr(ref, 'available_capital'),
                            child: Icon(Icons.help_outline_rounded, color: AppTheme.slate500, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: '${tr(ref, 'description')} *',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? tr(ref, 'required') : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: '${tr(ref, 'amount')} *',
                        border: const OutlineInputBorder(),
                        suffixText: 'XAF',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      validator: (value) => value == null || value.isEmpty ? tr(ref, 'required') : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'notes'),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _pickImage(false, (path) => setState(() => receiptImagePath = path)),
                      child: Center(
                        child: SmartImage(
                          imagePath: receiptImagePath,
                          width: 320,
                          height: 150,
                          borderRadius: 12,
                        ),
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
              onPressed: isSaving ? null : () async {
                if (formKey.currentState!.validate()) {
                  setState(() => isSaving = true);
                  try {
                    final quantity = int.tryParse(stockQuantityController.text) ?? 0;
                    final purchasePrice = double.tryParse(stockPurchasePriceController.text) ?? 0;
                    final resalePrice = double.tryParse(stockResalePriceController.text) ?? 0;
                    final computedStockAmount = quantity * purchasePrice;
                    final isStock = selectedCategory == ExpenseCategory.stock;

                    // Validation: Stock expense must have profit
                    if (isStock && resalePrice <= purchasePrice) {
                      setState(() {
                        _validationError = tr(ref, 'resale_price_error');
                        isSaving = false;
                      });
                      return;
                    }

                    // Validation: Expense amount must not exceed available capital (uses capital now, not profit)
                    if (!isStock) {
                      final expenseAmount = double.tryParse(amountController.text) ?? 0;
                      
                      if (expenseAmount > currentCapitalPool) {
                        setState(() {
                          _validationError = '${tr(ref, 'insufficient_capital')}: ${CurrencyUtils.format(currentCapitalPool)}';
                          isSaving = false;
                        });
                        return;
                      }
                    }

                    // Validation: Stock refill must have sufficient capital
                    if (isStock) {
                      final names = stockNameController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                      final totalStockAmount = computedStockAmount * names.length;
                      if (totalStockAmount > currentCapitalPool) {
                        setState(() {
                          _validationError = '${tr(ref, 'insufficient_capital')}: ${tr(ref, 'all')} ${CurrencyUtils.format(currentCapitalPool)}';
                          isSaving = false;
                        });
                        return;
                      }
                    }

                    if (isStock) {
                      final names = stockNameController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                      for (var name in names) {
                        final newExpense = Expense()
                          ..description = 'Stock purchase: $name'
                          ..amount = computedStockAmount
                          ..category = selectedCategory
                          ..notes = stockDescriptionController.text
                          ..receiptImagePath = receiptImagePath
                          ..stockProductName = name
                          ..stockProductType = stockTypeController.text
                          ..stockQuantity = quantity
                          ..stockPurchasePrice = purchasePrice
                          ..stockResalePrice = resalePrice
                          ..stockQuality = selectedStockQuality
                          ..stockImagePath = stockImagePath
                          ..expenseDate = selectedDate
                          ..operationId = const Uuid().v4();

                        await ref.read(expenseProvider.notifier).addExpense(newExpense);
                      }
                      // Refresh product catalog after adding stock
                      await ref.read(productProvider.notifier).loadProducts();
                    } else {
                      final newExpense = Expense()
                        ..description = descriptionController.text
                        ..amount = double.tryParse(amountController.text) ?? 0
                        ..category = selectedCategory
                        ..notes = notesController.text
                        ..receiptImagePath = receiptImagePath
                        ..expenseDate = selectedDate
                        ..operationId = const Uuid().v4();

                      await ref.read(expenseProvider.notifier).addExpense(newExpense);
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    setState(() {
                      _validationError = e.toString();
                      isSaving = false;
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue, 
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.6),
              ),
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(tr(ref, 'add')),
            ),
          ],
        );
      },
    ),
  );
  }
}
