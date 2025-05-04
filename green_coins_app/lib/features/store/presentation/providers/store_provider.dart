import 'package:flutter/material.dart';
import 'package:green_coins_app/features/store/data/store_repository.dart';
import 'package:green_coins_app/features/store/domain/models/order_model.dart';
import 'package:green_coins_app/features/store/domain/models/product_category_model.dart';
import 'package:green_coins_app/features/store/domain/models/product_model.dart';
import 'dart:developer' as developer;

enum StoreStatus {
  initial,
  loading,
  success,
  error,
}

class StoreProvider extends ChangeNotifier {
  final StoreRepository _storeRepository;

  StoreStatus _status = StoreStatus.initial;
  List<ProductCategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  ProductModel? _selectedProduct;
  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  String _errorMessage = '';

  StoreProvider({required StoreRepository storeRepository})
      : _storeRepository = storeRepository;

  // Getters
  StoreStatus get status => _status;
  List<ProductCategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  ProductModel? get selectedProduct => _selectedProduct;
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  String get errorMessage => _errorMessage;

  // Get all product categories
  Future<void> getCategories() async {
    print('StoreProvider: Getting categories');
    _status = StoreStatus.loading;
    notifyListeners();

    try {
      final categories = await _storeRepository.getCategories();
      print('StoreProvider: Received ${categories.length} categories');
      _categories = categories;
      _status = StoreStatus.success;
    } catch (e) {
      print('StoreProvider: Error getting categories: $e');
      // Just set empty categories and success status instead of error
      // This prevents the UI from showing an error when there are no categories
      _categories = [];
      _status = StoreStatus.success;

      // Store the error message but don't show it to the user
      _errorMessage = e.toString();
    }

    print('StoreProvider: Notifying listeners with status: $_status, categories: ${_categories.length}');
    notifyListeners();
  }

  // Get all products
  Future<void> getAllProducts() async {
    print('StoreProvider: Getting all products');
    _status = StoreStatus.loading;
    notifyListeners();

    try {
      final products = await _storeRepository.getAllProducts();
      print('StoreProvider: Received ${products.length} products');
      _products = products;
      _status = StoreStatus.success;
    } catch (e) {
      print('StoreProvider: Error getting all products: $e');
      _status = StoreStatus.error;
      _errorMessage = e.toString();
    }

    print('StoreProvider: Notifying listeners with status: $_status, products: ${_products.length}');
    notifyListeners();
  }

  // Get featured products
  Future<void> getFeaturedProducts() async {
    _status = StoreStatus.loading;
    notifyListeners();

    try {
      final products = await _storeRepository.getFeaturedProducts();
      _featuredProducts = products;
      _status = StoreStatus.success;
    } catch (e) {
      // Just set empty products and success status instead of error
      // This prevents the UI from showing an error when there are no products
      _featuredProducts = [];
      _status = StoreStatus.success;

      // Store the error message but don't show it to the user
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Get products by category
  Future<void> getProductsByCategory(int categoryId) async {
    _status = StoreStatus.loading;
    notifyListeners();

    try {
      final products = await _storeRepository.getProductsByCategory(categoryId);
      _products = products;
      _status = StoreStatus.success;
    } catch (e) {
      _status = StoreStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Get product details
  Future<void> getProduct(int productId) async {
    _status = StoreStatus.loading;
    notifyListeners();

    try {
      final product = await _storeRepository.getProduct(productId);
      _selectedProduct = product;
      _status = StoreStatus.success;
    } catch (e) {
      _status = StoreStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Create order
  Future<Map<String, dynamic>> createOrder({
    required int userId,
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
    required String contactPhone,
    String? notes,
  }) async {
    _status = StoreStatus.loading;
    notifyListeners();

    try {
      final result = await _storeRepository.createOrder(
        userId: userId,
        items: items,
        shippingAddress: shippingAddress,
        contactPhone: contactPhone,
        notes: notes,
      );

      _status = StoreStatus.success;
      notifyListeners();

      return result;
    } catch (e) {
      _status = StoreStatus.error;
      _errorMessage = e.toString();
      notifyListeners();

      return {'error': e.toString()};
    }
  }

  // Get user orders
  Future<void> getUserOrders(int userId) async {
    developer.log('Getting user orders for user ID: $userId', name: 'StoreProvider');
    _status = StoreStatus.loading;
    notifyListeners();

    try {
      final orders = await _storeRepository.getUserOrders(userId);
      developer.log('Received ${orders.length} orders', name: 'StoreProvider');
      _orders = orders;
      _status = StoreStatus.success;
    } catch (e) {
      developer.log('Error getting user orders: $e', name: 'StoreProvider');
      _status = StoreStatus.error;
      _errorMessage = e.toString();
    }

    developer.log('Notifying listeners with status: $_status, orders: ${_orders.length}', name: 'StoreProvider');
    notifyListeners();
  }

  // Get order details
  Future<void> getOrder(int orderId) async {
    developer.log('Getting order details for order ID: $orderId', name: 'StoreProvider');
    _status = StoreStatus.loading;
    notifyListeners();

    try {
      final order = await _storeRepository.getOrder(orderId);
      developer.log('Received order details: ${order.id}, status: ${order.status}, items: ${order.items?.length ?? 0}', name: 'StoreProvider');
      _selectedOrder = order;
      _status = StoreStatus.success;
    } catch (e) {
      developer.log('Error getting order details: $e', name: 'StoreProvider');
      _status = StoreStatus.error;
      _errorMessage = e.toString();
    }

    developer.log('Notifying listeners with status: $_status', name: 'StoreProvider');
    notifyListeners();
  }

  // Reset selected product
  void resetSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  // Reset selected order
  void resetSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  // Reset error
  void resetError() {
    _errorMessage = '';
    notifyListeners();
  }
}
