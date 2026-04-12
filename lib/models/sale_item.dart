import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'sale_item.g.dart';

@collection
class SaleItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? serverId;

  @Index()
  late int saleId;
  
  @Index()
  late int productId;
  
  @Index()
  late int quantity;
  
  @Index()
  late double unitPrice;
  
  @Index()
  late double totalPrice;

  SaleItem() {
    serverId = const Uuid().v4();
  }
}
