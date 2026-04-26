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

import 'package:uuid/uuid.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

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
                    tr(ref, 'no_sales_yet'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(ref, 'tap_to_add_sale'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return _buildSaleCard(sale, isMobile);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSaleDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSaleCard(Sale sale, bool isMobile) {
    return FutureBuilder<Customer?>(
      future: sale.customerId != '0' ? ref.read(customerProvider.notifier).getCustomerById(sale.customerId) : Future.value(null),
      builder: (context, snapshot) {
        final customer = snapshot.data;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.slate200),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 4),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                sale.isDelivery ? Icons.local_shipping_rounded : Icons.sell_rounded,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    CurrencyUtils.format(sale.totalAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                ),
                _buildStatusBadge(sale),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 10, color: AppTheme.slate500),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDate(sale.saleDate)} • ${_formatTime(sale.saleDate)}',
                      style: TextStyle(color: AppTheme.slate500, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sale.operationId,
                        style: TextStyle(color: AppTheme.slate400, fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (customer != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline_rounded, size: 11, color: AppTheme.slate500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            customer.name,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.slate300),
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
        tr(ref, sale.status.toLowerCase()),
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
    
    final isDelivery = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr(ref, 'new_sale_type')),
        content: Text(tr(ref, 'is_this_direct_or_delivery')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.storefront_rounded), SizedBox(width: 8), Text(tr(ref, 'direct_sale'))],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            child: Row(
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
    double discountAmount = 0;
    final discountController = TextEditingController();
    final notesController = TextEditingController();
    final deliveryAddressController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String searchQuery = '';
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isDelivery ? tr(ref, 'new_delivery_sale') : tr(ref, 'direct_store_sale')),
            content: SizedBox(
              width: double.maxFinite,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
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
                          decoration: InputDecoration(
                            labelText: tr(ref, 'select_customer'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person_outline),
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
                  const SizedBox(height: 16),
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
                        labelText: tr(ref, 'sale_date'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _formatDate(selectedDate),
                      ),
                    ),
                  ),
                  if (selectedCustomer != null) ...[
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final stats = _getCustomerLoyaltyStats(
                          selectedCustomer!.id,
                          existingSales,
                        );
                        final double totalSpent = stats['totalSpent'] as double;
                        if (totalSpent < 10000) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 16, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'this client has made ${CurrencyUtils.format(totalSpent)} as purchase',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'do you want to give him a little discount?',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: discountController,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'discount_amount'),
                        hintText: tr(ref, 'enter_discount_amount'),
                        border: const OutlineInputBorder(),
                        prefixText: 'XAF ',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      onChanged: (value) {
                        final amount = double.tryParse(value) ?? 0;
                        setState(() => discountAmount = amount);
                      },
                    ),
                  ],
                  if (isDelivery) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: deliveryAddressController,
                      decoration: InputDecoration(
                        labelText: tr(ref, 'delivery_address'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: '${tr(ref, 'notes')} (${tr(ref, 'optional')})',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(tr(ref, 'inventory_selection'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.slate200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.slate50,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: tr(ref, 'search_products'),
                              prefixIcon: const Icon(Icons.search, size: 20),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                            onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            itemCount: products.where((p) => p.stockQuantity > 0 && p.name.toLowerCase().contains(searchQuery)).length,
                            separatorBuilder: (context, index) => Divider(height: 1, color: AppTheme.slate100),
                            itemBuilder: (context, index) {
                              final productFiltered = products.where((p) => p.stockQuantity > 0 && p.name.toLowerCase().contains(searchQuery)).toList();
                              final product = productFiltered[index];
                              final existingIndex = saleItems.indexWhere((i) => i.productId == product.id);
                              final quantity = existingIndex != -1 ? saleItems[existingIndex].quantity : 0;
                              
                              return ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                title: Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                subtitle: Text('${CurrencyUtils.format(product.price)} • ${tr(ref, 'stock')}: ${product.stockQuantity}', style: const TextStyle(fontSize: 11)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (quantity > 0) ...[
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                                        onPressed: () => setState(() {
                                          final idx = saleItems.indexWhere((i) => i.productId == product.id);
                                          if (saleItems[idx].quantity > 1) {
                                            saleItems[idx].quantity--;
                                            saleItems[idx].totalPrice = saleItems[idx].quantity * saleItems[idx].unitPrice;
                                          } else {
                                            saleItems.removeAt(idx);
                                          }
                                        }),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      ),
                                    ],
                                    IconButton(
                                      icon: Icon(quantity > 0 ? Icons.add_circle : Icons.add_circle_outline, 
                                        color: quantity > 0 ? Colors.green : AppTheme.primaryBlue, 
                                        size: 22
                                      ),
                                      onPressed: product.stockQuantity > quantity ? () => setState(() {
                                        final idx = saleItems.indexWhere((i) => i.productId == product.id);
                                        if (idx != -1) {
                                          saleItems[idx].quantity++;
                                          saleItems[idx].totalPrice = saleItems[idx].quantity * saleItems[idx].unitPrice;
                                        } else {
                                          final newItem = SaleItem(id: const Uuid().v4());
                                          newItem.productId = product.id;
                                          newItem.quantity = 1;
                                          newItem.unitPrice = product.price;
                                          newItem.totalPrice = product.price;
                                          saleItems.add(newItem);
                                        }
                                      }) : null,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        if (saleItems.isNotEmpty) ...[
                          const Divider(height: 1),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                            child: Row(
                              children: [
                                Text('${tr(ref, 'items_in_cart')}: ${saleItems.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => setState(() => saleItems.clear()),
                                  child: Text(tr(ref, 'clear_all'), style: const TextStyle(color: Colors.red, fontSize: 11)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
                        if (discountAmount > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(tr(ref, 'discount')),
                              Text(
                                '-${CurrencyUtils.format(discountAmount)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr(ref, 'grand_total'), style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              CurrencyUtils.format(
                                saleItems.fold(0.0, (sum, i) => sum + i.totalPrice) - discountAmount,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
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
              onPressed: (saleItems.isEmpty || isSaving) ? null : () async {
                setState(() {
                  _validationError = null;
                  isSaving = true;
                });
                
                try {
                  if (selectedCustomer == null) {
                    setState(() {
                      _validationError = tr(ref, 'error_select_customer');
                      isSaving = false;
                    });
                    return;
                  }

                  final subtotal = saleItems.fold(0.0, (sum, i) => sum + i.totalPrice);
                  final finalTotal = subtotal - discountAmount;
                  final sale = Sale()
                    ..customerId = selectedCustomer!.id
                    ..totalAmount = finalTotal
                    ..saleDate = selectedDate
                    ..notes = notesController.text
                    ..isDelivery = isDelivery
                    ..deliveryAddress = deliveryAddressController.text
                    ..metadataJson = jsonEncode({
                      'subtotal': subtotal,
                      'discountAmount': discountAmount,
                    })
                    ..lifecycleStatus = isDelivery
                        ? SaleLifecycleStatus.pending
                        : SaleLifecycleStatus.completed
                    ..isPaid = !isDelivery;

                  await ref.read(saleProvider.notifier).addSale(sale, saleItems);
                  
                  for (var item in saleItems) {
                    final p = await ref.read(productProvider.notifier).getProductById(item.productId);
                    if (p != null) {
                      p.stockQuantity -= item.quantity;
                      await ref.read(productProvider.notifier).updateProduct(p);
                    }
                  }
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  setState(() {
                    _validationError = e.toString();
                    isSaving = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue, 
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.6),
              ),
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(tr(ref, 'confirm_sale')),
            ),
          ],
        );
        },
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
    final customer = sale.customerId != '0'
        ? await ref.read(customerProvider.notifier).getCustomerById(sale.customerId) 
        : null;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(tr(ref, 'sale_details'), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            _buildStatusBadge(sale),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Operation ID', sale.operationId),
              _buildDetailRow('Date', '${_formatDate(sale.saleDate)} at ${_formatTime(sale.saleDate)}',
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    onPressed: () => _editSaleDate(context, sale),
                  )),
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
              Text(tr(ref, 'items'), style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildDetailRow(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(color: AppTheme.slate500, fontSize: 13), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.end)),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editSaleDate(BuildContext context, Sale sale) async {
    DateTime selectedDate = sale.saleDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(sale.saleDate);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(tr(ref, 'edit_sale_date')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(tr(ref, 'select_date')),
                subtitle: Text(_formatDate(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
              ListTile(
                title: Text(tr(ref, 'select_time')),
                subtitle: Text('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(tr(ref, 'cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
              child: Text(tr(ref, 'save')),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      // Combine selected date and time
      final newDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Update the sale
      sale.saleDate = newDateTime;
      await ref.read(saleProvider.notifier).updateSale(sale);
      
      if (context.mounted) {
        Navigator.pop(context); // Close details dialog
        _showSaleDetailsDialog(sale); // Reopen with updated date
      }
    }
  }

  Map<String, dynamic> _getCustomerLoyaltyStats(String customerId, List<Sale> sales) {
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
      final discountAmount = (metadata['discountAmount'] as num?)?.toDouble() ?? 0;
      if (discountAmount <= 0) return [];
      return [
        _buildDetailRow('Discount', CurrencyUtils.format(discountAmount)),
      ];
    } catch (_) {
      return [];
    }
  }
}
