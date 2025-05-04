import 'dart:developer' as developer;

class OrderItemModel {
  final int id;
  final int productId;
  final String? productName;
  final String? productImage;
  final int quantity;
  final int coinPrice;
  final int totalPrice;

  OrderItemModel({
    required this.id,
    required this.productId,
    this.productName,
    this.productImage,
    required this.quantity,
    required this.coinPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse id
      final id = json['id'] is String ? int.parse(json['id']) : json['id'];

      // Parse product_id
      final productId = json['product_id'] is String ? int.parse(json['product_id']) : json['product_id'];

      // Parse quantity
      final quantity = json['quantity'] is String ? int.parse(json['quantity']) : json['quantity'];

      // Parse coin_price
      final coinPrice = json['coin_price'] is String ? int.parse(json['coin_price']) : json['coin_price'];

      // Parse or calculate total_price
      int totalPrice;
      if (json['total_price'] != null) {
        totalPrice = json['total_price'] is String ? int.parse(json['total_price']) : json['total_price'];
      } else {
        totalPrice = quantity * coinPrice;
      }

      return OrderItemModel(
        id: id,
        productId: productId,
        productName: json['product_name'],
        productImage: json['product_image'],
        quantity: quantity,
        coinPrice: coinPrice,
        totalPrice: totalPrice,
      );
    } catch (e) {
      developer.log('Error parsing OrderItemModel: $e, json: $json', name: 'OrderItemModel');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      'coin_price': coinPrice,
      'total_price': totalPrice,
    };
  }
}

class OrderModel {
  final int id;
  final int userId;
  final int totalCoinAmount;
  final String status;
  final String shippingAddress;
  final String contactPhone;
  final String? notes;
  final String createdAt;
  final String? updatedAt;
  final List<OrderItemModel>? items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalCoinAmount,
    required this.status,
    required this.shippingAddress,
    required this.contactPhone,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('Parsing OrderModel from JSON: $json', name: 'OrderModel');

      List<OrderItemModel>? orderItems;

      if (json['items'] != null) {
        try {
          orderItems = List<OrderItemModel>.from(
            json['items'].map((item) => OrderItemModel.fromJson(item)),
          );
          developer.log('Parsed ${orderItems.length} order items', name: 'OrderModel');
        } catch (e) {
          developer.log('Error parsing order items: $e', name: 'OrderModel');
          // Continue without items rather than failing the whole order
          orderItems = [];
        }
      }

      // Parse id
      final id = json['id'] is String ? int.parse(json['id']) : json['id'];

      // Parse user_id
      final userId = json['user_id'] is String ? int.parse(json['user_id']) : json['user_id'];

      // Parse total_coin_amount
      final totalCoinAmount = json['total_coin_amount'] is String
          ? int.parse(json['total_coin_amount'])
          : json['total_coin_amount'];

      // Ensure status is a string
      final status = json['status']?.toString() ?? 'unknown';

      // Ensure shipping_address is a string
      final shippingAddress = json['shipping_address']?.toString() ?? '';

      // Ensure contact_phone is a string
      final contactPhone = json['contact_phone']?.toString() ?? '';

      // Ensure created_at is a string
      final createdAt = json['created_at']?.toString() ?? '';

      return OrderModel(
        id: id,
        userId: userId,
        totalCoinAmount: totalCoinAmount,
        status: status,
        shippingAddress: shippingAddress,
        contactPhone: contactPhone,
        notes: json['notes'],
        createdAt: createdAt,
        updatedAt: json['updated_at'],
        items: orderItems,
      );
    } catch (e) {
      developer.log('Error parsing OrderModel: $e, json: $json', name: 'OrderModel');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_coin_amount': totalCoinAmount,
      'status': status,
      'shipping_address': shippingAddress,
      'contact_phone': contactPhone,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}
