import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/auth/presentation/screens/login_screen.dart';
import 'package:green_coins_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:green_coins_app/features/profile/presentation/screens/coin_history_screen.dart';
import 'package:green_coins_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:green_coins_app/features/store/presentation/providers/store_provider.dart';
import 'package:green_coins_app/features/store/presentation/screens/my_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId != null) {
      // Load user coin balance
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      await profileProvider.getCoinBalance(userId);

      if (!mounted) return;

      // Update auth provider with new coin balance
      authProvider.updateCoinBalance(profileProvider.coinBalance);

      // Load user orders
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      await storeProvider.getUserOrders(userId);
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final storeProvider = Provider.of<StoreProvider>(context);

    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // User avatar and name - more responsive
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final screenWidth = MediaQuery.of(context).size.width;
                                final isSmallScreen = screenWidth < 360;
                                final avatarRadius = isSmallScreen ? 30.0 : 40.0;

                                return Row(
                                  children: [
                                    CircleAvatar(
                                      radius: avatarRadius,
                                      backgroundColor: AppTheme.primaryColor,
                                      child: Text(
                                        user.fullName.isNotEmpty
                                            ? user.fullName[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isSmallScreen ? 24 : 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: isSmallScreen ? 8 : 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.fullName,
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 16 : 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: isSmallScreen ? 2 : 4),
                                          Text(
                                            user.username,
                                            style: TextStyle(
                                              color: AppTheme.textSecondaryColor,
                                              fontSize: isSmallScreen ? 12 : 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: isSmallScreen ? 2 : 4),
                                          Text(
                                            user.email,
                                            style: TextStyle(
                                              color: AppTheme.textSecondaryColor,
                                              fontSize: isSmallScreen ? 12 : 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Coin balance - attractive but not too fancy
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final screenWidth = MediaQuery.of(context).size.width;
                                final isSmallScreen = screenWidth < 360;

                                return Container(
                                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(15),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withAlpha(40),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // Attractive coin icon with background
                                          Container(
                                            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withAlpha(30),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.monetization_on,
                                              color: AppTheme.primaryColor,
                                              size: isSmallScreen ? 22 : 28,
                                            ),
                                          ),
                                          SizedBox(width: isSmallScreen ? 10 : 16),

                                          // Balance info with improved typography
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Coin Balance',
                                                style: TextStyle(
                                                  fontSize: isSmallScreen ? 14 : 16,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: isSmallScreen ? 2 : 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    '${user.coinBalance}',
                                                    style: TextStyle(
                                                      fontSize: isSmallScreen ? 20 : 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.primaryColor,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'coins',
                                                    style: TextStyle(
                                                      fontSize: isSmallScreen ? 12 : 14,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Spacer(),

                                          // Attractive "View History" button
                                          if (constraints.maxWidth > 320)
                                            Container(
                                              height: isSmallScreen ? 32 : 36,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(18),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppTheme.primaryColor,
                                                    Color.fromARGB(255, 76, 175, 80), // Slightly lighter shade
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppTheme.primaryColor.withAlpha(40),
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => const CoinHistoryScreen(),
                                                      ),
                                                    );
                                                  },
                                                  borderRadius: BorderRadius.circular(18),
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: isSmallScreen ? 12 : 16,
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.history,
                                                          color: Colors.white,
                                                          size: isSmallScreen ? 14 : 16,
                                                        ),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          'View History',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: isSmallScreen ? 12 : 14,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      // If screen is too small, show button below
                                      if (constraints.maxWidth <= 320)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 12),
                                          child: Container(
                                            width: double.infinity,
                                            height: isSmallScreen ? 36 : 40,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppTheme.primaryColor,
                                                  Color.fromARGB(255, 76, 175, 80), // Slightly lighter shade
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.primaryColor.withAlpha(40),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => const CoinHistoryScreen(),
                                                    ),
                                                  );
                                                },
                                                borderRadius: BorderRadius.circular(20),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.history,
                                                          color: Colors.white,
                                                          size: isSmallScreen ? 16 : 18,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          'View History',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: isSmallScreen ? 14 : 16,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Edit profile button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfileScreen(),
                                    ),
                                  ).then((_) => _loadData());
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Profile'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile menu
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // My Orders
                    _buildMenuCard(
                      icon: Icons.shopping_bag,
                      title: 'My Orders',
                      subtitle: 'View your order history',
                      trailing: storeProvider.orders.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${storeProvider.orders.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MyOrdersScreen(),
                          ),
                        );
                      },
                    ),

                    // Coin History
                    _buildMenuCard(
                      icon: Icons.history,
                      title: 'Coin History',
                      subtitle: 'View your coin transactions',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CoinHistoryScreen(),
                          ),
                        );
                      },
                    ),

                    // Settings
                    _buildMenuCard(
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'App preferences and notifications',
                      onTap: () {
                        // Navigate to settings screen
                      },
                    ),

                    // Help & Support
                    _buildMenuCard(
                      icon: Icons.help,
                      title: 'Help & Support',
                      subtitle: 'Contact us and FAQs',
                      onTap: () {
                        // Navigate to help screen
                      },
                    ),

                    // About
                    _buildMenuCard(
                      icon: Icons.info,
                      title: 'About',
                      subtitle: 'App version and information',
                      trailing: Text(
                        'v${AppConstants.appVersion}',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      onTap: () {
                        // Show about dialog
                      },
                    ),



                    const SizedBox(height: 24),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
