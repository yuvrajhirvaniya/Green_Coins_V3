import 'package:flutter/material.dart';
import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/features/auth/data/auth_repository.dart';
import 'package:green_coins_app/features/auth/domain/models/user_model.dart';
import 'dart:developer' as developer;

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String _errorMessage = '';

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;

  // Get user ID
  Future<int?> getUserId() async {
    if (_user != null) {
      return _user!.id;
    }
    return await _authRepository.getUserId();
  }

  // Check if user is logged in
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();

      if (isLoggedIn) {
        final userId = await _authRepository.getUserId();

        if (userId != null) {
          final user = await _authRepository.getUserProfile(userId);
          _user = user;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Login user
  Future<void> login(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = await _authRepository.login(username, password);
      _user = user;
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Register user
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? address,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await _authRepository.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        address: address,
      );

      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile({
    required String username,
    required String email,
    required String fullName,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    if (_user == null) return;

    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await _authRepository.updateProfile(
        id: _user!.id,
        username: username,
        email: email,
        fullName: fullName,
        phone: phone,
        address: address,
        profileImage: profileImage,
      );

      // Update local user data
      _user = _user!.copyWith(
        username: username,
        email: email,
        fullName: fullName,
        phone: phone,
        address: address,
        profileImage: profileImage,
      );

      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Update user password
  Future<void> updatePassword(String password) async {
    if (_user == null) return;

    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      await _authRepository.updatePassword(
        id: _user!.id,
        password: password,
      );

      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Update coin balance
  void updateCoinBalance(int coinBalance) {
    if (_user == null) {
      developer.log('Cannot update coin balance: user is null', name: 'AuthProvider');
      return;
    }

    developer.log('Updating coin balance in AuthProvider from ${_user!.coinBalance} to $coinBalance', name: 'AuthProvider');
    _user = _user!.copyWith(coinBalance: coinBalance);
    notifyListeners();
  }

  // Logout user
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authRepository.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Reset error
  void resetError() {
    _errorMessage = '';
    notifyListeners();
  }
}
