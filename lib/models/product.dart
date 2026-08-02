/// A selectable variant of a product (e.g. "Cheese" ₹60, "Potato Cheese" ₹70).
class ProductVariant {
  final String id;
  final String name;
  final double price;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ProductVariant.fromMap(Map<String, dynamic> map) => ProductVariant(
    id: (map['id'] ?? '') as String,
    name: (map['name'] ?? '') as String,
    price: (map['price'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'price': price};
}

/// A menu product the agent adds (admin) and the client sees.
class Product {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final bool isVeg;
  final bool isAvailable;
  final List<ProductVariant> variants;

  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.isVeg,
    required this.isAvailable,
    required this.variants,
  });

  double get startingPrice => variants.isEmpty
      ? 0
      : variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);

  factory Product.fromMap(String id, Map<String, dynamic> map) => Product(
    id: id,
    storeId: (map['storeId'] ?? '') as String,
    name: (map['name'] ?? '') as String,
    description: (map['description'] ?? '') as String,
    imageUrl: (map['imageUrl'] ?? '') as String,
    category: (map['category'] ?? 'Snacks') as String,
    isVeg: (map['isVeg'] ?? true) as bool,
    isAvailable: (map['isAvailable'] ?? true) as bool,
    variants: ((map['variants'] as List<dynamic>?) ?? [])
        .map((e) => ProductVariant.fromMap(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    'storeId': storeId,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'category': category,
    'isVeg': isVeg,
    'isAvailable': isAvailable,
    'variants': variants.map((v) => v.toMap()).toList(),
  };
}
