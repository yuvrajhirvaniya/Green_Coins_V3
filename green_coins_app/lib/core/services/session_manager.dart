import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:green_coins_app/features/auth/domain/models/user_model.dart';

/// A class that manages user session data using SharedPreferences
class SessionManager {
  // Keys for SharedPreferences
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _coinBalanceKey = 'coin_balance';
  
  /// Save user data to SharedPreferences
  static Future<bool> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  /// Get user data from SharedPreferences
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData != null) {
      try {
        return UserModel.fromJson(jsonDecode(userData));
      } catch (e) {
        print('SessionManager: Error parsing user data: $e');
        return null;
      }
    }
    
    return null;
  }
  
  /// Save authentication token to SharedPreferences
  static Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_tokenKey, token);
  }
  
  /// Get authentication token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  /// Update coin balance in SharedPreferences
  static Future<bool> updateCoinBalance(int balance) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_coinBalanceKey, balance);
  }
  
  /// Get coin balance from SharedPreferences
  static Future<int> getCoinBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinBalanceKey) ?? 0;
  }
  
  /// Clear all session data from SharedPreferences
  static Future<bool> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
