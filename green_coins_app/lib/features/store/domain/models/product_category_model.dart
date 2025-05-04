class ProductCategoryModel {
  final int id;
  final String name;
  final String description;
  final String? image;
  final String? createdAt;

  ProductCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.createdAt,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    print('ProductCategoryModel.fromJson: $json');
    try {
      return ProductCategoryModel(
        id: json['id'] is String ? int.parse(json['id']) : json['id'],
        name: json['name'] ?? 'Unknown Category',
        description: json['description'] ?? 'No description available',
        image: json['image'],
        createdAt: json['created_at'],
      );
    } catch (e) {
      print('Error parsing ProductCategoryModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'created_at': createdAt,
    };
  }
}
