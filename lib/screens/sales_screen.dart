import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../providers/sale_provider.dart';
import '../providers/product_provider.dart';
import '../providers/customer_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';
import '../utils/app_localization.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  String? _validationError;

  @override
  Widget build(BuildContext context) {
    final sales = ref.watch(saleProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: sales.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.point_of_sale_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sales yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to record your first sale',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return _buildSaleCard(sale);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSaleDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return FutureBuilder<Customer?>(
      future: sale.customerId > 0 ? ref.read(customerProvider.notifier).getCustomerById(sale.customerId) : Future.value(null),
      builder: (context, snapshot) {
        final customer = snapshot.data;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              child: Icon(
                sale.isDelivery ? Icons.local_shipping_rounded : Icons.sell_rounded,
                color: AppTheme.primaryBlue,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyUtils.format(sale.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                if (sale.operationId != null)
                  Text(
                    sale.operationId!,
                    style: TextStyle(color: AppTheme.slate400, fontSize: 11),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.slate500),
                    const SizedBox(width: 4),
                    Text('${_formatDate(sale.saleDate)} • ${_formatTime(sale.saleDate)}', style: TextStyle(color: AppTheme.slate500)),
                  ],
                ),
                if (customer != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline_rounded, size: 12, color: AppTheme.slate500),
                        const SizedBox(width: 4),
                        Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                if (sale.isDelivery && sale.deliveryAddress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: AppTheme.slate500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            sale.deliveryAddress!,
                            style: TextStyle(color: AppTheme.slate500, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sale.isDelivery && sale.lifecycleStatus == SaleLifecycleStatus.pending)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                    tooltip: 'Confirm Paid',
                    onPressed: () async {
                      sale.lifecycleStatus = SaleLifecycleStatus.completed;
                      sale.isPaid = true;
                      await ref.read(saleProvider.notifier).updateSale(sale);
                    },
                  ),
                Icon(Icons.chevron_right_rounded, color: AppTheme.slate300),
              ],
            ),
            onTap: () => _showSaleDetailsDialog(sale),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(Sale sale) {
    Color color;
    switch (sale.lifecycleStatus) {
      case SaleLifecycleStatus.completed:
        color = Colors.green;
        break;
      case SaleLifecycleStatus.pending:
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        sale.status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showSaleDialog() async {
    final products = ref.read(productProvider);
    final existingSales = ref.read(saleProvider);
    
    // Step 0: Choose Sale Type
    final isDelivery = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'new_sale_type')),
        content: Text(tr(ref, 'is_this_direct_or_delivery')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.storefront_rounded), SizedBox(width: 8), Text(tr(ref, 'direct_sale'))],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.local_shipping_rounded), SizedBox(width: 8), Text(tr(ref, 'delivery'))],
            ),
          ),
        ],
      ),
    );

    if (isDelivery == null) return;
    if (!mounted) return;

    Customer? selectedCustomer;
    final List<SaleItem> saleItems = [];
    double discountPercent = 0;
    final notesController = TextEditingController();
    final deliveryAddressController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isDelivery ? 'New Delivery Sale' : 'Direct Store Sale'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Customer>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Select Customer',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: ref.watch(customerProvider).map((customer) {
                            return DropdownMenuItem(
                              value: customer,
                              child: Text(customer.name),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => selectedCustomer = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () => _addCustomerOnSpot(context, ref, (newCustomer) {
                          setState(() => selectedCustomer = newCustomer);
                        }),
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                      ),
                    ],
                  ),
                  if (selectedCustomer != null) ...[
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final stats = _getCustomerLoyaltyStats(
                          selectedCustomer!.id,
                          existingSales,
                        );
                        if (!stats['isRegular']) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.loyalty_rounded, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Regular client (${stats['completedSales']} purchases)',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<double>(
                      initialValue: discountPercent,
                      decoration: const InputDecoration(
                        labelText: 'Optional Discount',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text(tr(ref, 'no_discount'))),
                        DropdownMenuItem(value: 5, child: Text(tr(ref, 'five_percent'))),
                        DropdownMenuItem(value: 10, child: Text(tr(ref, 'ten_percent'))),
                        DropdownMenuItem(value: 15, child: Text(tr(ref, 'fifteen_percent'))),
                        DropdownMenuItem(value: 20, child: Text(tr(ref, 'twenty_percent'))),
                      ],
                      onChanged: (value) {
                        setState(() => discountPercent = value ?? 0);
                      },
                    ),
                  ],
                  if (isDelivery) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: deliveryAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(tr(ref, 'inventory_selection'), style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.slate200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: products.where((p) => p.stockQuantity > 0).length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: AppTheme.slate100),
                      itemBuilder: (context, index) {
                        final productFiltered = products.where((p) => p.stockQuantity > 0).toList();
                        final product = productFiltered[index];
                        final item = saleItems.firstWhere((i) => i.productId == product.id, orElse: () => SaleItem()..quantity = 0);
                        
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                          title: Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: Text('${CurrencyUtils.format(product.price)} • Stock: ${product.stockQuantity}', style: const TextStyle(fontSize: 11)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red, size: 24),
                                onPressed: item.quantity > 0 ? () => setState(() {
                                  final idx = saleItems.indexWhere((i) => i.productId == product.id);
                                  if (saleItems[idx].quantity > 1) {
                                    saleItems[idx].quantity--;
                                    saleItems[idx].totalPrice = saleItems[idx].quantity * saleItems[idx].unitPrice;
                                  } else {
                                    saleItems.removeAt(idx);
                                  }
                                }) : null,
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green, size: 24),
                                onPressed: product.stockQuantity > item.quantity ? () => setState(() {
                                  final idx = saleItems.indexWhere((i) => i.productId == product.id);
                                  if (idx != -1) {
                                    saleItems[idx].quantity++;
                                    saleItems[idx].totalPrice = saleItems[idx].quantity * saleItems[idx].unitPrice;
                                  } else {
                                    saleItems.add(SaleItem()
                                      ..productId = product.id
                                      ..quantity = 1
                                      ..unitPrice = product.price
                                      ..totalPrice = product.price);
                                  }
                                }) : null,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr(ref, 'subtotal')),
                            Text(
                              CurrencyUtils.format(
                                saleItems.fold(0.0, (sum, i) => sum + i.totalPrice),
                              ),
                            ),
                          ],
                        ),
                        if (discountPercent > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${tr(ref, 'discount')} (${discountPercent.toStringAsFixed(0)}%)'),
                              Text(
                                '-${CurrencyUtils.format((saleItems.fold(0.0, (sum, i) => sum + i.totalPrice) * discountPercent) / 100)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr(ref, 'grand_total'), style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              CurrencyUtils.format(
                                saleItems.fold(0.0, (sum, i) => sum + i.totalPrice) *
                                    (1 - (discountPercent / 100)),
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryBlue,
                                fontSize: 18,
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
              onPressed: saleItems.isEmpty ? null : () async {
                setState(() => _validationError = null);
                
                // Validation: Must select a customer
                if (selectedCustomer == null) {
                  setState(() => _validationError = 'Please select a customer for this sale');
                  return;
                }

                final subtotal = saleItems.fold(0.0, (sum, i) => sum + i.totalPrice);
                final discountAmount = subtotal * (discountPercent / 100);
                final finalTotal = subtotal - discountAmount;
                final sale = Sale()
                  ..customerId = selectedCustomer?.id ?? 0
                  ..totalAmount = finalTotal
                  ..notes = notesController.text
                  ..isDelivery = isDelivery
                  ..deliveryAddress = deliveryAddressController.text
                  ..metadataJson = jsonEncode({
                    'subtotal': subtotal,
                    'discountPercent': discountPercent,
                    'discountAmount': discountAmount,
                  })
                  ..lifecycleStatus = isDelivery
                      ? SaleLifecycleStatus.pending
                      : SaleLifecycleStatus.completed
                  ..isPaid = !isDelivery;

                await ref.read(saleProvider.notifier).addSale(sale, saleItems);
                
                // Stock update is handled by the repository/service usually, 
                // but let's ensure it's triggered.
                for (var item in saleItems) {
                   final p = await ref.read(productProvider.notifier).getProductById(item.productId);
                   if (p != null) {
                     p.stockQuantity -= item.quantity;
                     await ref.read(productProvider.notifier).updateProduct(p);
                   }
                }
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
              child: Text(tr(ref, 'confirm_sale')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addCustomerOnSpot(BuildContext context, WidgetRef ref, Function(Customer) onAdded) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    final result = await showDialog<Customer>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'quick_add_customer')),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController, 
                decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController, 
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(tr(ref, 'cancel'))),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final customer = Customer()..name = nameController.text..phoneNumber = phoneController.text;
                await ref.read(customerProvider.notifier).addCustomer(customer);
                if (context.mounted) Navigator.pop(context, customer);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            child: Text(tr(ref, 'save')),
          ),
        ],
      ),
    );

    if (result != null) {
      onAdded(result);
    }
  }

  Future<void> _showSaleDetailsDialog(Sale sale) async {
    final saleItems = await ref.read(saleProvider.notifier).getSaleItems(sale.id);
    final customer = sale.customerId > 0 
        ? await ref.read(customerProvider.notifier).getCustomerById(sale.customerId) 
        : null;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(tr(ref, 'sale_details')),
            const Spacer(),
            _buildStatusBadge(sale),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sale.operationId != null)
                _buildDetailRow('Operation ID', sale.operationId!),
              _buildDetailRow('Date', '${_formatDate(sale.saleDate)} at ${_formatTime(sale.saleDate)}'),
              _buildDetailRow('Total', CurrencyUtils.format(sale.totalAmount)),
              if (customer != null) _buildDetailRow('Customer', customer.name),
              _buildDetailRow(
                'Type',
                sale.saleType == SaleType.delivery ? 'Delivery' : 'Store',
              ),
              _buildDetailRow(
                'Payment',
                sale.isPaid ? 'Paid' : 'Pending Payment',
              ),
              ..._buildDiscountRows(sale),
              if (sale.isDelivery) ...[
                _buildDetailRow('Delivery', 'Yes'),
                if (sale.deliveryAddress != null) _buildDetailRow('Address', sale.deliveryAddress!),
              ],
              const Divider(height: 32),
              Text(tr(ref, 'items'), style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...saleItems.map((item) {
                return FutureBuilder<Product?>(
                  future: ref.read(productProvider.notifier).getProductById(item.productId),
                  builder: (context, snapshot) {
                    final product = snapshot.data;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(product?.name ?? 'Product ${item.productId}'),
                      subtitle: Text('${item.quantity} x ${CurrencyUtils.format(item.unitPrice)}'),
                      trailing: Text(CurrencyUtils.format(item.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                );
              }),
            ],
          ),
        ),
        actions: [
          if (sale.isDelivery && sale.lifecycleStatus == SaleLifecycleStatus.pending)
            ElevatedButton.icon(
              onPressed: () async {
                sale.lifecycleStatus = SaleLifecycleStatus.completed;
                sale.isPaid = true;
                await ref.read(saleProvider.notifier).updateSale(sale);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(tr(ref, 'confirm_paid')),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr(ref, 'close')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.slate500, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCustomerLoyaltyStats(int customerId, List<Sale> sales) {
    final customerSales = sales.where((sale) => sale.customerId == customerId).toList();
    final completedSales = customerSales.where((sale) => sale.isPaid).length;
    final totalSpent = customerSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    return {
      'completedSales': completedSales,
      'totalSpent': totalSpent,
      'isRegular': completedSales >= 3,
    };
  }

  List<Widget> _buildDiscountRows(Sale sale) {
    if (sale.metadataJson == null || sale.metadataJson!.isEmpty) return [];
    try {
      final metadata = jsonDecode(sale.metadataJson!) as Map<String, dynamic>;
      final discountPercent = (metadata['discountPercent'] as num?)?.toDouble() ?? 0;
      final discountAmount = (metadata['discountAmount'] as num?)?.toDouble() ?? 0;
      if (discountPercent <= 0) return [];
      return [
        _buildDetailRow('Discount', '${discountPercent.toStringAsFixed(0)}%'),
        _buildDetailRow('Discount Value', CurrencyUtils.format(discountAmount)),
      ];
    } catch (_) {
      return [];
    }
  }
}

