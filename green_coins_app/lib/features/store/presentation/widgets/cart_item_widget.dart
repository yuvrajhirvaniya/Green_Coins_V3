import 'package:flutter/material.dart';
import 'package:green_coins_app/core/theme/app_theme.dart';
import 'package:green_coins_app/features/store/presentation/providers/cart_provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    // Responsive dimensions
    final double imageSize = isSmallScreen ? 70 : 80;
    final double padding = isSmallScreen ? 8 : 12;
    final double spacing = isSmallScreen ? 8 : 16;

    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: cartItem.product.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://via.placeholder.com/80', // Replace with actual image URL
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image,
                              color: AppTheme.primaryColor.withOpacity(0.5),
                              size: isSmallScreen ? 24 : 32,
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.image,
                        color: AppTheme.primaryColor.withOpacity(0.5),
                        size: isSmallScreen ? 24 : 32,
                      ),
                    ),
            ),
            SizedBox(width: spacing),

            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  if (cartItem.product.categoryName != null)
                    Text(
                      cartItem.product.categoryName!,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: isSmallScreen ? 4 : 8),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: AppTheme.primaryColor,
                        size: isSmallScreen ? 14 : 16,
                      ),
                      SizedBox(width: isSmallScreen ? 2 : 4),
                      Text(
                        '${cartItem.product.coinPrice}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 8),

                  // Quantity controls - more responsive layout
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: isSmallScreen ? 4 : 8,
                    runSpacing: isSmallScreen ? 4 : 8,
                    children: [
                      // Quantity controls in a row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: isSmallScreen ? 32 : 36,
                            height: isSmallScreen ? 32 : 36,
                            child: IconButton(
                              onPressed: cartItem.quantity > 1
                                  ? () => onQuantityChanged(cartItem.quantity - 1)
                                  : null,
                              icon: Icon(Icons.remove, size: isSmallScreen ? 16 : 18),
                              padding: EdgeInsets.zero,
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  AppTheme.primaryColor.withOpacity(0.1),
                                ),
                                minimumSize: WidgetStateProperty.all(
                                  Size(isSmallScreen ? 28 : 36, isSmallScreen ? 28 : 36),
                                ),
                                padding: WidgetStateProperty.all(EdgeInsets.zero),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4 : 8),
                            child: Text(
                              '${cartItem.quantity}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: isSmallScreen ? 32 : 36,
                            height: isSmallScreen ? 32 : 36,
                            child: IconButton(
                              onPressed: cartItem.quantity < cartItem.product.stockQuantity
                                  ? () => onQuantityChanged(cartItem.quantity + 1)
                                  : null,
                              icon: Icon(Icons.add, size: isSmallScreen ? 16 : 18),
                              padding: EdgeInsets.zero,
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  AppTheme.primaryColor.withOpacity(0.1),
                                ),
                                minimumSize: WidgetStateProperty.all(
                                  Size(isSmallScreen ? 28 : 36, isSmallScreen ? 28 : 36),
                                ),
                                padding: WidgetStateProperty.all(EdgeInsets.zero),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Total price
                      Text(
                        'Total: ${cartItem.totalPrice}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Remove button - more responsive
            SizedBox(
              width: isSmallScreen ? 32 : 40,
              height: isSmallScreen ? 32 : 40,
              child: IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete,
                  size: isSmallScreen ? 18 : 20,
                ),
                padding: EdgeInsets.zero,
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
