import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/smart_image.dart';
import '../utils/currency_utils.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: expenses.isEmpty
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
                    'No expenses yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first expense',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildCategoryFilter(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
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
        children: ExpenseCategory.values.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getCategoryName(category)),
              selected: false,
              onSelected: (selected) {
                // Future: Filter Logic
              },
            ),
          );
        }).toList(),
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
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              _formatDate(expense.expenseDate),
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
        title: const Text('Delete Expense?'),
        content: Text('Are you sure you want to delete "${expense.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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
      case ExpenseCategory.socialMedia: return 'Social Media';
      case ExpenseCategory.stand: return 'Stand';
      case ExpenseCategory.transportation: return 'Transportation';
      case ExpenseCategory.supplies: return 'Supplies';
      case ExpenseCategory.utilities: return 'Utilities';
      case ExpenseCategory.rent: return 'Rent';
      case ExpenseCategory.marketing: return 'Marketing';
      case ExpenseCategory.other: return 'Other';
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.socialMedia: return Icons.share;
      case ExpenseCategory.stand: return Icons.store;
      case ExpenseCategory.transportation: return Icons.directions_car;
      case ExpenseCategory.supplies: return Icons.inventory;
      case ExpenseCategory.utilities: return Icons.lightbulb;
      case ExpenseCategory.rent: return Icons.home;
      case ExpenseCategory.marketing: return Icons.campaign;
      case ExpenseCategory.other: return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.socialMedia: return AppTheme.chart3;
      case ExpenseCategory.stand: return AppTheme.chart5;
      case ExpenseCategory.transportation: return AppTheme.chart1;
      case ExpenseCategory.supplies: return AppTheme.chart2;
      case ExpenseCategory.utilities: return AppTheme.chart4;
      case ExpenseCategory.rent: return AppTheme.chart3;
      case ExpenseCategory.marketing: return AppTheme.chart5;
      case ExpenseCategory.other: return AppTheme.mutedForeground;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showExpenseDialog({Expense? expense}) async {
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController(text: expense?.description ?? '');
    final amountController = TextEditingController(text: expense?.amount.toString() ?? '');
    final notesController = TextEditingController(text: expense?.notes ?? '');
    ExpenseCategory selectedCategory = expense?.category ?? ExpenseCategory.other;
    String? receiptImagePath = expense?.receiptImagePath;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                      final pickedFile = await _imagePicker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                        maxHeight: 800,
                      );
                      if (pickedFile != null && mounted) {
                        setState(() {
                          receiptImagePath = pickedFile.path;
                        });
                      }
                    },
                    child: SmartImage(
                      imagePath: receiptImagePath,
                      width: double.infinity,
                      height: 150,
                      borderRadius: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newExpense = Expense()
                    ..description = descriptionController.text
                    ..amount = double.tryParse(amountController.text) ?? 0.0
                    ..category = selectedCategory
                    ..notes = notesController.text.isEmpty ? null : notesController.text
                    ..receiptImagePath = receiptImagePath;

                  if (expense != null) {
                    newExpense.id = expense.id;
                    newExpense.serverId = expense.serverId;
                    await ref.read(expenseProvider.notifier).updateExpense(newExpense);
                  } else {
                    await ref.read(expenseProvider.notifier).addExpense(newExpense);
                  }

                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
              child: Text(expense == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
