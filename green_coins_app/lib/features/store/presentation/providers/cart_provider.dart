import 'package:flutter/material.dart';
import 'package:green_coins_app/features/store/domain/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  
  CartItem({
    required this.product,
    this.quantity = 1,
  });
  
  int get totalPrice => product.coinPrice * quantity;
  
  CartItem copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  
  // Getters
  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  
  // Get total items quantity
  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }
  
  // Get total price
  int get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }
  
  // Check if cart contains a product
  bool containsProduct(int productId) {
    return _items.any((item) => item.product.id == productId);
  }
  
  // Get cart item by product ID
  CartItem? getCartItem(int productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }
  
  // Add item to cart
  void addItem(ProductModel product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      // Update quantity if product already in cart
      _items[existingIndex].quantity += quantity;
    } else {
      // Add new item to cart
      _items.add(CartItem(product: product, quantity: quantity));
    }
    
    notifyListeners();
  }
  
  // Update item quantity
  void updateItemQuantity(int productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    
    if (index >= 0) {
      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        _items.removeAt(index);
      } else {
        // Update quantity
        _items[index].quantity = quantity;
      }
      
      notifyListeners();
    }
  }
  
  // Remove item from cart
  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }
  
  // Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
  
  // Get cart items as list of maps for order creation
  List<Map<String, dynamic>> getItemsForOrder() {
    return _items.map((item) => {
      'product_id': item.product.id,
      'quantity': item.quantity,
    }).toList();
  }
}
