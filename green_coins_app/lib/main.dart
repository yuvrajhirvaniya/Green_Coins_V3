import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/core/services/service_provider.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/features/auth/data/auth_repository.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:green_coins_app/features/profile/data/profile_repository.dart';
import 'package:green_coins_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:green_coins_app/features/recycling/data/recycling_repository.dart';
import 'package:green_coins_app/features/recycling/presentation/providers/recycling_provider.dart';
import 'package:green_coins_app/features/store/data/store_repository.dart';
import 'package:green_coins_app/features/store/presentation/providers/cart_provider.dart';
import 'package:green_coins_app/features/store/presentation/providers/store_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authRepository: AuthRepository(),
          ),
        ),

        // Recycling provider
        ChangeNotifierProvider(
          create: (_) => RecyclingProvider(
            recyclingRepository: RecyclingRepository(),
          ),
        ),

        // Store provider
        ChangeNotifierProvider(
          create: (_) => StoreProvider(
            storeRepository: StoreRepository(),
          ),
        ),

        // Cart provider
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),

        // Profile provider
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            profileRepository: ProfileRepository(),
          ),
        ),
      ],
      child: ServiceProvider(
        child: MaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
