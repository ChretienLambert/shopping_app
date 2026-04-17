import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
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
  final List<String> _productCategories = ['dress', 'blouse', 'trouser', 'set', 'jacket', 'skirt', 'shirt', 'pants', 'other'];
  String? _selectedFilterCategory;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final filteredProducts = _selectedFilterCategory == null
        ? products
        : products.where((p) => p.productType?.toLowerCase() == _selectedFilterCategory).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              tr(ref, 'catalogs'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          _buildCategoryFilter(),
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 3,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _productCategories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : _productCategories[index - 1];
          final isSelected = _selectedFilterCategory == category;

          return ChoiceChip(
            label: Text(isAll ? tr(ref, 'all') : tr(ref, category!)),
            selected: isSelected,
            onSelected: (selected) {
              setState(() => _selectedFilterCategory = selected ? category : null);
            },
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showProductDetail(product),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SmartImage(
                      imagePath: product.imagePath,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  // Out of Stock Overlay
                  if (product.stockQuantity == 0)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              tr(ref, 'out_of_stock'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.productType != null)
                        Text(
                          tr(ref, product.productType!.toLowerCase()),
                          style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.slate400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (product.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        product.description,
                        style: TextStyle(fontSize: 9, color: AppTheme.slate400),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          CurrencyUtils.format(product.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: (product.stockQuantity > 5 
                              ? Colors.green 
                              : (product.stockQuantity > 0 ? Colors.orange : Colors.grey)
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '${product.stockQuantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 7,
                            color: product.stockQuantity > 5 
                                ? Colors.green 
                                : (product.stockQuantity > 0 ? Colors.orange : Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.slate300),
          const SizedBox(height: 16),
          Text(
            tr(ref, 'no_products_found'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            tr(ref, 'add_stock_from_expenses'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showProductDetail(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Product Image with Close Button
              Stack(
                children: [
                  SmartImage(
                    imagePath: product.imagePath,
                    width: double.infinity,
                    height: 200,
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                  if (product.stockQuantity == 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.red.withValues(alpha: 0.8),
                        child: Text(
                          tr(ref, 'out_of_stock').toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (product.productType != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    tr(ref, product.productType!.toLowerCase()),
                                    style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyUtils.format(product.price),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats Row
                    Row(
                      children: [
                        _statCard(
                          icon: Icons.inventory_2_outlined,
                          label: tr(ref, 'stock_level'),
                          value: '${product.stockQuantity} ${tr(ref, 'units')}',
                          color: product.stockQuantity > 5 ? Colors.green : (product.stockQuantity > 0 ? Colors.orange : Colors.red),
                        ),
                        const SizedBox(width: 10),
                        _statCard(
                          icon: Icons.calendar_today_outlined,
                          label: tr(ref, 'date'),
                          value: _formatDate(product.createdAt),
                          color: AppTheme.slate600,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    _detailRow(tr(ref, 'description'), product.description.isEmpty ? tr(ref, 'no_description_provided') : product.description),
                    
                    if (product.quality != null) ...[
                      const SizedBox(height: 12),
                      _detailRow(tr(ref, 'condition'), tr(ref, product.quality!.toLowerCase())),
                    ],

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditDialog(product),
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(tr(ref, 'update_stock_price')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({required IconData icon, required String label, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(fontSize: 10, color: AppTheme.slate400),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value, 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppTheme.slate400, fontSize: 12)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }

  void _showEditDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());
    final purchasePriceController = TextEditingController(text: product.purchasePrice.toString());
    final stockController = TextEditingController(text: product.stockQuantity.toString());
    String? selectedType = product.productType;
    String? selectedQuality = product.quality;
    DateTime selectedDate = product.createdAt;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(tr(ref, 'update_product_details')),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'product'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'description'),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'garment_category'),
                        border: const OutlineInputBorder(),
                      ),
                      items: const ['dress', 'blouse', 'trouser', 'set', 'jacket', 'skirt', 'shirt', 'pants', 'other'].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(tr(ref, type)),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedType = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedQuality,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'condition'),
                        border: const OutlineInputBorder(),
                      ),
                      items: const ['second_hand', 'new_condition', 'standard'].map((quality) {
                        return DropdownMenuItem(
                          value: quality,
                          child: Text(tr(ref, quality)),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedQuality = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: stockController,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'quantity'),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: purchasePriceController,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'purchase_price_unit'),
                        border: const OutlineInputBorder(),
                        suffixText: 'XAF',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'selling_price'),
                        border: const OutlineInputBorder(),
                        suffixText: 'XAF',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                        child: Text(_formatDate(selectedDate)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(tr(ref, 'cancel'))),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  setState(() => isSaving = true);
                  try {
                    final updated = Product.fromJson(product.toJson());
                    updated.name = nameController.text;
                    updated.description = descriptionController.text;
                    updated.price = double.tryParse(priceController.text) ?? product.price;
                    updated.purchasePrice = double.tryParse(purchasePriceController.text) ?? product.purchasePrice;
                    updated.stockQuantity = int.tryParse(stockController.text) ?? product.stockQuantity;
                    updated.productType = selectedType;
                    updated.quality = selectedQuality;
                    updated.createdAt = selectedDate;
                    updated.updatedAt = DateTime.now();
                    
                    await ref.read(productProvider.notifier).updateProduct(updated);
                    if (context.mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      _showProductDetail(updated);
                    }
                  } catch (e) {
                    setState(() => isSaving = false);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                child: Text(tr(ref, 'save')),
              ),
            ],
          );
        },
      ),
    );
  }
}
