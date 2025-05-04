class ProductModel {
  final int id;
  final int categoryId;
  final String? categoryName;
  final String name;
  final String description;
  final int coinPrice;
  final int stockQuantity;
  final String? image;
  final bool isFeatured;
  final String? createdAt;
  final String? updatedAt;

  ProductModel({
    required this.id,
    required this.categoryId,
    this.categoryName,
    required this.name,
    required this.description,
    required this.coinPrice,
    required this.stockQuantity,
    this.image,
    required this.isFeatured,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    print('ProductModel.fromJson: $json');
    try {
      return ProductModel(
        id: json['id'] is String ? int.parse(json['id']) : json['id'],
        categoryId: json['category_id'] is String ? int.parse(json['category_id']) : json['category_id'],
        categoryName: json['category_name'],
        name: json['name'] ?? 'Unknown Product',
        description: json['description'] ?? 'No description available',
        coinPrice: json['coin_price'] is String ? int.parse(json['coin_price']) : json['coin_price'],
        stockQuantity: json['stock_quantity'] is String ? int.parse(json['stock_quantity']) : json['stock_quantity'],
        image: json['image'],
        isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );
    } catch (e) {
      print('Error parsing ProductModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_name': categoryName,
      'name': name,
      'description': description,
      'coin_price': coinPrice,
      'stock_quantity': stockQuantity,
      'image': image,
      'is_featured': isFeatured,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
