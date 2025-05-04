import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/home/presentation/screens/home_screen.dart';
import 'package:green_coins_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:green_coins_app/features/recycling/presentation/screens/recycling_screen.dart';
import 'package:green_coins_app/features/store/presentation/screens/store_screen.dart';
import 'package:green_coins_app/features/store/presentation/providers/store_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RecyclingScreen(),
    const StoreScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Load user data if needed
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      await authProvider.checkAuthStatus();
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    // Add haptic feedback for a better physical response
    HapticFeedback.lightImpact();

    // If switching to the store tab, preload store data
    if (index == 2 && _currentIndex != 2) {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      storeProvider.getCategories();
      storeProvider.getAllProducts();
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: AppTheme.primaryColor.withAlpha(15),
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: isDarkMode ? Colors.grey[400] : Color(0xFF9E9E9E),
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
              elevation: 0,
              items: [
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.recycling_rounded, 'Recycle', 1),
                _buildNavItem(Icons.store_rounded, 'Store', 2),
                _buildNavItem(Icons.person_rounded, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    final isSelected = index == _currentIndex;

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Icon(icon, size: 24),

          // Indicator line
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: EdgeInsets.only(top: 4),
            height: 2,
            width: isSelected ? 20 : 0,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
      label: label,
    );
  }
}
