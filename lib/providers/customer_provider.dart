import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer.dart';
import '../repositories/customer_repository.dart';

class CustomerNotifier extends StateNotifier<List<Customer>> {
  final _repository = CustomerRepository();

  CustomerNotifier() : super([]) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    final customers = await _repository.getAll();
    state = customers;
  }

  Future<void> addCustomer(Customer customer) async {
    await _repository.save(customer);
    await loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await _repository.save(customer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(Customer customer) async {
    await _repository.softDelete(customer);
    await loadCustomers();
  }

  Future<Customer?> getCustomerById(int id) async {
    final List<Customer> customers = await _repository.getAll();
    try {
      return customers.firstWhere((Customer c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

final customerProvider = StateNotifierProvider<CustomerNotifier, List<Customer>>((ref) {
  return CustomerNotifier();
});
