class RecyclingActivityModel {
  final int id;
  final int userId;
  final int categoryId;
  final String? categoryName;
  final double quantity;
  final int coinsEarned;
  final String status;
  final String? proofImage;
  final String? notes;
  final String? pickupDate;
  final String? pickupTimeSlot;
  final String? pickupAddress;
  final String? pickupStatus;
  final String createdAt;
  final String? updatedAt;

  RecyclingActivityModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    this.categoryName,
    required this.quantity,
    required this.coinsEarned,
    required this.status,
    this.proofImage,
    this.notes,
    this.pickupDate,
    this.pickupTimeSlot,
    this.pickupAddress,
    this.pickupStatus,
    required this.createdAt,
    this.updatedAt,
  });

  factory RecyclingActivityModel.fromJson(Map<String, dynamic> json) {
    print('RecyclingActivityModel.fromJson: $json');
    try {
      return RecyclingActivityModel(
        id: json['id'] is String ? int.parse(json['id']) : json['id'],
        userId: json['user_id'] is String ? int.parse(json['user_id']) : json['user_id'],
        categoryId: json['category_id'] is String ? int.parse(json['category_id']) : json['category_id'],
        categoryName: json['category_name'],
        quantity: double.parse((json['quantity'] ?? '0').toString()),
        coinsEarned: json['coins_earned'] is String ? int.parse(json['coins_earned']) : json['coins_earned'] ?? 0,
        status: json['status'] ?? 'pending',
        proofImage: json['proof_image'],
        notes: json['notes'],
        pickupDate: json['pickup_date'],
        pickupTimeSlot: json['pickup_time_slot'],
        pickupAddress: json['pickup_address'],
        pickupStatus: json['pickup_status'] ?? 'not_required',
        createdAt: json['created_at'] ?? DateTime.now().toString(),
        updatedAt: json['updated_at'],
      );
    } catch (e) {
      print('Error parsing RecyclingActivityModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'category_name': categoryName,
      'quantity': quantity,
      'coins_earned': coinsEarned,
      'status': status,
      'proof_image': proofImage,
      'notes': notes,
      'pickup_date': pickupDate,
      'pickup_time_slot': pickupTimeSlot,
      'pickup_address': pickupAddress,
      'pickup_status': pickupStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
