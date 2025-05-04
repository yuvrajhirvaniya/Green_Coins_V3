import 'dart:async';
import 'dart:developer' as developer;
import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/core/network/api_service.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/profile/presentation/providers/profile_provider.dart';

class BackgroundSyncService {
  static final BackgroundSyncService _instance = BackgroundSyncService._internal();
  factory BackgroundSyncService() => _instance;

  BackgroundSyncService._internal();

  Timer? _timer;
  final ApiService _apiService = ApiService();
  bool _isSyncing = false;

  // Start the background sync service
  void startService(AuthProvider authProvider, ProfileProvider profileProvider) {
    developer.log('Starting background sync service', name: 'BackgroundSyncService');

    // Stop any existing timer
    stopService();

    // Run sync immediately
    developer.log('Running initial sync', name: 'BackgroundSyncService');
    _syncTransactions(authProvider, profileProvider);

    // Schedule periodic sync (every second)
    final syncInterval = const Duration(seconds: 1);
    developer.log('Setting up periodic sync every ${syncInterval.inSeconds} second(s)', name: 'BackgroundSyncService');

    _timer = Timer.periodic(syncInterval, (timer) {
      developer.log('Running periodic sync (${DateTime.now().toIso8601String()})', name: 'BackgroundSyncService');
      _syncTransactions(authProvider, profileProvider);
    });

    developer.log('Service started successfully', name: 'BackgroundSyncService');
  }

  // Stop the background sync service
  void stopService() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      developer.log('Service stopped', name: 'BackgroundSyncService');
    }
  }

  // Sync transactions
  Future<void> _syncTransactions(AuthProvider authProvider, ProfileProvider profileProvider) async {
    // Skip if already syncing or user is not logged in
    if (_isSyncing || authProvider.user == null) {
      developer.log('Skipping sync (${_isSyncing ? 'already syncing' : 'user not logged in'})', name: 'BackgroundSyncService');
      return;
    }

    _isSyncing = true;
    developer.log('Syncing transactions for user ID: ${authProvider.user!.id}', name: 'BackgroundSyncService');

    try {
      // Call the transaction sync endpoint with user ID
      final response = await _apiService.get(
        AppConstants.transactionSyncEndpoint,
        queryParameters: {'user_id': authProvider.user!.id},
      );

      developer.log('Sync response: $response', name: 'BackgroundSyncService');

      // Process the response
      if (response != null) {
        final timestamp = response['timestamp'] ?? DateTime.now().toIso8601String();
        final fixedCount = response['fixed_count'] ?? 0;

        developer.log('Sync response at $timestamp - Fixed: $fixedCount transactions', name: 'BackgroundSyncService');

        // If transactions were fixed, refresh the user's coin balance
        if (fixedCount > 0) {
          developer.log('Fixed $fixedCount transactions', name: 'BackgroundSyncService');

          // Get details of fixed transactions
          if (response['fixed_transactions'] != null) {
            for (var transaction in response['fixed_transactions']) {
              developer.log('Fixed transaction - Activity ID: ${transaction['activity_id']}, Coins: ${transaction['coins_earned']}', name: 'BackgroundSyncService');
            }
          }

          // Refresh coin balance
          final userId = authProvider.user!.id;
          await profileProvider.getCoinBalance(userId);

          // Update auth provider with new coin balance
          authProvider.updateCoinBalance(profileProvider.coinBalance);

          developer.log('Updated coin balance: ${profileProvider.coinBalance}', name: 'BackgroundSyncService');
        } else {
          // No need to log every time when no transactions are found
          // This reduces log spam since we're checking every second
        }
      } else {
        developer.log('Received null response from sync endpoint', name: 'BackgroundSyncService');
      }
    } catch (e) {
      developer.log('Error syncing transactions: $e', name: 'BackgroundSyncService');
    } finally {
      _isSyncing = false;
      developer.log('Sync completed', name: 'BackgroundSyncService');
    }
  }

  // Force a sync now
  Future<void> syncNow(AuthProvider authProvider, ProfileProvider profileProvider) async {
    return _syncTransactions(authProvider, profileProvider);
  }
}
