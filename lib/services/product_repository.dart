import 'package:sqflite/sqflite.dart';
import '../core/database/app_database.dart';
import '../models/product.dart';

class ProductRepository {
  final AppDatabase _database = AppDatabase.instance;

  Future<List<Product>> all({String query = ''}) async {
    final db = await _database.database;
    final q = query.trim();
    final rows = await db.query(
      'products',
      where: q.isEmpty ? null : 'name LIKE ? OR barcode LIKE ? OR brand LIKE ? OR model LIKE ?',
      whereArgs: q.isEmpty ? null : ['%$q%', '%$q%', '%$q%', '%$q%'],
      orderBy: 'updated_at DESC',
    );
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> findByBarcode(String barcode) async {
    final db = await _database.database;
    final rows = await db.query('products', where: 'barcode = ?', whereArgs: [barcode], limit: 1);
    return rows.isEmpty ? null : Product.fromMap(rows.first);
  }

  Future<int> insert(Product product) async {
    final db = await _database.database;
    return db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> update(Product product) async {
    final db = await _database.database;
    return db.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> delete(int id) async {
    final db = await _database.database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> adjustQuantity(int id, int delta) async {
    final db = await _database.database;
    await db.rawUpdate(
      'UPDATE products SET quantity = MAX(quantity + ?, 0), updated_at = ? WHERE id = ?',
      [delta, DateTime.now().toIso8601String(), id],
    );
  }

  Future<int> count() async {
    final db = await _database.database;
    final result = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products'));
    return result ?? 0;
  }

  Future<double> inventoryValue() async {
    final db = await _database.database;
    final rows = await db.rawQuery('SELECT SUM(purchase_price * quantity) AS total FROM products');
    return (rows.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<List<Product>> lowStock({int threshold = 3}) async {
    final db = await _database.database;
    final rows = await db.query('products', where: 'quantity <= ?', whereArgs: [threshold], orderBy: 'quantity ASC');
    return rows.map(Product.fromMap).toList();
  }
}
