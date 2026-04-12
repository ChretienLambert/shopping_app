import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../providers/sale_provider.dart';
import '../providers/product_provider.dart';
import '../providers/customer_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_utils.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
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
            title: Row(
              children: [
                Text(
                  CurrencyUtils.format(sale.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(sale),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.slate500),
                    const SizedBox(width: 4),
                    Text(_formatDate(sale.saleDate), style: TextStyle(color: AppTheme.slate500)),
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
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!sale.isLocked)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(sale),
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

  Future<void> _confirmDelete(Sale sale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sale?'),
        content: const Text('Are you sure you want to delete this sale record? It will be hidden from reports and history.'),
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
      await ref.read(saleProvider.notifier).deleteSale(sale);
    }
  }

  Widget _buildStatusBadge(Sale sale) {
    Color color;
    switch (sale.status.toLowerCase()) {
      case 'complete':
        color = Colors.green;
        break;
      case 'paid':
        color = AppTheme.primaryBlue;
        break;
      case 'delivered':
        color = Colors.indigo;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      default:
        color = AppTheme.slate500;
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

  Future<void> _showSaleDialog() async {
    final products = ref.read(productProvider);
    
    // Step 0: Choose Sale Type
    final isDelivery = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Sale Type'),
        content: const Text('Is this a direct store sale or a delivery?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.storefront_rounded), SizedBox(width: 8), Text('Direct Sale')],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.local_shipping_rounded), SizedBox(width: 8), Text('Delivery')],
            ),
          ),
        ],
      ),
    );

    if (isDelivery == null) return;
    if (!mounted) return;

    Customer? selectedCustomer;
    final List<SaleItem> saleItems = [];
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
                  const Text('Inventory Selection:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          CurrencyUtils.format(saleItems.fold(0.0, (sum, i) => sum + i.totalPrice)),
                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryBlue, fontSize: 18),
                        ),
                      ],
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
              onPressed: saleItems.isEmpty ? null : () async {
                final sale = Sale()
                  ..customerId = selectedCustomer?.id ?? 0
                  ..totalAmount = saleItems.fold(0.0, (sum, i) => sum + i.totalPrice)
                  ..notes = notesController.text
                  ..isDelivery = isDelivery
                  ..deliveryAddress = deliveryAddressController.text
                  ..status = isDelivery ? 'Pending' : 'Complete'
                  ..isPaid = true;

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
              child: const Text('Confirm Sale'),
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
        title: const Text('Quick Add Customer'),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final customer = Customer()..name = nameController.text..phoneNumber = phoneController.text;
                await ref.read(customerProvider.notifier).addCustomer(customer);
                if (context.mounted) Navigator.pop(context, customer);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            child: const Text('Save'),
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
            const Text('Sale Details'),
            const Spacer(),
            _buildStatusBadge(sale),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Date', _formatDate(sale.saleDate)),
              _buildDetailRow('Total', CurrencyUtils.format(sale.totalAmount)),
              if (customer != null) _buildDetailRow('Customer', customer.name),
              if (sale.isDelivery) ...[
                _buildDetailRow('Delivery', 'Yes'),
                if (sale.deliveryAddress != null) _buildDetailRow('Address', sale.deliveryAddress!),
              ],
              const Divider(height: 32),
              const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
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
          if (!sale.isLocked)
             TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Sale Record?'),
                    content: const Text('This will remove the sale from your active history. Items will be returned to stock only if you manually adjust them or implement return logic.'),
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
                  await ref.read(saleProvider.notifier).deleteSale(sale);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete Sale'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
}

