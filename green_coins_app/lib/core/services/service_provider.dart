import 'package:flutter/material.dart';
import 'package:green_coins_app/core/services/background_sync_service.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class ServiceProvider extends StatefulWidget {
  final Widget child;

  const ServiceProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ServiceProvider> createState() => _ServiceProviderState();
}

class _ServiceProviderState extends State<ServiceProvider> {
  final BackgroundSyncService _syncService = BackgroundSyncService();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      _initializeServices();
      _isInitialized = true;
    }
  }

  void _initializeServices() {
    // Get providers
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    
    // Listen for auth state changes
    authProvider.addListener(() {
      if (authProvider.isAuthenticated) {
        // Start background sync service when user is authenticated
        _syncService.startService(authProvider, profileProvider);
      } else {
        // Stop background sync service when user is not authenticated
        _syncService.stopService();
      }
    });
    
    // Start service if user is already authenticated
    if (authProvider.isAuthenticated) {
      _syncService.startService(authProvider, profileProvider);
    }
  }

  @override
  void dispose() {
    // Stop background sync service
    _syncService.stopService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
