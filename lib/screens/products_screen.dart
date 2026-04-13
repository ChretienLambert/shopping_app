import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../models/product.dart';
import '../providers/expense_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/smart_image.dart';
import '../utils/currency_utils.dart';
import '../utils/app_localization.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final List<String> _productCategories = ['Dress', 'Blouse', 'Trouser', 'Set', 'Jacket', 'Skirt', 'Shirt', 'Pants', 'Other'];
  String? _selectedFilterCategory;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final expenses = ref.watch(expenseProvider);
    final filteredProducts = _selectedFilterCategory == null
        ? products
        : products.where((p) => p.productType == _selectedFilterCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(ref, 'catalogs')),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width > 1200 ? 4 : width > 800 ? 3 : 2;
                      
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductGridItem(product, expenses);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.slate300),
          const SizedBox(height: 16),
          Text(
            _selectedFilterCategory == null ? 'No catalogs yet' : 'No catalogs in this category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.slate600,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilterCategory == null ? 'Add stock expenses to create catalogs' : 'Select a different category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.slate500,
                ),
          ),
        ],
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
          ..._productCategories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category),
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

  Widget _buildProductGridItem(Product product, List<Expense> expenses) {
    // Find last refill date from stock expenses
    DateTime? lastRefillDate;
    final stockExpenses = expenses
        .where((e) => 
            e.category == ExpenseCategory.stock &&
            e.stockProductName == product.name &&
            e.stockProductType == product.productType &&
            e.stockQuality == product.quality)
        .toList();
    
    if (stockExpenses.isNotEmpty) {
      stockExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
      lastRefillDate = stockExpenses.first.expenseDate;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showProductDialog(product: product),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.slate200),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SmartImage(
                        imagePath: product.imagePath,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      if (product.stockQuantity <= 5)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _buildStockBadge(product.stockQuantity),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${product.productType ?? "Not set"}',
                        style: TextStyle(color: AppTheme.slate500, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Condition: ${product.quality ?? "Not set"}',
                        style: TextStyle(color: AppTheme.slate500, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (lastRefillDate != null)
                        Text(
                          'Last refill: ${_formatDate(lastRefillDate)}',
                          style: TextStyle(color: AppTheme.primaryBlue.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 6),
                      Text(
                        product.description,
                        style: TextStyle(color: AppTheme.slate600, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyUtils.format(product.price),
                            style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.slate100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'x${product.stockQuantity}',
                              style: TextStyle(color: AppTheme.slate600, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStockBadge(int stock) {
    final color = stock == 0 ? Colors.red : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
      ),
      child: Text(
        stock == 0 ? 'OUT' : 'LOW',
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _showProductDialog({Product? product}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final stockController = TextEditingController(text: product?.stockQuantity.toString() ?? '');
    String? imagePath = product?.imagePath;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(tr(ref, 'update_price_and_stock')),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmartImage(
                    imagePath: imagePath,
                    width: 120,
                    height: 120,
                    borderRadius: 12,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price *',
                      border: OutlineInputBorder(),
                      suffixText: 'XAF',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
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
                if (formKey.currentState!.validate()) {
                  final newProduct = Product()
                    ..name = nameController.text
                    ..description = descriptionController.text
                    ..price = double.tryParse(priceController.text) ?? 0.0
                    ..stockQuantity = int.tryParse(stockController.text) ?? 0
                    ..imagePath = imagePath;

                  if (product == null) return;
                  newProduct.id = product.id;
                  newProduct.serverId = product.serverId;
                  newProduct.purchasePrice = product.purchasePrice;
                  newProduct.productType = product.productType;
                  newProduct.quality = product.quality;
                  await ref.read(productProvider.notifier).updateProduct(newProduct);

                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
              child: Text(tr(ref, 'update')),
            ),
          ],
        ),
      ),
    );
  }
}
