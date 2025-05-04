import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/core/network/api_service.dart';
import 'package:green_coins_app/core/utils/session_manager.dart';
import 'package:green_coins_app/features/auth/domain/models/user_model.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Login user
  Future<UserModel> login(String username, String password) async {
    try {
      final data = {
        'username': username,
        'password': password,
      };

      final response = await _apiService.post(AppConstants.loginEndpoint, data: data);

      // Save user session
      await SessionManager.saveUserSession(
        token: response['token'],
        userId: response['user']['id'],
        username: response['user']['username'],
        email: response['user']['email'],
        fullName: response['user']['full_name'],
        coinBalance: response['user']['coin_balance'],
      );

      return UserModel.fromJson(response['user']);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Register user
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    try {
      final data = {
        'username': username,
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone': phone,
        'address': address,
        'profile_image': profileImage,
      };

      await _apiService.post(AppConstants.registerEndpoint, data: data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Get user profile
  Future<UserModel> getUserProfile(int userId) async {
    try {
      final response = await _apiService.get(
        AppConstants.userProfileEndpoint,
        queryParameters: {'id': userId.toString()},
      );

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required int id,
    required String username,
    required String email,
    required String fullName,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    try {
      final data = {
        'id': id.toString(),
        'username': username,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'address': address,
        'profile_image': profileImage,
      };

      await _apiService.post(AppConstants.updateProfileEndpoint, data: data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Update user password
  Future<void> updatePassword({
    required int id,
    required String password,
  }) async {
    try {
      final data = {
        'id': id.toString(),
        'password': password,
      };

      await _apiService.post(AppConstants.updatePasswordEndpoint, data: data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await SessionManager.clearUserSession();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await SessionManager.isLoggedIn();
  }

  // Get user ID
  Future<int?> getUserId() async {
    return await SessionManager.getUserId();
  }
}
