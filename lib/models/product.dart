class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final double price;
  final String unit;
  final double rating;
  final String category;
  final bool isFeatured;
  final bool isFavorite;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.unit,
    required this.rating,
    required this.category,
    required this.isFeatured,
    this.isFavorite = false,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    String? unit,
    double? rating,
    String? category,
    bool? isFeatured,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      unit: unit ?? this.unit,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      isFeatured: isFeatured ?? this.isFeatured,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'unit': unit,
      'rating': rating,
      'category': category,
      'isFeatured': isFeatured,
      'isFavorite': isFavorite,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] is int)
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0).toDouble(),
      image: map['image'] ?? '',
      unit: map['unit'] ?? '',
      rating: (map['rating'] is int)
          ? (map['rating'] as int).toDouble()
          : (map['rating'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      isFeatured: map['isFeatured'] ?? false,
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  // ✅ Unique bonne version du constructeur Firestore
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    final List<String> images = List<String>.from(data['images'] ?? []);
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] ?? 0.0).toDouble(),
      image: images.isNotEmpty ? images.first : '',
      unit: data['unit'] ?? '',
      rating: (data['rating'] is int)
          ? (data['rating'] as int).toDouble()
          : (data['rating'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  get images => null;

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'unit': unit,
      'rating': rating,
      'category': category,
      'isFeatured': isFeatured,
      'isFavorite': isFavorite,
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price)';
  }
}
