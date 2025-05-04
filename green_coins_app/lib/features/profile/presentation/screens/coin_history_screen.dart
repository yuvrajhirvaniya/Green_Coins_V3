import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/profile/domain/models/coin_transaction_model.dart';
import 'package:green_coins_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key});

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    developer.log('Loading transactions', name: 'CoinHistoryScreen');
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    final userId = authProvider.user?.id;
    developer.log('User ID: $userId', name: 'CoinHistoryScreen');

    if (userId != null) {
      try {
        // First refresh the coin balance
        await profileProvider.getCoinBalance(userId);
        developer.log('Updated coin balance: ${profileProvider.coinBalance}', name: 'CoinHistoryScreen');

        // Update auth provider with new coin balance
        authProvider.updateCoinBalance(profileProvider.coinBalance);

        // Then get the transactions
        await profileProvider.getCoinTransactions(userId);
        developer.log('Loaded ${profileProvider.transactions.length} transactions', name: 'CoinHistoryScreen');
      } catch (e) {
        developer.log('Error loading transactions: $e', name: 'CoinHistoryScreen');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading transactions: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } else {
      developer.log('User ID is null', name: 'CoinHistoryScreen');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      developer.log('Loading completed, isLoading = $_isLoading', name: 'CoinHistoryScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    final user = authProvider.user;
    final transactions = profileProvider.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin History'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Coin balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Current Balance',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          // Add refresh button
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                            onPressed: () async {
                              developer.log('Refreshing data', name: 'CoinHistoryScreen');
                              await _loadTransactions();

                              if (mounted) {
                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Transactions refreshed'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            tooltip: 'Refresh transactions',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${user.coinBalance}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Transactions list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : transactions.isEmpty
                          ? const Center(
                              child: Text('No transactions found'),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadTransactions,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = transactions[index];
                                  return _buildTransactionCard(transaction);
                                },
                              ),
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildTransactionCard(CoinTransactionModel transaction) {
    final bool isEarned = transaction.transactionType == 'earned';
    final Color amountColor = isEarned ? AppTheme.successColor : AppTheme.errorColor;
    final String amountPrefix = isEarned ? '+' : '-';

    // Format date
    final DateTime transactionDate = DateTime.parse(transaction.createdAt);
    final String formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(transactionDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Transaction type icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTransactionIcon(transaction.transactionType, transaction.referenceType),
                color: amountColor,
              ),
            ),
            const SizedBox(width: 16),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTransactionTitle(transaction.transactionType, transaction.referenceType),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.description ?? _getDefaultDescription(transaction.transactionType, transaction.referenceType),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '$amountPrefix${transaction.amount}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: amountColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon(String transactionType, String referenceType) {
    if (transactionType == 'earned') {
      if (referenceType == 'recycling') {
        return Icons.recycling;
      } else if (referenceType == 'admin') {
        return Icons.admin_panel_settings;
      } else {
        return Icons.add_circle;
      }
    } else if (transactionType == 'spent') {
      if (referenceType == 'purchase') {
        return Icons.shopping_cart;
      } else {
        return Icons.remove_circle;
      }
    } else if (transactionType == 'refunded') {
      return Icons.replay;
    } else {
      return Icons.monetization_on;
    }
  }

  String _getTransactionTitle(String transactionType, String referenceType) {
    if (transactionType == 'earned') {
      if (referenceType == 'recycling') {
        return 'Earned from Recycling';
      } else if (referenceType == 'admin') {
        return 'Added by Admin';
      } else {
        return 'Coins Earned';
      }
    } else if (transactionType == 'spent') {
      if (referenceType == 'purchase') {
        return 'Spent on Purchase';
      } else {
        return 'Coins Spent';
      }
    } else if (transactionType == 'refunded') {
      return 'Order Refund';
    } else {
      return 'Coin Transaction';
    }
  }

  String _getDefaultDescription(String transactionType, String referenceType) {
    if (transactionType == 'earned') {
      if (referenceType == 'recycling') {
        return 'Coins earned from recycling activity';
      } else if (referenceType == 'admin') {
        return 'Coins added by administrator';
      } else {
        return 'Coins earned';
      }
    } else if (transactionType == 'spent') {
      if (referenceType == 'purchase') {
        return 'Coins spent on product purchase';
      } else {
        return 'Coins spent';
      }
    } else if (transactionType == 'refunded') {
      return 'Coins refunded from cancelled order';
    } else {
      return 'Coin transaction';
    }
  }
}
