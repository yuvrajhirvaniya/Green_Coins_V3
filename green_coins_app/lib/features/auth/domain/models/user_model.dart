import 'dart:developer' as developer;

class UserModel {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String? phone;
  final String? address;
  final String? profileImage;
  final int coinBalance;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.phone,
    this.address,
    this.profileImage,
    required this.coinBalance,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle coin_balance parsing with additional logging
    int parsedCoinBalance;
    if (json['coin_balance'] is String) {
      try {
        parsedCoinBalance = int.parse(json['coin_balance']);
      } catch (e) {
        developer.log('Error parsing coin_balance: ${json['coin_balance']}', name: 'UserModel');
        parsedCoinBalance = 0; // Default to 0 if parsing fails
      }
    } else if (json['coin_balance'] is int) {
      parsedCoinBalance = json['coin_balance'];
    } else {
      developer.log('Unexpected coin_balance type: ${json['coin_balance']} (${json['coin_balance'].runtimeType})', name: 'UserModel');
      parsedCoinBalance = 0; // Default to 0 for unexpected types
    }

    return UserModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      address: json['address'],
      profileImage: json['profile_image'],
      coinBalance: parsedCoinBalance,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'profile_image': profileImage,
      'coin_balance': coinBalance,
      'created_at': createdAt,
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? phone,
    String? address,
    String? profileImage,
    int? coinBalance,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      coinBalance: coinBalance ?? this.coinBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
