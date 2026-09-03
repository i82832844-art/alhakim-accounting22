import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final base = await getDatabasesPath();
    final path = join(base, 'alhakim_accounting.db');
    return openDatabase(path, version: 2, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          barcode TEXT UNIQUE,
          category TEXT,
          purchase_price REAL NOT NULL DEFAULT 0,
          sale_price REAL NOT NULL DEFAULT 0,
          quantity INTEGER NOT NULL DEFAULT 0,
          image_path TEXT,
          brand TEXT,
          model TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE sales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          total REAL NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE sale_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sale_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          quantity INTEGER NOT NULL,
          unit_price REAL NOT NULL,
          FOREIGN KEY(sale_id) REFERENCES sales(id),
          FOREIGN KEY(product_id) REFERENCES products(id)
        )
      ''');
      await db.execute('''
        CREATE TABLE expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
      await db.execute('CREATE INDEX idx_products_name ON products(name)');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_products_name ON products(name)');
      }
    });
  }
}
