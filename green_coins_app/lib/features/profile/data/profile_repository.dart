import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/core/network/api_service.dart';
import 'package:green_coins_app/core/utils/session_manager.dart';
import 'package:green_coins_app/features/profile/domain/models/coin_transaction_model.dart';
import 'dart:developer' as developer;

class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Get user coin balance
  Future<int> getCoinBalance(int userId) async {
    try {
      final response = await _apiService.get(
        AppConstants.coinBalanceEndpoint,
        queryParameters: {'id': userId},
      );

      developer.log('API Response for coin balance: $response', name: 'ProfileRepository');

      // Make sure we're parsing the coin_balance as an integer
      final coinBalance = response['coin_balance'] is String
          ? int.parse(response['coin_balance'])
          : response['coin_balance'];

      developer.log('Retrieved coin balance: $coinBalance (type: ${coinBalance.runtimeType})', name: 'ProfileRepository');

      // Update coin balance in session
      await SessionManager.updateCoinBalance(coinBalance);

      return coinBalance;
    } catch (e) {
      developer.log('Error getting coin balance: $e', name: 'ProfileRepository');
      throw Exception(e.toString());
    }
  }

  // Get user coin transactions
  Future<List<CoinTransactionModel>> getCoinTransactions(int userId) async {
    try {
      developer.log('Getting coin transactions for user ID: $userId', name: 'ProfileRepository');
      final response = await _apiService.get(
        AppConstants.coinTransactionsEndpoint,
        queryParameters: {'id': userId},
      );

      developer.log('Coin transactions response: $response', name: 'ProfileRepository');

      final List<CoinTransactionModel> transactions = [];

      if (response != null && response.containsKey('records')) {
        developer.log('Found ${response['records'].length} transactions', name: 'ProfileRepository');
        for (var transaction in response['records']) {
          try {
            developer.log('Processing transaction: $transaction', name: 'ProfileRepository');
            transactions.add(CoinTransactionModel.fromJson(transaction));
          } catch (parseError) {
            developer.log('Error parsing transaction: $parseError', name: 'ProfileRepository');
          }
        }
      } else {
        developer.log('No records found in response', name: 'ProfileRepository');
      }

      developer.log('Returning ${transactions.length} transactions', name: 'ProfileRepository');
      return transactions;
    } catch (e) {
      developer.log('Error getting coin transactions: $e', name: 'ProfileRepository');
      // Return empty list instead of throwing exception to prevent app crashes
      return [];
    }
  }
}
