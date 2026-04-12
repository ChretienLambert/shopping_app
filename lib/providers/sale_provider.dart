import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../repositories/sale_repository.dart';

class SaleNotifier extends StateNotifier<List<Sale>> {
  final _repository = SaleRepository();

  SaleNotifier() : super([]) {
    loadSales();
  }

  Future<void> loadSales() async {
    final sales = await _repository.getAll();
    state = sales..sort((a, b) => b.saleDate.compareTo(a.saleDate));
  }

  Future<void> addSale(Sale sale, List<SaleItem> items) async {
    await _repository.save(sale, items);
    await loadSales();
  }

  Future<void> updateSale(Sale sale) async {
    // Note: This only updates the sale header, not items
    await _repository.save(sale, []); 
    await loadSales();
  }

  Future<void> deleteSale(Sale sale) async {
    await _repository.softDelete(sale);
    await loadSales();
  }

  Future<Sale?> getSaleById(int id) async {
    final sales = await _repository.getAll();
    try {
      return sales.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    return await _repository.getSaleItems(saleId);
  }

  Future<double> getTotalSales() async {
    final List<Sale> sales = await _repository.getAll();
    double total = 0.0;
    for (var sale in sales) {
      total += sale.totalAmount;
    }
    return total;
  }

  Future<double> getSalesToday() async {
    final List<Sale> sales = await _repository.getAll();
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    double total = 0.0;
    for (var sale in sales) {
      if (sale.saleDate.isAfter(startOfDay) || sale.saleDate.isAtSameMomentAs(startOfDay)) {
        total += sale.totalAmount;
      }
    }
    return total;
  }

  Future<double> getSalesThisMonth() async {
    final List<Sale> sales = await _repository.getAll();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    double total = 0.0;
    for (var sale in sales) {
      if (sale.saleDate.isAfter(startOfMonth) || sale.saleDate.isAtSameMomentAs(startOfMonth)) {
        total += sale.totalAmount;
      }
    }
    return total;
  }
}

final saleProvider = StateNotifierProvider<SaleNotifier, List<Sale>>((ref) {
  return SaleNotifier();
});
