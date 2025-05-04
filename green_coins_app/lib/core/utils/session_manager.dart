import 'package:shared_preferences/shared_preferences.dart';
import 'package:green_coins_app/core/constants/app_constants.dart';
import 'dart:developer' as developer;

class SessionManager {
  // Save user session
  static Future<void> saveUserSession({
    required String token,
    required dynamic userId,
    required String username,
    required String email,
    required String fullName,
    required dynamic coinBalance,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert userId to int if it's a string
    final int userIdInt = userId is String ? int.parse(userId) : userId;

    // Handle coin balance conversion with better error handling
    int coinBalanceInt;
    if (coinBalance is String) {
      try {
        coinBalanceInt = int.parse(coinBalance);
      } catch (e) {
        developer.log('Error parsing coinBalance: $coinBalance, defaulting to 0', name: 'SessionManager');
        coinBalanceInt = 0;
      }
    } else if (coinBalance is int) {
      coinBalanceInt = coinBalance;
    } else {
      developer.log('Unexpected coinBalance type: $coinBalance (${coinBalance.runtimeType}), defaulting to 0', name: 'SessionManager');
      coinBalanceInt = 0;
    }

    developer.log('Saving user session with coin balance: $coinBalanceInt', name: 'SessionManager');

    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setInt(AppConstants.userIdKey, userIdInt);
    await prefs.setString(AppConstants.usernameKey, username);
    await prefs.setString(AppConstants.emailKey, email);
    await prefs.setString(AppConstants.fullNameKey, fullName);
    await prefs.setInt(AppConstants.coinBalanceKey, coinBalanceInt);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(AppConstants.tokenKey);
  }

  // Get user token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // Get user ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.userIdKey);
  }

  // Get username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.usernameKey);
  }

  // Get email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.emailKey);
  }

  // Get full name
  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.fullNameKey);
  }

  // Get coin balance
  static Future<int?> getCoinBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final coinBalance = prefs.getInt(AppConstants.coinBalanceKey);
    developer.log('Retrieved coin balance from SharedPreferences: $coinBalance', name: 'SessionManager');
    return coinBalance;
  }

  // Update coin balance
  static Future<void> updateCoinBalance(int coinBalance) async {
    final prefs = await SharedPreferences.getInstance();
    developer.log('Updating coin balance in SessionManager: $coinBalance', name: 'SessionManager');
    await prefs.setInt(AppConstants.coinBalanceKey, coinBalance);
  }

  // Clear user session (logout)
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.usernameKey);
    await prefs.remove(AppConstants.emailKey);
    await prefs.remove(AppConstants.fullNameKey);
    await prefs.remove(AppConstants.coinBalanceKey);
  }
}
