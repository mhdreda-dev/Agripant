class Product {
  final int? id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String? imageUrl;
  final String? description;
  final int? userId;
  final String? createdAt;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.description,
    this.userId,
    this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: map['price'],
      quantity: map['quantity'],
      imageUrl: map['imageUrl'],
      description: map['description'],
      userId: map['userId'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'description': description,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    int? quantity,
    String? imageUrl,
    String? description,
    int? userId,
    String? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
