import 'package:flutter/material.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/features/home/presentation/screens/main_screen.dart';
import 'package:green_coins_app/features/store/presentation/screens/store_screen.dart';
import 'dart:developer' as developer;

class OrderSuccessScreen extends StatelessWidget {
  final int orderId;
  final int totalAmount;

  OrderSuccessScreen({
    super.key,
    required dynamic orderId,
    required dynamic totalAmount,
  }) : orderId = orderId is String ? int.parse(orderId) : orderId,
       totalAmount = totalAmount is String ? int.parse(totalAmount) : totalAmount {
    developer.log('OrderSuccessScreen initialized with orderId: $orderId (${this.orderId.runtimeType}), totalAmount: $totalAmount (${this.totalAmount.runtimeType})',
        name: 'OrderSuccessScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Success message
                const Text(
                  'Order Placed Successfully!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Order details
                Text(
                  'Your order #$orderId has been placed successfully.',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total amount: ',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.monetization_on,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalAmount',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Thank you for your order! You can track your order status in the Orders section of your profile.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text('Go to Home'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text('Continue Shopping'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
