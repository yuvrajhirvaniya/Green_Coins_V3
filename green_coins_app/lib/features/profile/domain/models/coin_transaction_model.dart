class CoinTransactionModel {
  final int id;
  final int userId;
  final int amount;
  final String transactionType;
  final int? referenceId;
  final String referenceType;
  final String? description;
  final String createdAt;

  CoinTransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.transactionType,
    this.referenceId,
    required this.referenceType,
    this.description,
    required this.createdAt,
  });

  factory CoinTransactionModel.fromJson(Map<String, dynamic> json) {
    print('CoinTransactionModel.fromJson: $json');
    try {
      return CoinTransactionModel(
        id: json['id'] is String ? int.parse(json['id']) : json['id'],
        userId: json['user_id'] is String ? int.parse(json['user_id']) : json['user_id'],
        amount: json['amount'] is String ? int.parse(json['amount']) : json['amount'],
        transactionType: json['transaction_type'] ?? 'unknown',
        referenceId: json['reference_id'] != null
            ? (json['reference_id'] is String ? int.parse(json['reference_id']) : json['reference_id'])
            : null,
        referenceType: json['reference_type'] ?? 'unknown',
        description: json['description'],
        createdAt: json['created_at'] ?? DateTime.now().toString(),
      );
    } catch (e) {
      print('Error parsing CoinTransactionModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'transaction_type': transactionType,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'description': description,
      'created_at': createdAt,
    };
  }
}
