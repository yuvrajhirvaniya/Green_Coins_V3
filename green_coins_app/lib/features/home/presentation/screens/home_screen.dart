import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:green_coins_app/features/recycling/presentation/providers/recycling_provider.dart';
import 'package:green_coins_app/features/store/presentation/providers/store_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to ensure this runs after the build is complete
    Future.microtask(() {
      if (!mounted) return;
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted || _isInitialized) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId != null) {
      try {
        // Load user coin balance
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        await profileProvider.getCoinBalance(userId);

        if (!mounted) return;

        // Update auth provider with new coin balance
        authProvider.updateCoinBalance(profileProvider.coinBalance);

        // Load featured products
        final storeProvider = Provider.of<StoreProvider>(context, listen: false);
        await storeProvider.getFeaturedProducts();

        if (!mounted) return;

        // Load recycling categories
        final recyclingProvider = Provider.of<RecyclingProvider>(context, listen: false);
        await recyclingProvider.getCategories();

        if (!mounted) return;

        // Load user recycling activities
        await recyclingProvider.getUserActivities(userId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading data: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Mark as initialized to prevent multiple loads
    if (mounted && !_isInitialized) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recyclingProvider = Provider.of<RecyclingProvider>(context);
    final storeProvider = Provider.of<StoreProvider>(context);

    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Icon(
            Icons.eco_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          AppConstants.appName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Coin Balance Indicator
          if (user != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${user.coinBalance}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              // Reset the initialization flag to allow reloading
              setState(() {
                _isInitialized = false;
              });
              _loadData();
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                // Reset the initialization flag to allow reloading
                setState(() {
                  _isInitialized = false;
                });
                return _loadData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section with user info and coin balance
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF43A047),  // Softer green
                              Color(0xFF388E3C),  // Medium green
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User info row
                              Row(
                                children: [
                                  // User avatar
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      user.fullName.isNotEmpty
                                          ? user.fullName[0].toUpperCase()
                                          : 'Y',
                                      style: TextStyle(
                                        color: Color(0xFF43A047),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Welcome text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome back,',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                        Text(
                                          user.fullName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Divider
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Divider(
                                  color: Colors.white.withOpacity(0.2),
                                  height: 1,
                                  thickness: 1,
                                ),
                              ),

                              // Balance row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Balance info
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your Coin Balance',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.monetization_on,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${user.coinBalance}',
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Earn more button
                                  ElevatedButton(
                                    onPressed: () {
                                      // Navigate to recycling screen
                                      Navigator.of(context).pushNamed('/recycling');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Color(0xFF43A047),
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Earn More',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recycling categories section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recycling Categories',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all categories
                            Navigator.of(context).pushNamed('/recycling');
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    recyclingProvider.status == RecyclingStatus.loading
                        ? const Center(child: CircularProgressIndicator())
                        : recyclingProvider.categories.isEmpty
                            ? const Center(child: Text('No recycling categories available'))
                            : SizedBox(
                                height: 180,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: recyclingProvider.categories.length,
                                  itemBuilder: (context, index) {
                                    final category = recyclingProvider.categories[index];
                                    return Container(
                                      width: 160,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            // Navigate to recycling screen with selected category
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // Category icon
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryColor.withAlpha(20),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    _getCategoryIcon(category.name),
                                                    color: AppTheme.primaryColor,
                                                    size: 30,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              // Category name
                                              Text(
                                                category.name,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                    const SizedBox(height: 24),

                    // Recent activities section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activities',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all activities
                          },
                          child: Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    recyclingProvider.activities.isEmpty
                        ? Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.recycling_rounded,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No recycling activities yet',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start recycling to earn coins!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed('/recycling');
                                    },
                                    child: const Text('Start Recycling'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recyclingProvider.activities.length > 3
                                ? 3
                                : recyclingProvider.activities.length,
                            itemBuilder: (context, index) {
                              final activity = recyclingProvider.activities[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getStatusColor(activity.status).withAlpha(30),
                                    child: Icon(
                                      _getStatusIcon(activity.status),
                                      color: _getStatusColor(activity.status),
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    activity.categoryName ?? 'Recycling Activity',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    'Status: ${activity.status.toUpperCase()} • ${activity.createdAt.substring(0, 10)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.monetization_on,
                                        color: AppTheme.primaryColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${activity.coinsEarned}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // Navigate to activity details
                                  },
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 24),

                    // Featured products section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Featured Products',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to store
                            Navigator.of(context).pushNamed('/store');
                          },
                          child: Text('View Store'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    storeProvider.status == StoreStatus.loading
                        ? const Center(child: CircularProgressIndicator())
                        : storeProvider.featuredProducts.isEmpty
                            ? Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.store_rounded,
                                        size: 40,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No featured products available',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Check back later for exciting eco-friendly products!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: storeProvider.featuredProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = storeProvider.featuredProducts[index];
                                    return Container(
                                      width: 160,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Card(
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            // Navigate to product details
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Product image
                                              Container(
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryColor.withAlpha(20),
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(12),
                                                    topRight: Radius.circular(12),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    color: AppTheme.primaryColor.withAlpha(100),
                                                    size: 40,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      product.name,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.monetization_on,
                                                          color: AppTheme.primaryColor,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${product.coinPrice}',
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: AppTheme.primaryColor,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                  ],
                ),
              ),
            ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'electronic waste':
        return Icons.devices;
      case 'plastic':
        return Icons.local_drink;
      case 'paper':
        return Icons.description;
      case 'metal':
        return Icons.settings;
      case 'glass':
        return Icons.wine_bar;
      default:
        return Icons.recycling;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return AppTheme.successColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }
}
