import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localization.dart';

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
                    'No customers yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first customer',
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
                return _buildCustomerCard(customer);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phoneNumber != null)
              Row(
                children: [
                   Icon(Icons.phone, size: 14, color: AppTheme.slate500),
                  const SizedBox(width: 4),
                  Text(customer.phoneNumber!),
                ],
              ),
            if (customer.email != null)
              Row(
                children: [
                   Icon(Icons.email, size: 14, color: AppTheme.slate500),
                  const SizedBox(width: 4),
                  Text(
                    customer.email!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmDelete(customer),
        ),
        onTap: () => _showCustomerDialog(customer: customer),
      ),
    );
  }

  Future<void> _confirmDelete(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tr(ref, 'delete')}?'),
        content: Text('${tr(ref, 'are_you_sure_delete_customer')} ${customer.name}? ${tr(ref, 'hide_from_active')}'),
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

  Future<void> _showCustomerDialog({Customer? customer}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phoneNumber ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final addressController = TextEditingController(text: customer?.address ?? '');
    final notesController = TextEditingController(text: customer?.notes ?? '');

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer == null ? 'Add Customer' : 'Edit Customer'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixText: '+',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                     // Allow only digits and +
                     FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
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
                  newCustomer.serverId = customer.serverId; // Keep serverId
                  await ref.read(customerProvider.notifier).updateCustomer(newCustomer);
                } else {
                  await ref.read(customerProvider.notifier).addCustomer(newCustomer);
                }

                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            child: Text(customer == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}
