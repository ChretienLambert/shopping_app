import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product.dart';
import '../models/expense.dart';
import '../providers/product_provider.dart';
import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localization.dart';
import '../utils/currency_utils.dart';
import '../widgets/smart_image.dart';
import '../services/storage_service.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final List<String> _productCategories = const [
    'dress',
    'blouse',
    'trouser',
    'set',
    'jacket',
    'skirt',
    'shirt',
    'pants',
    'other',
  ];

  String? _selectedFilterCategory;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final filteredProducts = _selectedFilterCategory == null
        ? products
        : products
            .where((p) => p.productType?.toLowerCase() == _selectedFilterCategory)
            .toList();

    final stockCount =
        filteredProducts.fold<int>(0, (sum, product) => sum + product.stockQuantity);
    final lowStockCount =
        filteredProducts.where((product) => product.stockQuantity > 0 && product.stockQuantity < 5).length;
    final outOfStockCount =
        filteredProducts.where((product) => product.stockQuantity == 0).length;

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, isMobile ? 16 : 24, isMobile ? 16 : 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile)
                  Text(
                    tr(ref, 'catalogs'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                if (!isMobile) const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _summaryChip(
                        context,
                        label: tr(ref, 'stock_items'),
                        value: '${filteredProducts.length}',
                      ),
                      const SizedBox(width: 10),
                      _summaryChip(
                        context,
                        label: tr(ref, 'stock_quantity'),
                        value: '$stockCount',
                      ),
                      const SizedBox(width: 10),
                      _summaryChip(
                        context,
                        label: tr(ref, 'low_stock_items'),
                        value: '$lowStockCount',
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      _summaryChip(
                        context,
                        label: tr(ref, 'out_of_stock'),
                        value: '$outOfStockCount',
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildCategoryFilter(isMobile),
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: EdgeInsets.fromLTRB(isMobile ? 12 : 16, 8, isMobile ? 12 : 16, 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 1200
                          ? 4
                          : screenWidth > 820
                              ? 3
                              : 2,
                      childAspectRatio: isMobile ? (screenWidth < 380 ? 0.58 : 0.65) : 0.72,
                      crossAxisSpacing: isMobile ? 10 : 14,
                      mainAxisSpacing: isMobile ? 10 : 14,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(filteredProducts[index], isMobile);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(
    BuildContext context, {
    required String label,
    required String value,
    Color? color,
  }) {
    final accent = color ?? AppTheme.primaryBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(bool isMobile) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
        itemCount: _productCategories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : _productCategories[index - 1];
          final isSelected = _selectedFilterCategory == category;

          return ChoiceChip(
            label: Text(isAll ? tr(ref, 'all') : tr(ref, category!).replaceAll('_', ' ')),
            selected: isSelected,
            onSelected: (selected) {
              setState(() => _selectedFilterCategory = selected ? category : null);
            },
            showCheckmark: false,
            selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.14),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryBlue : null,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                  : Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isMobile) {
    final stockColor = product.stockQuantity == 0
        ? Colors.redAccent
        : product.stockQuantity < 5
            ? Colors.orange
            : Colors.green;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showProductDetail(product),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: isMobile ? 5 : 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: SmartImage(
                        imagePath: product.imagePath,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(16)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          CurrencyUtils.format(product.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryBlue,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.productType != null)
                             Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tr(ref, product.productType!.toLowerCase()).replaceAll('_', ' '),
                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: isMobile ? 5 : 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 12, color: stockColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${product.stockQuantity} ${tr(ref, 'units')}',
                              style: TextStyle(
                                fontSize: 11,
                                color: stockColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description.isNotEmpty ? product.description : tr(ref, 'no_description_provided'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.slate500,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          CurrencyUtils.format(product.purchasePrice),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 52, color: AppTheme.slate300),
          const SizedBox(height: 16),
          Text(
            tr(ref, 'no_products_found'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            tr(ref, 'add_stock_from_expenses'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showProductDetail(Product product) {
    final stockColor = product.stockQuantity == 0
        ? Colors.redAccent
        : product.stockQuantity < 5
            ? Colors.orange
            : Colors.green;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.74,
        minChildSize: 0.48,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                      child: SmartImage(
                        imagePath: product.imagePath,
                        width: double.infinity,
                        height: 260,
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(28)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.08),
                            Colors.black.withValues(alpha: 0.68),
                          ],
                        ),
                      ),
                      child: const SizedBox(height: 260),
                    ),
                    Positioned(
                      top: 14,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 18,
                      right: 18,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black.withValues(alpha: 0.38),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (product.productType != null)
                                _heroChip(tr(ref, product.productType!.toLowerCase()).replaceAll('_', ' ')),
                              _heroChip(
                                product.stockQuantity == 0
                                    ? tr(ref, 'out_of_stock')
                                    : '${product.stockQuantity} ${tr(ref, 'units')}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            product.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyUtils.format(product.price),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double cardWidth = (constraints.maxWidth - 12) / 2;
                          final bool wrapCards = constraints.maxWidth < 320;
                          
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: wrapCards ? constraints.maxWidth : cardWidth,
                                child: _detailMetricCard(
                                  icon: Icons.inventory_2_outlined,
                                  label: tr(ref, 'stock_level'),
                                  value: '${product.stockQuantity} ${tr(ref, 'units')}',
                                  color: stockColor,
                                ),
                              ),
                              SizedBox(
                                width: wrapCards ? constraints.maxWidth : cardWidth,
                                child: _detailMetricCard(
                                  icon: Icons.calendar_today_outlined,
                                  label: tr(ref, 'date'),
                                  value: _formatDate(product.createdAt),
                                  color: AppTheme.slate600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('Pricing'),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                           final double cardWidth = (constraints.maxWidth - 12) / 2;
                           final bool wrapCards = constraints.maxWidth < 350;

                           return Wrap(
                             spacing: 12,
                             runSpacing: 12,
                             children: [
                               SizedBox(
                                 width: wrapCards ? constraints.maxWidth : cardWidth,
                                 child: _priceCard(
                                   title: tr(ref, 'purchase_price_unit'),
                                   value: CurrencyUtils.format(product.purchasePrice),
                                   subtitle: 'Managed from stock expenses',
                                   accent: AppTheme.slate500,
                                 ),
                               ),
                               SizedBox(
                                 width: wrapCards ? constraints.maxWidth : cardWidth,
                                 child: _priceCard(
                                   title: tr(ref, 'selling_price'),
                                   value: CurrencyUtils.format(product.price),
                                   subtitle: 'This is the editable resale price',
                                   accent: AppTheme.primaryBlue,
                                 ),
                               ),
                             ],
                           );
                        },
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(tr(ref, 'product_details')),
                      const SizedBox(height: 10),
                      _detailBlock(
                        label: tr(ref, 'description'),
                        value: product.description.isEmpty
                            ? tr(ref, 'no_description_provided')
                            : product.description,
                      ),
                      if (product.quality != null) ...[
                        const SizedBox(height: 12),
                        _detailBlock(
                          label: tr(ref, 'condition'),
                          value: tr(ref, product.quality!.toLowerCase()),
                        ),
                      ],
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.primaryBlue,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'You can adjust stock quantity and resale price here. Purchase cost stays managed from stock expenses.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 12,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showProductAdjustmentsDialog(product),
                          icon: const Icon(Icons.tune_rounded),
                          label: const Text('Update stock and resale price'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _heroChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _detailMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.slate500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCard({
    required String title,
    required String value,
    required String subtitle,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.slate500,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.slate500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String label) {
    return Text(
      label,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
    );
  }

  Widget _detailBlock({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.slate500,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showProductAdjustmentsDialog(Product product) {
    final resaleController = TextEditingController(text: product.price.toString());
    final stockController =
        TextEditingController(text: product.stockQuantity.toString());
    String? newImagePath = product.imagePath;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Update stock and resale price'),
            content: SizedBox(
              width: 380,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                         final ImagePicker picker = ImagePicker();
                         final source = await showModalBottomSheet<ImageSource>(
                           context: context,
                           builder: (context) => SafeArea(
                             child: Wrap(
                               children: [
                                 ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
                                 ListTile(leading: const Icon(Icons.photo_camera), title: const Text('Camera'), onTap: () => Navigator.pop(context, ImageSource.camera)),
                               ],
                             ),
                           ),
                         );
                         if (source != null) {
                           final file = await picker.pickImage(
                             source: source,
                             maxWidth: 1200,
                             maxHeight: 1200,
                             imageQuality: 85,
                           );
                           if (file != null) {
                             setState(() => newImagePath = file.path);
                           }
                         }
                      },
                      child: Center(
                        child: SmartImage(
                          imagePath: newImagePath,
                          width: 120,
                          height: 120,
                          borderRadius: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.slate100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${tr(ref, 'purchase_price_unit')}: ${CurrencyUtils.format(product.purchasePrice)}',
                            style: TextStyle(
                              color: AppTheme.slate600,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'stock_quantity'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: resaleController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: tr(ref, 'selling_price'),
                        border: const OutlineInputBorder(),
                        suffixText: 'XAF',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(tr(ref, 'cancel')),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final parentNavigator = Navigator.of(this.context);
                        final dialogNavigator = Navigator.of(dialogContext);
                        setState(() => isSaving = true);
                        try {
                          final updated = Product.fromJson(product.toJson());
                          updated.stockQuantity =
                              int.tryParse(stockController.text) ?? product.stockQuantity;
                          updated.price =
                              double.tryParse(resaleController.text) ?? product.price;
                          
                          if (newImagePath != product.imagePath) {
                             final savedPath = await storageService.saveLocalImage(newImagePath!, 'products');
                             updated.imagePath = savedPath;
                          }
                          
                          updated.updatedAt = DateTime.now();

                          await ref.read(productProvider.notifier).updateProduct(updated);
                          
                          // Also try to update the associated expense image if it was a direct match
                          final expenses = ref.read(expenseProvider);
                          final relatedExpense = expenses.where((e) => 
                            e.category == ExpenseCategory.stock && 
                            e.stockProductName?.trim().toLowerCase() == product.name.trim().toLowerCase()
                          ).toList();
                          
                          for (var e in relatedExpense) {
                            e.stockImagePath = updated.imagePath;
                            await ref.read(expenseProvider.notifier).updateExpense(e);
                          }

                          if (!mounted) return;
                          dialogNavigator.pop();
                          parentNavigator.pop();
                          _showProductDetail(updated);
                        } catch (_) {
                          setState(() => isSaving = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text(tr(ref, 'save')),
              ),
            ],
          );
        },
      ),
    );
  }
}
