import 'package:hive_flutter/hive_flutter.dart';
import 'logging_service.dart';

class HiveService {
  static final HiveService instance = HiveService._();
  HiveService._();

  late Box<Map> productsBox;
  late Box<Map> customersBox;
  late Box<Map> salesBox;
  late Box<Map> expensesBox;
  late Box<Map> saleItemsBox;
  late Box weeklyCheckupsBox;
  late Box usersBox;
  late Box settingsBox;

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      
      productsBox = await Hive.openBox<Map>('products');
      customersBox = await Hive.openBox<Map>('customers');
      salesBox = await Hive.openBox<Map>('sales');
      expensesBox = await Hive.openBox<Map>('expenses');
      saleItemsBox = await Hive.openBox<Map>('sale_items');
      weeklyCheckupsBox = await Hive.openBox('weekly_checkups');
      usersBox = await Hive.openBox('users');
      settingsBox = await Hive.openBox('settings');
      
      logger.info('Hive initialized and boxes opened successfully');
    } catch (e, stack) {
      logger.error('HIVE_INIT_ERROR', e, stack);
      rethrow;
    }
  }

  // Generic helper to get a box by name
  Box getBox(String name) {
    switch (name) {
      case 'products': return productsBox;
      case 'customers': return customersBox;
      case 'sales': return salesBox;
      case 'expenses': return expensesBox;
      case 'sale_items': return saleItemsBox;
      case 'weekly_checkups': return weeklyCheckupsBox;
      case 'users': return usersBox;
      default: return settingsBox;
    }
  }

  Future<void> clearAll() async {
    await productsBox.clear();
    await customersBox.clear();
    await salesBox.clear();
    await expensesBox.clear();
    await weeklyCheckupsBox.clear();
    await usersBox.clear();
    await settingsBox.clear();
  }
}
