import 'package:sqflite/sqflite.dart';
import '../core/database/app_database.dart';
import '../models/cart_item.dart';

class SalesRepository {
  final AppDatabase _database = AppDatabase.instance;

  Future<int> createSale(List<CartItem> items) async {
    if (items.isEmpty) throw ArgumentError('لا يمكن إنشاء فاتورة فارغة');
    final db = await _database.database;
    return db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      final total = items.fold<double>(0, (sum, item) => sum + item.total);
      final saleId = await txn.insert('sales', {'total': total, 'created_at': now});

      for (final item in items) {
        final rows = await txn.query('products', columns: ['quantity'], where: 'id = ?', whereArgs: [item.product.id], limit: 1);
        if (rows.isEmpty) throw StateError('المنتج غير موجود: ${item.product.name}');
        final stock = (rows.first['quantity'] as num).toInt();
        if (stock < item.quantity) {
          throw StateError('الكمية غير كافية للمنتج: ${item.product.name} (المتاح $stock)');
        }
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'unit_price': item.product.salePrice,
        });
        await txn.rawUpdate(
          'UPDATE products SET quantity = quantity - ?, updated_at = ? WHERE id = ?',
          [item.quantity, now, item.product.id],
        );
      }
      return saleId;
    });
  }

  Future<double> salesTotal({DateTime? from, DateTime? to}) async {
    final db = await _database.database;
    final clauses = <String>[];
    final args = <Object?>[];
    if (from != null) {
      clauses.add('created_at >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      clauses.add('created_at < ?');
      args.add(to.toIso8601String());
    }
    final where = clauses.isEmpty ? null : clauses.join(' AND ');
    final rows = await db.query('sales', columns: ['SUM(total) AS total'], where: where, whereArgs: args);
    return (rows.first['total'] as num?)?.toDouble() ?? 0;
  }
}
