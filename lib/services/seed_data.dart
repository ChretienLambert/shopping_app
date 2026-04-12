import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/expense.dart';
import '../services/isar_service.dart';

class SeedDataService {
  static Future<void> seedDummyData() async {
    final isar = await IsarService.instance.isar;
    
    // Check if data already exists
    final existingProducts = await isar.products.count();
    if (existingProducts > 0) return; // Data already seeded
    
    await isar.writeTxn(() async {
      // Seed Products - Clothing items with Cameroon Franc pricing
      final products = [
        Product()
          ..name = 'Men\'s Cotton T-Shirt'
          ..description = '100% cotton premium t-shirt, comfortable and breathable'
          ..price = 15000.0 // XAF
          ..stockQuantity = 45
          ..imagePath = null,
        Product()
          ..name = 'Women\'s Blouse'
          ..description = 'Elegant chiffon blouse with floral patterns'
          ..price = 25000.0 // XAF
          ..stockQuantity = 30
          ..imagePath = null,
        Product()
          ..name = 'Men\'s Dress Shirt'
          ..description = 'Classic fit dress shirt, perfect for formal occasions'
          ..price = 35000.0 // XAF
          ..stockQuantity = 40
          ..imagePath = null,
        Product()
          ..name = 'Women\'s Maxi Dress'
          ..description = 'Flowing maxi dress with vibrant African prints'
          ..price = 45000.0 // XAF
          ..stockQuantity = 25
          ..imagePath = null,
        Product()
          ..name = 'Denim Jeans'
          ..description = 'Classic fit jeans, durable and stylish'
          ..price = 30000.0 // XAF
          ..stockQuantity = 60
          ..imagePath = null,
        Product()
          ..name = 'Sports Jersey'
          ..description = 'Breathable sports jersey, ideal for workouts'
          ..price = 20000.0 // XAF
          ..stockQuantity = 50
          ..imagePath = null,
        Product()
          ..name = 'Traditional Wrapper'
          ..description = 'Authentic African wrapper fabric, premium quality'
          ..price = 40000.0 // XAF
          ..stockQuantity = 35
          ..imagePath = null,
        Product()
          ..name = 'Kids\' T-Shirt'
          ..description = 'Comfortable cotton t-shirt for children'
          ..price = 12000.0 // XAF
          ..stockQuantity = 80
          ..imagePath = null,
        Product()
          ..name = 'Hoodie'
          ..description = 'Warm fleece hoodie, perfect for cool weather'
          ..price = 28000.0 // XAF
          ..stockQuantity = 45
          ..imagePath = null,
        Product()
          ..name = 'Polo Shirt'
          ..description = 'Classic polo shirt, casual and stylish'
          ..price = 22000.0 // XAF
          ..stockQuantity = 70
          ..imagePath = null,
      ];
      
      for (var product in products) {
        await isar.products.put(product);
      }
      
      // Seed Customers
      final customers = [
        Customer()
          ..name = 'John Smith'
          ..phoneNumber = '+1234567890'
          ..email = 'john.smith@email.com'
          ..address = '123 Main St, City, State 12345'
          ..notes = 'Regular customer, prefers premium products',
        Customer()
          ..name = 'Sarah Johnson'
          ..phoneNumber = '+1234567891'
          ..email = 'sarah.j@email.com'
          ..address = '456 Oak Ave, Town, State 67890'
          ..notes = 'New customer, interested in fitness products',
        Customer()
          ..name = 'Michael Brown'
          ..phoneNumber = '+1234567892'
          ..email = 'm.brown@email.com'
          ..address = '789 Pine Rd, Village, State 11223'
          ..notes = 'Bulk buyer for office supplies',
        Customer()
          ..name = 'Emily Davis'
          ..phoneNumber = '+1234567893'
          ..email = 'emily.d@email.com'
          ..address = '321 Elm St, Hamlet, State 33445'
          ..notes = null,
        Customer()
          ..name = 'Robert Wilson'
          ..phoneNumber = '+1234567894'
          ..email = 'rwilson@email.com'
          ..address = '654 Maple Dr, Borough, State 55667'
          ..notes = 'Prefers wireless accessories',
      ];
      
      for (var customer in customers) {
        await isar.customers.put(customer);
      }
      
      // Seed Expenses - Clothing shop related with XAF currency
      final expenses = [
        Expense()
          ..description = 'Facebook Ads Campaign'
          ..amount = 150000.0 // XAF
          ..category = ExpenseCategory.socialMedia
          ..expenseDate = DateTime.now().subtract(const Duration(days: 5))
          ..notes = 'Monthly advertising budget'
          ..receiptImagePath = null,
        Expense()
          ..description = 'Instagram Promoted Posts'
          ..amount = 90000.0 // XAF
          ..category = ExpenseCategory.socialMedia
          ..expenseDate = DateTime.now().subtract(const Duration(days: 3))
          ..notes = 'New collection promotion'
          ..receiptImagePath = null,
        Expense()
          ..description = 'Market Stand Rental'
          ..amount = 300000.0 // XAF
          ..category = ExpenseCategory.stand
          ..expenseDate = DateTime.now().subtract(const Duration(days: 7))
          ..notes = 'Weekend market booth at Douala'
          ..receiptImagePath = null,
        Expense()
          ..description = 'Delivery Vehicle Fuel'
          ..amount = 50000.0 // XAF
          ..category = ExpenseCategory.transportation
          ..expenseDate = DateTime.now().subtract(const Duration(days: 2))
          ..notes = 'Weekly delivery costs'
          ..receiptImagePath = null,
        Expense()
          ..description = 'Packaging Materials'
          ..amount = 75000.0 // XAF
          ..category = ExpenseCategory.supplies
          ..expenseDate = DateTime.now().subtract(const Duration(days: 10))
          ..notes = 'Bags, tags, and hangers'
          ..receiptImagePath = null,
        Expense()
          ..description = 'Shop Electricity'
          ..amount = 85000.0 // XAF
          ..category = ExpenseCategory.utilities
          ..expenseDate = DateTime.now().subtract(const Duration(days: 15))
          ..notes = 'Monthly utility payment'
          ..receiptImagePath = null,
        Expense()
          ..description = 'Shop Rent'
          ..amount = 500000.0 // XAF
          ..category = ExpenseCategory.rent
          ..expenseDate = DateTime.now().subtract(const Duration(days: 20))
          ..notes = 'Monthly rent payment'
          ..receiptImagePath = null,
        Expense()
          ..description = 'Radio Advertisement'
          ..amount = 200000.0 // XAF
          ..category = ExpenseCategory.marketing
          ..expenseDate = DateTime.now().subtract(const Duration(days: 8))
          ..notes = 'Weekly radio spot'
          ..receiptImagePath = null,
      ];
      
      for (var expense in expenses) {
        await isar.expenses.put(expense);
      }
      
      // Seed Sales - Clothing shop with XAF currency
      final now = DateTime.now();
      final sales = [
        Sale()
          ..customerId = 1
          ..totalAmount = 60000.0 // XAF - T-shirt + Blouse
          ..saleDate = now.subtract(const Duration(days: 1))
          ..notes = 'Customer bought T-shirt and blouse',
        Sale()
          ..customerId = 2
          ..totalAmount = 45000.0 // XAF - Maxi dress
          ..saleDate = now.subtract(const Duration(days: 2))
          ..notes = 'Maxi dress purchase',
        Sale()
          ..customerId = 3
          ..totalAmount = 90000.0 // XAF - Dress shirt + Jeans
          ..saleDate = now.subtract(const Duration(days: 3))
          ..notes = 'Bulk order for office uniforms',
        Sale()
          ..customerId = 1
          ..totalAmount = 35000.0 // XAF - Dress shirt
          ..saleDate = now.subtract(const Duration(days: 4))
          ..notes = 'Repeat customer',
        Sale()
          ..customerId = 4
          ..totalAmount = 40000.0 // XAF - Traditional wrapper
          ..saleDate = now.subtract(const Duration(days: 5))
          ..notes = null,
        Sale()
          ..customerId = 5
          ..totalAmount = 50000.0 // XAF - Jeans + Polo
          ..saleDate = now.subtract(const Duration(days: 6))
          ..notes = 'Casual wear bundle',
        Sale()
          ..customerId = 2
          ..totalAmount = 28000.0 // XAF - Hoodie
          ..saleDate = now.subtract(const Duration(hours: 12))
          ..notes = 'Hoodie purchase',
        Sale()
          ..customerId = 3
          ..totalAmount = 22000.0 // XAF - Polo shirt
          ..saleDate = now.subtract(const Duration(hours: 6))
          ..notes = 'Additional polo for office',
      ];
      
      for (var sale in sales) {
        await isar.sales.put(sale);
      }
      
      // Seed Sale Items - Clothing items with XAF prices
      final saleItems = [
        // Sale 1 items - T-shirt + Blouse
        SaleItem()..saleId = 1..productId = 1..quantity = 1..unitPrice = 15000.0..totalPrice = 15000.0,
        SaleItem()..saleId = 1..productId = 2..quantity = 1..unitPrice = 25000.0..totalPrice = 25000.0,
        // Sale 2 items - Maxi dress
        SaleItem()..saleId = 2..productId = 4..quantity = 1..unitPrice = 45000.0..totalPrice = 45000.0,
        // Sale 3 items - Dress shirt + Jeans
        SaleItem()..saleId = 3..productId = 3..quantity = 2..unitPrice = 35000.0..totalPrice = 70000.0,
        SaleItem()..saleId = 3..productId = 5..quantity = 1..unitPrice = 30000.0..totalPrice = 30000.0,
        // Sale 4 items - Dress shirt
        SaleItem()..saleId = 4..productId = 3..quantity = 1..unitPrice = 35000.0..totalPrice = 35000.0,
        // Sale 5 items - Traditional wrapper
        SaleItem()..saleId = 5..productId = 7..quantity = 1..unitPrice = 40000.0..totalPrice = 40000.0,
        // Sale 6 items - Jeans + Polo
        SaleItem()..saleId = 6..productId = 5..quantity = 1..unitPrice = 30000.0..totalPrice = 30000.0,
        SaleItem()..saleId = 6..productId = 10..quantity = 1..unitPrice = 22000.0..totalPrice = 22000.0,
        // Sale 7 items - Hoodie
        SaleItem()..saleId = 7..productId = 9..quantity = 1..unitPrice = 28000.0..totalPrice = 28000.0,
        // Sale 8 items - Polo shirt
        SaleItem()..saleId = 8..productId = 10..quantity = 1..unitPrice = 22000.0..totalPrice = 22000.0,
      ];
      
      for (var item in saleItems) {
        await isar.saleItems.put(item);
      }
    });
  }
}
