import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/product.dart';
import '../models/expense.dart';
import '../repositories/sale_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/expense_repository.dart';
import 'hive_service.dart';
import 'logging_service.dart';

/// Transaction service for atomic operations across multiple entities
class TransactionService {
  final _hive = HiveService.instance;
  final _saleRepo = SaleRepository();
  final _productRepo = ProductRepository();
  final _expenseRepo = ExpenseRepository();

  /// Executes a sale with stock update as a single transaction
  /// If any step fails, all changes are rolled back
  Future<void> executeSaleTransaction(
    Sale sale,
    List<SaleItem> items,
  ) async {
    // Create snapshots for rollback
    final saleSnapshot = sale.toJson();
    final itemsSnapshots = items.map((i) => i.toJson()).toList();
    final productSnapshots = <String, Map>{};

    try {
      logger.info('Starting sale transaction for sale ${sale.id}');

      // Capture product states before modification
      for (var item in items) {
        final product = await _productRepo.getProductById(item.productId);
        if (product != null) {
          productSnapshots[item.productId] = product.toJson();
        }
      }

      // Step 1: Save sale and items
      await _saleRepo.save(sale, items);

      // Step 2: Update stock quantities
      for (var item in items) {
        final product = await _productRepo.getProductById(item.productId);
        if (product != null) {
          product.stockQuantity -= item.quantity;
          
          // Validate stock doesn't go negative
          if (product.stockQuantity < 0) {
            throw Exception(
              'Insufficient stock for product ${product.name}. '
              'Requested: ${item.quantity}, Available: ${product.stockQuantity + item.quantity}',
            );
          }
          
          await _productRepo.save(product);
        }
      }

      logger.info('Sale transaction completed successfully for sale ${sale.id}');
    } catch (e, stack) {
      logger.error('Sale transaction failed, rolling back changes', e, stack);

      // Rollback: Restore product states
      try {
        for (var entry in productSnapshots.entries) {
          final restoredProduct = Product.fromJson(entry.value);
          await _productRepo.save(restoredProduct);
        }

        // Rollback: Remove sale and items (soft delete)
        await _saleRepo.softDelete(sale);

        logger.info('Rollback completed for sale ${sale.id}');
      } catch (rollbackError) {
        logger.error('CRITICAL: Rollback failed for sale ${sale.id}', rollbackError);
        throw Exception(
          'Transaction failed and rollback could not complete. '
          'Manual intervention may be required. Sale ID: ${sale.id}',
        );
      }

      rethrow;
    }
  }

  /// Executes a stock expense with product creation/update as a transaction
  Future<void> executeStockExpenseTransaction(Expense expense) async {
    if (expense.category != ExpenseCategory.stock) {
      throw Exception('This transaction is only for stock expenses');
    }

    final expenseSnapshot = expense.toJson();
    Map<String, Map>? productSnapshots;

    try {
      logger.info('Starting stock expense transaction for expense ${expense.id}');

      // Find existing product or prepare for new
      final productsBox = _hive.productsBox;
      final itemName = expense.stockProductName?.trim().toLowerCase();
      final itemType = expense.stockProductType?.trim().toLowerCase();

      final existingEntry = productsBox.values.cast<Map<dynamic, dynamic>>().where(
        (p) {
          final pName = (p['name'] as String?)?.trim().toLowerCase();
          final pType = (p['productType'] as String?)?.trim().toLowerCase();
          return pName == itemName && pType == itemType;
        },
      ).firstOrNull;

      // Capture existing product state if it exists
      if (existingEntry != null) {
        productSnapshots = {existingEntry['id']: Map<String, dynamic>.from(existingEntry)};
      }

      // Step 1: Save expense
      await _expenseRepo.save(expense);

      // Step 2: Update or create product
      if (existingEntry != null) {
        // Update existing product stock
        final p = Map<String, dynamic>.from(existingEntry);
        final oldQuantity = p['stockQuantity'] ?? 0;
        p['stockQuantity'] = oldQuantity + (expense.stockQuantity ?? 0);
        p['updatedAt'] = DateTime.now().toIso8601String();
        p['isDirty'] = true;
        await productsBox.put(p['id'], p);
        logger.info('Updated existing product stock: ${expense.stockProductName}');
      } else {
        // Create new product
        final newId = expense.id; // Use expense ID as base
        final newProduct = {
          'id': newId,
          'name': expense.stockProductName ?? 'New Stock',
          'productType': expense.stockProductType,
          'quality': expense.stockQuality,
          'description': expense.notes ?? '',
          'stockQuantity': expense.stockQuantity ?? 0,
          'purchasePrice': expense.stockPurchasePrice ?? 0.0,
          'price': expense.stockResalePrice ?? 0.0,
          'imagePath': expense.stockImagePath,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'isDirty': true,
          'deletedAt': null,
          'serverId': null,
          'lastSyncedAt': null,
        };
        await productsBox.put(newId, newProduct);
        logger.info('Created new product from stock: ${expense.stockProductName}');
      }

      logger.info('Stock expense transaction completed successfully');
    } catch (e, stack) {
      logger.error('Stock expense transaction failed, rolling back', e, stack);

      // Rollback
      try {
        // Restore product state if it existed
        if (productSnapshots != null) {
          for (var entry in productSnapshots.entries) {
            await _hive.productsBox.put(entry.key, entry.value);
          }
        } else {
          // Remove newly created product
          if (expense.stockProductName != null) {
            final productsBox = _hive.productsBox;
            final itemName = expense.stockProductName!.trim().toLowerCase();
            final itemType = expense.stockProductType?.trim().toLowerCase();
            
            final newEntry = productsBox.values.cast<Map<dynamic, dynamic>>().where(
              (p) {
                final pName = (p['name'] as String?)?.trim().toLowerCase();
                final pType = (p['productType'] as String?)?.trim().toLowerCase();
                return pName == itemName && pType == itemType;
              },
            ).firstOrNull;
            
            if (newEntry != null) {
              await productsBox.delete(newEntry['id']);
            }
          }
        }

        // Soft delete the expense
        await _expenseRepo.softDelete(expense);

        logger.info('Rollback completed for expense ${expense.id}');
      } catch (rollbackError) {
        logger.error('CRITICAL: Rollback failed for expense ${expense.id}', rollbackError);
        throw Exception(
          'Transaction failed and rollback could not complete. '
          'Manual intervention may be required. Expense ID: ${expense.id}',
        );
      }

      rethrow;
    }
  }

  /// Validates stock availability before a sale
  Future<Map<String, int>> validateStockAvailability(List<SaleItem> items) async {
    final insufficientStock = <String, int>{};
    
    for (var item in items) {
      final product = await _productRepo.getProductById(item.productId);
      if (product == null) {
        insufficientStock[item.productId] = item.quantity;
      } else if (product.stockQuantity < item.quantity) {
        insufficientStock[item.productId] = product.stockQuantity;
      }
    }
    
    return insufficientStock;
  }
}

extension ProductRepositoryExtension on ProductRepository {
  Future<Product?> getProductById(String id) async {
    final products = await getAll();
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
