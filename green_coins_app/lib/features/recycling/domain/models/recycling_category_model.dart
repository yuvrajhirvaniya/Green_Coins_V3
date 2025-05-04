class RecyclingCategoryModel {
  final int id;
  final String name;
  final String description;
  final int coinValue;
  final String? image;
  final String? createdAt;

  RecyclingCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coinValue,
    this.image,
    this.createdAt,
  });

  factory RecyclingCategoryModel.fromJson(Map<String, dynamic> json) {
    return RecyclingCategoryModel(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      description: json['description'],
      coinValue: int.parse(json['coin_value'].toString()),
      image: json['image'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coin_value': coinValue,
      'image': image,
      'created_at': createdAt,
    };
  }
}
