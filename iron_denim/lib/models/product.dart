class Product {
  final String id;
  String name;
  String category; // 'Jeans' atau 'Jaket'
  int price;
  int stock;
  String imageUrl;
  String description;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imageUrl = '',
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'description': description,
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        price: j['price'] as int,
        stock: j['stock'] as int,
        imageUrl: (j['imageUrl'] ?? '') as String,
        description: (j['description'] ?? '') as String,
      );
}
