import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/customer.dart';
import '../models/expense.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/user.dart';
import '../models/weekly_checkup.dart';

class IsarService {
  static IsarService? _instance;
  static IsarService get instance => _instance ??= IsarService._();

  IsarService._();

  Isar? _isar;

  Future<Isar> get isar async {
    if (_isar != null) return _isar!;
    await init();
    return _isar!;
  }

  Future<void> init() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    
    _isar = await Isar.open(
      [
        CustomerSchema,
        ExpenseSchema,
        ProductSchema,
        SaleSchema,
        SaleItemSchema,
        UserSchema,
        WeeklyCheckupSchema,
      ],
      directory: dir.path,
      inspector: true,
    );
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  Future<void> clearAllData() async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.clear();
    });
  }

  Future<void> seedClothingShopData() async {
    final db = await isar;
    
    await db.writeTxn(() async {
      // 1. Add Customers
      final customers = [
        Customer()..name = 'Jean-Paul Biya'..phoneNumber = '+237 600000000'..email = 'jp@cam.com'..address = 'Bastos, Yaoundé',
        Customer()..name = 'Marie Claire'..phoneNumber = '+237 611111111'..email = 'marie@cam.com'..address = 'Akwa, Douala',
        Customer()..name = 'Oumarou Sali'..phoneNumber = '+237 622222222'..email = 'oumarou@cam.com'..address = 'Garoua',
      ];
      await db.customers.putAll(customers);

      // 2. Add Fashion Products
      final products = [
        Product()
          ..name = 'Premium Slim Fit Jeans'
          ..description = 'High-quality denim with a modern slim cut. Durable and stylish.'
          ..price = 15000.0
          ..stockQuantity = 45
          ..imagePath = 'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&q=80&w=800',
        Product()
          ..name = 'Yaoundé Urban T-Shirt'
          ..description = '100% Cotton, locally inspired urban design.'
          ..price = 5600.0
          ..stockQuantity = 120
          ..imagePath = 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&q=80&w=800',
        Product()
          ..name = 'Traditional Embroidered Kaftan'
          ..description = 'Hand-embroidered luxury kaftan for special occasions.'
          ..price = 45000.0
          ..stockQuantity = 15
          ..imagePath = 'https://images.unsplash.com/photo-1583311123963-3d0d6213797c?auto=format&fit=crop&q=80&w=800',
        Product()
          ..name = 'Leather Loafers (Brown)'
          ..description = 'Genuine leather loafers, comfortable for daily wear.'
          ..price = 28000.0
          ..stockQuantity = 25
          ..imagePath = 'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&q=80&w=800',
        Product()
          ..name = 'Silk Evening Scarf'
          ..description = 'Elegant silk scarf with vibrant African patterns.'
          ..price = 8500.0
          ..stockQuantity = 60
          ..imagePath = 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?auto=format&fit=crop&q=80&w=800',
      ];
      await db.products.putAll(products);
    });
  }
}
