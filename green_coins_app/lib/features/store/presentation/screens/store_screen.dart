import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/store/domain/models/product_category_model.dart';
import 'package:green_coins_app/features/store/presentation/providers/cart_provider.dart';
import 'package:green_coins_app/features/store/presentation/providers/store_provider.dart';
import 'package:green_coins_app/features/store/presentation/screens/cart_screen.dart';
import 'package:green_coins_app/features/store/presentation/screens/product_detail_screen.dart';
import 'package:green_coins_app/features/store/presentation/widgets/product_grid_item.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  ProductCategoryModel? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool showSuccessMessage = false}) async {
    print('StoreScreen: Loading data...');
    setState(() {
      _isLoading = true;
    });

    final storeProvider = Provider.of<StoreProvider>(context, listen: false);

    try {
      // Load categories
      print('StoreScreen: Loading categories...');
      await storeProvider.getCategories();
      print('StoreScreen: Categories loaded: ${storeProvider.categories.length}');

      // Load all products initially
      print('StoreScreen: Loading all products...');
      await storeProvider.getAllProducts();
      print('StoreScreen: Products loaded: ${storeProvider.products.length}');

      // Show success message if requested (e.g., after pull-to-refresh)
      if (showSuccessMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Products refreshed successfully'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('StoreScreen: Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading store data: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('StoreScreen: Loading completed, isLoading = $_isLoading');
      }
    }
  }

  // Method specifically for pull-to-refresh
  Future<void> _handleRefresh() async {
    print('StoreScreen: Pull-to-refresh triggered');
    await _loadData(showSuccessMessage: true);
    return;
  }

  Future<void> _selectCategory(ProductCategoryModel? category) async {
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });

    final storeProvider = Provider.of<StoreProvider>(context, listen: false);

    try {
      if (category == null) {
        // Load all products
        await storeProvider.getAllProducts();
      } else {
        // Load products by category
        await storeProvider.getProductsByCategory(category.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToProductDetail(int productId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: productId),
      ),
    );
  }

  void _navigateToCart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CartScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final storeProvider = Provider.of<StoreProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Store'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _navigateToCart,
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Coin balance - full width
                Container(
                  width: double.infinity,
                  color: AppTheme.primaryColor.withAlpha(25), // 0.1 * 255 = ~25
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isSmallScreen = screenWidth < 360;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 16,
                          vertical: isSmallScreen ? 8 : 16,
                        ),
                        child: Row(
                          children: [
                            // Wallet icon
                            Icon(
                              Icons.account_balance_wallet,
                              color: AppTheme.primaryColor,
                              size: isSmallScreen ? 18 : 24,
                            ),
                            SizedBox(width: isSmallScreen ? 4 : 8),

                            // "Your Balance:" text
                            Text(
                              'Your Balance:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 4 : 8),

                            // Coin icon and balance amount
                            Icon(
                              Icons.monetization_on,
                              color: AppTheme.primaryColor,
                              size: isSmallScreen ? 14 : 16,
                            ),
                            SizedBox(width: isSmallScreen ? 2 : 4),
                            Text(
                              '${user.coinBalance}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),

                            // Add spacer to push everything to the left
                            Spacer(),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Categories - more responsive
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isSmallScreen = screenWidth < 360;

                    return Container(
                      height: isSmallScreen ? 40 : 50,
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
                      child: storeProvider.categories.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: storeProvider.categories.length + 1, // +1 for "All" category
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // "All" category
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
                                    child: ChoiceChip(
                                      label: Text(
                                        'All',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 11 : 14,
                                        ),
                                      ),
                                      labelPadding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 4 : 8,
                                        vertical: isSmallScreen ? 0 : 2,
                                      ),
                                      padding: EdgeInsets.all(isSmallScreen ? 0 : 2),
                                      selected: _selectedCategory == null,
                                      onSelected: (selected) {
                                        if (selected) {
                                          _selectCategory(null);
                                        }
                                      },
                                    ),
                                  );
                                } else {
                                  final category = storeProvider.categories[index - 1];
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
                                    child: ChoiceChip(
                                      label: Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 11 : 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      labelPadding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 4 : 8,
                                        vertical: isSmallScreen ? 0 : 2,
                                      ),
                                      padding: EdgeInsets.all(isSmallScreen ? 0 : 2),
                                      selected: _selectedCategory?.id == category.id,
                                      onSelected: (selected) {
                                        if (selected) {
                                          _selectCategory(category);
                                        }
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                    );
                  },
                ),

                // Products
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : storeProvider.products.isEmpty
                          ? RefreshIndicator(
                              onRefresh: _handleRefresh,
                              color: AppTheme.primaryColor,
                              backgroundColor: Colors.white,
                              displacement: 40,
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(), // Ensures refresh works even when content doesn't fill screen
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.shopping_bag_outlined,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'No products found',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Try selecting a different category',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          ElevatedButton.icon(
                                            onPressed: () => _selectCategory(null),
                                            icon: const Icon(Icons.category),
                                            label: const Text('Show All Products'),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Pull down to refresh',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _handleRefresh,
                              color: AppTheme.primaryColor,
                              backgroundColor: Colors.white,
                              displacement: 40,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // Calculate responsive values based on available width
                                  final double availableWidth = constraints.maxWidth;
                                  final double padding = availableWidth < 360 ? 4.0 :
                                                        availableWidth < 400 ? 8.0 : 16.0;
                                  final double spacing = availableWidth < 360 ? 4.0 :
                                                        availableWidth < 400 ? 8.0 : 16.0;

                                  // Calculate aspect ratio based on screen size
                                  // Smaller screens need taller cards (smaller aspect ratio)
                                  // Use a more aggressive scaling for very small screens
                                  final double aspectRatio = availableWidth < 320 ? 0.52 :
                                                           availableWidth < 360 ? 0.55 :
                                                           availableWidth < 400 ? 0.58 : 0.62;

                                  return GridView.builder(
                                    padding: EdgeInsets.all(padding),
                                    physics: const AlwaysScrollableScrollPhysics(), // Ensures refresh works even when content doesn't fill screen
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: aspectRatio,
                                      crossAxisSpacing: spacing,
                                      mainAxisSpacing: spacing,
                                    ),
                                    itemCount: storeProvider.products.length,
                                    itemBuilder: (context, index) {
                                      final product = storeProvider.products[index];
                                      return ProductGridItem(
                                        product: product,
                                        onTap: () => _navigateToProductDetail(product.id),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
    );
  }
}
