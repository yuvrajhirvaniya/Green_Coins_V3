import 'package:flutter/material.dart';
import 'package:green_coins_app/features/profile/data/profile_repository.dart';
import 'package:green_coins_app/features/profile/domain/models/coin_transaction_model.dart';
import 'dart:developer' as developer;

enum ProfileStatus {
  initial,
  loading,
  success,
  error,
}

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileStatus _status = ProfileStatus.initial;
  int _coinBalance = 0;
  List<CoinTransactionModel> _transactions = [];
  String _errorMessage = '';

  ProfileProvider({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  // Getters
  ProfileStatus get status => _status;
  int get coinBalance => _coinBalance;
  List<CoinTransactionModel> get transactions => _transactions;
  String get errorMessage => _errorMessage;

  // Get user coin balance
  Future<void> getCoinBalance(int userId) async {
    developer.log('Getting coin balance for user ID: $userId, current balance: $_coinBalance', name: 'ProfileProvider');
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      final balance = await _profileRepository.getCoinBalance(userId);
      developer.log('Retrieved coin balance: $balance', name: 'ProfileProvider');
      _coinBalance = balance;
      _status = ProfileStatus.success;
    } catch (e) {
      developer.log('Error getting coin balance: $e', name: 'ProfileProvider');
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
    }

    developer.log('Final coin balance: $_coinBalance, status: $_status', name: 'ProfileProvider');
    notifyListeners();
  }

  // Get user coin transactions
  Future<void> getCoinTransactions(int userId) async {
    developer.log('Getting coin transactions for user ID: $userId', name: 'ProfileProvider');
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      final transactions = await _profileRepository.getCoinTransactions(userId);
      developer.log('Received ${transactions.length} transactions', name: 'ProfileProvider');
      _transactions = transactions;
      _status = ProfileStatus.success;
    } catch (e) {
      developer.log('Error getting coin transactions: $e', name: 'ProfileProvider');
      _status = ProfileStatus.error;
      _errorMessage = e.toString();
    }

    developer.log('Notifying listeners with status: $_status, transactions: ${_transactions.length}', name: 'ProfileProvider');
    notifyListeners();
  }

  // Update coin balance
  void updateCoinBalance(int balance) {
    developer.log('Updating coin balance from $_coinBalance to $balance', name: 'ProfileProvider');
    _coinBalance = balance;
    notifyListeners();
  }

  // Reset error
  void resetError() {
    _errorMessage = '';
    notifyListeners();
  }
}
