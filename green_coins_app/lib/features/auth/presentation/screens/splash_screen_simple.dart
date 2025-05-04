import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/core/utils/shared_prefs_helper.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/auth/presentation/screens/login_screen.dart';
import 'package:green_coins_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:green_coins_app/features/home/presentation/screens/main_screen.dart';
import 'dart:developer' as developer;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay before checking auth status
    Future.delayed(const Duration(seconds: 2), () {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    if (!mounted) return;

    // Check if user has seen onboarding
    final hasSeenOnboarding = await SharedPrefsHelper.hasSeenOnboarding();
    developer.log('Has seen onboarding: $hasSeenOnboarding', name: 'SplashScreen');

    if (!mounted) return;

    // Check authentication status
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (!mounted) return;

    // Navigate based on auth status and onboarding status
    if (!hasSeenOnboarding) {
      // First-time user, show onboarding
      developer.log('First-time user, showing onboarding screen', name: 'SplashScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else if (authProvider.status == AuthStatus.authenticated) {
      // Returning authenticated user, go to main screen
      developer.log('Returning authenticated user, navigating to MainScreen', name: 'SplashScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      // Returning unauthenticated user, go to login
      developer.log('Returning unauthenticated user, navigating to LoginScreen', name: 'SplashScreen');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple logo
            Icon(
              Icons.recycling,
              size: 80,
              color: Colors.white,
            ),
            
            const SizedBox(height: 20),
            
            // App name
            Text(
              AppConstants.appName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Simple tagline
            const Text(
              'Save Earth',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Loading indicator
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
