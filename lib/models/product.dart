class Product {
  final int? id;
  final String name;
  final String? barcode;
  final String? category;
  final double purchasePrice;
  final double salePrice;
  final int quantity;
  final String? imagePath;
  final String? brand;
  final String? model;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    this.id,
    required this.name,
    this.barcode,
    this.category,
    required this.purchasePrice,
    required this.salePrice,
    required this.quantity,
    this.imagePath,
    this.brand,
    this.model,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    int? id,
    String? name,
    String? barcode,
    String? category,
    double? purchasePrice,
    double? salePrice,
    int? quantity,
    String? imagePath,
    String? brand,
    String? model,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Product(
        id: id ?? this.id,
        name: name ?? this.name,
        barcode: barcode ?? this.barcode,
        category: category ?? this.category,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        salePrice: salePrice ?? this.salePrice,
        quantity: quantity ?? this.quantity,
        imagePath: imagePath ?? this.imagePath,
        brand: brand ?? this.brand,
        model: model ?? this.model,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'barcode': barcode,
        'category': category,
        'purchase_price': purchasePrice,
        'sale_price': salePrice,
        'quantity': quantity,
        'image_path': imagePath,
        'brand': brand,
        'model': model,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Product.fromMap(Map<String, Object?> map) => Product(
        id: map['id'] as int?,
        name: map['name'] as String,
        barcode: map['barcode'] as String?,
        category: map['category'] as String?,
        purchasePrice: (map['purchase_price'] as num).toDouble(),
        salePrice: (map['sale_price'] as num).toDouble(),
        quantity: map['quantity'] as int,
        imagePath: map['image_path'] as String?,
        brand: map['brand'] as String?,
        model: map['model'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );
}
