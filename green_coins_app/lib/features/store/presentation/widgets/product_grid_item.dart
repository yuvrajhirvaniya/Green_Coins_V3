import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:green_coins_app/features/store/domain/models/product_model.dart';
import 'package:green_coins_app/features/store/presentation/providers/cart_provider.dart';

class ProductGridItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  // Helper method to get appropriate icon based on product category
  IconData _getProductIcon(String? categoryName) {
    if (categoryName == null) return Icons.shopping_bag;

    switch (categoryName.toLowerCase()) {
      case 'eco-friendly home':
        return Icons.home;
      case 'organic products':
        return Icons.spa;
      case 'sustainable fashion':
        return Icons.checkroom;
      case 'reusable items':
        return Icons.repeat;
      case 'energy efficient':
        return Icons.bolt;
      default:
        return Icons.shopping_bag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive height based on screen width
    // More granular adjustments for different screen sizes
    final imageContainerHeight = screenWidth < 320 ? 100.0 :
                               screenWidth < 360 ? 110.0 :
                               screenWidth < 400 ? 120.0 : 140.0;

    final user = authProvider.user;
    final bool canAfford = user != null && user.coinBalance >= product.coinPrice;
    final bool isInStock = product.stockQuantity > 0;
    final bool isInCart = cartProvider.containsProduct(product.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product image with decorative elements
            Stack(
              children: [
                Container(
                  height: imageContainerHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles in the background
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -15,
                        left: -15,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ),

                      // Product image
                      Center(
                        child: Container(
                          width: screenWidth < 360 ? 70 : 80,
                          height: screenWidth < 360 ? 70 : 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: product.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: Image.network(
                                      'https://via.placeholder.com/150', // Replace with actual image URL
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          _getProductIcon(product.categoryName),
                                          color: AppTheme.primaryColor,
                                          size: 32,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    _getProductIcon(product.categoryName),
                                    color: AppTheme.primaryColor,
                                    size: 32,
                                  ),
                          ),
                        ),
                      ),

                      // Eco-friendly indicator
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(30),
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.eco,
                            color: AppTheme.primaryColor,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (product.isFeatured)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 8,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Featured',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!isInStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(70),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(30),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Out of Stock',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
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

            // Product info with improved layout
            Container(
              padding: EdgeInsets.fromLTRB(
                screenWidth < 360 ? 8 : 12,
                screenWidth < 360 ? 8 : 12,
                screenWidth < 360 ? 8 : 12,
                screenWidth < 360 ? 4 : 6
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product name with shadow effect
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: screenWidth < 360 ? 4 : 6),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withAlpha(40),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth < 360 ? 12 : 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: screenWidth < 360 ? 2 : 4),

                  // Category and price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category badge
                      if (product.categoryName != null)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withAlpha(15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getProductIcon(product.categoryName),
                                  color: AppTheme.primaryColor,
                                  size: 10,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    product.categoryName!,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Price badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                              size: 10,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${product.coinPrice}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Product details section - simplified for smaller screens
                  Container(
                    padding: EdgeInsets.symmetric(vertical: screenWidth < 360 ? 4 : 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Rating - simplified for smaller screens
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Color(0xFFFFC107),
                                  size: screenWidth < 360 ? 10 : 12,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  '4.5',
                                  style: TextStyle(
                                    fontSize: screenWidth < 360 ? 9 : 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Rating',
                              style: TextStyle(
                                fontSize: screenWidth < 360 ? 7 : 8,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        // Vertical divider
                        Container(
                          height: screenWidth < 360 ? 16 : 20,
                          width: 1,
                          color: Colors.grey.withAlpha(40),
                        ),

                        // Stock - only show this on smaller screens for space
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  color: isInStock ? Colors.blue : Colors.red,
                                  size: screenWidth < 360 ? 10 : 12,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  isInStock ? '${product.stockQuantity}' : '0',
                                  style: TextStyle(
                                    fontSize: screenWidth < 360 ? 9 : 10,
                                    fontWeight: FontWeight.bold,
                                    color: isInStock ? Colors.black87 : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              'In Stock',
                              style: TextStyle(
                                fontSize: screenWidth < 360 ? 7 : 8,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenWidth < 360 ? 4 : 6),

                  // Add to cart button - more responsive
                  SizedBox(
                    width: double.infinity,
                    height: screenWidth < 360 ? 28 : 32,
                    child: ElevatedButton(
                      onPressed: isInStock && canAfford && !isInCart
                          ? () {
                              cartProvider.addItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to cart'),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    onPressed: () {
                                      Navigator.of(context).pushNamed('/cart');
                                    },
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: isInCart ? Colors.grey : AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isInCart ? Icons.shopping_cart_checkout : Icons.add_shopping_cart,
                            size: screenWidth < 360 ? 12 : 14,
                          ),
                          SizedBox(width: screenWidth < 360 ? 2 : 4),
                          // Simplified text for smaller screens with more granular control
                          Text(
                            screenWidth < 320
                                ? (isInCart
                                    ? 'In Cart'
                                    : !isInStock
                                        ? 'Out'
                                        : !canAfford
                                            ? 'Need Coins'
                                            : 'Add')
                                : screenWidth < 360
                                    ? (isInCart
                                        ? 'In Cart'
                                        : !isInStock
                                            ? 'Out of Stock'
                                            : !canAfford
                                                ? 'Need Coins'
                                                : 'Add')
                                    : (isInCart
                                        ? 'In Cart'
                                        : !isInStock
                                            ? 'Out of Stock'
                                            : !canAfford
                                                ? 'Not Enough Coins'
                                                : 'Add to Cart'),
                            style: TextStyle(
                              fontSize: screenWidth < 320 ? 9 : screenWidth < 360 ? 10 : 11,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
