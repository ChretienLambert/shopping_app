import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';
import '../providers/sale_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localization.dart';
import '../utils/currency_utils.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: customers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr(ref, 'no_customers_yet'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(ref, 'tap_to_add_customer'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return _CustomerExpandableCard(
                  customer: customer,
                  onEdit: () => _showCustomerDialog(customer: customer),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCustomerDialog({Customer? customer}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phoneNumber ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final addressController = TextEditingController(text: customer?.address ?? '');
    final notesController = TextEditingController(text: customer?.notes ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer == null ? tr(ref, 'add_customer') : tr(ref, 'edit_customer')),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '${tr(ref, 'name')} *',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? tr(ref, 'required') : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: tr(ref, 'phone'),
                    border: const OutlineInputBorder(),
                    prefixText: '+',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: tr(ref, 'email'),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: tr(ref, 'address'),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: tr(ref, 'notes'),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
                final newCustomer = Customer()
                  ..name = nameController.text
                  ..phoneNumber = phoneController.text.isEmpty ? null : phoneController.text
                  ..email = emailController.text.isEmpty ? null : emailController.text
                  ..address = addressController.text.isEmpty ? null : addressController.text
                  ..notes = notesController.text.isEmpty ? null : notesController.text;

                if (customer != null) {
                  newCustomer.id = customer.id;
                  newCustomer.serverId = customer.serverId;
                  await ref.read(customerProvider.notifier).updateCustomer(newCustomer);
                } else {
                  await ref.read(customerProvider.notifier).addCustomer(newCustomer);
                }

                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            child: Text(customer == null ? tr(ref, 'add') : tr(ref, 'update')),
          ),
        ],
      ),
    );
  }
}

class _CustomerExpandableCard extends ConsumerStatefulWidget {
  final Customer customer;
  final VoidCallback onEdit;
  const _CustomerExpandableCard({required this.customer, required this.onEdit});

  @override
  ConsumerState<_CustomerExpandableCard> createState() => _CustomerExpandableCardState();
}

class _CustomerExpandableCardState extends ConsumerState<_CustomerExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final allSales = ref.watch(saleProvider);
    final customerSales = allSales
        .where((s) => s.customerId == customer.id && s.deletedAt == null)
        .toList()
      ..sort((a, b) => b.saleDate.compareTo(a.saleDate));

    final totalSpent = customerSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: _isExpanded ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : [],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryBlue,
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              customer.phoneNumber ?? tr(ref, 'no_phone'),
              style: TextStyle(color: AppTheme.slate500, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: widget.onEdit,
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppTheme.slate400,
                ),
              ],
            ),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(tr(ref, 'total_spent'), CurrencyUtils.format(totalSpent), Colors.green),
                      _buildStatItem(tr(ref, 'purchases'), customerSales.length.toString(), AppTheme.primaryBlue),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (customer.email != null && customer.email!.isNotEmpty)
                    _buildInfoRow(Icons.email_outlined, customer.email!),
                  if (customer.address != null && customer.address!.isNotEmpty)
                    _buildInfoRow(Icons.location_on_outlined, customer.address!),
                  if (customer.notes != null && customer.notes!.isNotEmpty)
                    _buildInfoRow(Icons.notes, customer.notes!),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tr(ref, 'recent_purchases'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      if (customerSales.isNotEmpty)
                        Text(
                          '${tr(ref, 'last')}: ${_formatDate(customerSales.first.saleDate)}',
                          style: TextStyle(color: AppTheme.slate400, fontSize: 11),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (customerSales.isEmpty)
                    Text(tr(ref, 'no_purchases_yet'), style: TextStyle(color: AppTheme.slate400, fontSize: 12))
                  else
                    ...customerSales.take(3).map((sale) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(sale.operationId, style: const TextStyle(fontSize: 12)),
                              Text(CurrencyUtils.format(sale.totalAmount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(customer),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(tr(ref, 'delete_customer')),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppTheme.slate500, fontSize: 11)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.slate400),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  Future<void> _confirmDelete(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tr(ref, 'delete')}?'),
        content: Text('${tr(ref, 'are_you_sure_delete_customer')} ${customer.name}?'),
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
      await ref.read(customerProvider.notifier).deleteCustomer(customer);
    }
  }
}
