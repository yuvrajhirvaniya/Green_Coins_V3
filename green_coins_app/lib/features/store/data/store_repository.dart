import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/core/network/api_service.dart';
import 'package:green_coins_app/features/store/domain/models/order_model.dart';
import 'package:green_coins_app/features/store/domain/models/product_category_model.dart';
import 'package:green_coins_app/features/store/domain/models/product_model.dart';
import 'dart:developer' as developer;

class StoreRepository {
  final ApiService _apiService;

  StoreRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      print('StoreRepository: Getting all products from ${AppConstants.productsEndpoint}');
      final response = await _apiService.get(AppConstants.productsEndpoint);
      print('StoreRepository: Response received: $response');

      final List<ProductModel> products = [];

      if (response != null && response['records'] != null) {
        print('StoreRepository: Processing ${response['records'].length} products');
        for (var product in response['records']) {
          try {
            products.add(ProductModel.fromJson(product));
          } catch (parseError) {
            print('StoreRepository: Error parsing product: $parseError');
            print('StoreRepository: Product data: $product');
          }
        }
      } else {
        print('StoreRepository: No records found in response');
      }

      print('StoreRepository: Returning ${products.length} products');
      return products;
    } catch (e) {
      print('StoreRepository: Error getting all products: $e');
      throw Exception('Failed to load products: ${e.toString()}');
    }
  }

  // Get featured products
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await _apiService.get(AppConstants.featuredProductsEndpoint);

      final List<ProductModel> products = [];

      if (response != null && response['records'] != null) {
        for (var product in response['records']) {
          products.add(ProductModel.fromJson(product));
        }
      }

      return products;
    } catch (e) {
      // Return empty list instead of throwing exception
      return [];
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    try {
      final response = await _apiService.get(
        AppConstants.productsByCategoryEndpoint,
        queryParameters: {'category_id': categoryId},
      );

      final List<ProductModel> products = [];

      for (var product in response['records']) {
        products.add(ProductModel.fromJson(product));
      }

      return products;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Get product details
  Future<ProductModel> getProduct(int productId) async {
    try {
      final response = await _apiService.get(
        AppConstants.productEndpoint,
        queryParameters: {'id': productId},
      );

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Get all product categories
  Future<List<ProductCategoryModel>> getCategories() async {
    try {
      print('StoreRepository: Getting categories from ${AppConstants.productCategoriesEndpoint}');
      final response = await _apiService.get(AppConstants.productCategoriesEndpoint);
      print('StoreRepository: Categories response received: $response');

      final List<ProductCategoryModel> categories = [];

      if (response != null && response['records'] != null) {
        print('StoreRepository: Processing ${response['records'].length} categories');
        for (var category in response['records']) {
          try {
            categories.add(ProductCategoryModel.fromJson(category));
          } catch (parseError) {
            print('StoreRepository: Error parsing category: $parseError');
            print('StoreRepository: Category data: $category');
          }
        }
      } else {
        print('StoreRepository: No category records found in response');
      }

      print('StoreRepository: Returning ${categories.length} categories');
      return categories;
    } catch (e) {
      print('StoreRepository: Error getting categories: $e');
      // Return empty list instead of throwing exception
      return [];
    }
  }

  // Create order
  Future<Map<String, dynamic>> createOrder({
    required int userId,
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
    required String contactPhone,
    String? notes,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'items': items,
        'shipping_address': shippingAddress,
        'contact_phone': contactPhone,
        'notes': notes,
      };

      final response = await _apiService.post(AppConstants.createOrderEndpoint, data: data);

      developer.log('Order creation response: $response', name: 'StoreRepository');

      // Parse the id and total_coin_amount to ensure they are integers
      final orderId = response['id'] is String ? int.parse(response['id']) : response['id'];
      final totalAmount = response['total_coin_amount'] is String
          ? int.parse(response['total_coin_amount'])
          : response['total_coin_amount'];

      developer.log('Parsed orderId: $orderId (${orderId.runtimeType}), totalAmount: $totalAmount (${totalAmount.runtimeType})',
          name: 'StoreRepository');

      return {
        'id': orderId,
        'total_coin_amount': totalAmount,
      };
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Get user orders
  Future<List<OrderModel>> getUserOrders(int userId) async {
    try {
      developer.log('Getting orders for user ID: $userId', name: 'StoreRepository');

      final response = await _apiService.get(
        AppConstants.userOrdersEndpoint,
        queryParameters: {'user_id': userId},
      );

      developer.log('User orders response: $response', name: 'StoreRepository');

      final List<OrderModel> orders = [];

      if (response != null && response.containsKey('records') && response['records'] != null) {
        developer.log('Found ${response['records'].length} orders', name: 'StoreRepository');

        for (var order in response['records']) {
          try {
            developer.log('Processing order: $order', name: 'StoreRepository');
            orders.add(OrderModel.fromJson(order));
          } catch (parseError) {
            developer.log('Error parsing order: $parseError, order data: $order', name: 'StoreRepository');
          }
        }
      } else {
        developer.log('No records found in response or invalid response format', name: 'StoreRepository');
      }

      developer.log('Returning ${orders.length} orders', name: 'StoreRepository');
      return orders;
    } catch (e) {
      developer.log('Error getting user orders: $e', name: 'StoreRepository');
      throw Exception(e.toString());
    }
  }

  // Get order details
  Future<OrderModel> getOrder(int orderId) async {
    try {
      developer.log('Getting order details for order ID: $orderId', name: 'StoreRepository');

      final response = await _apiService.get(
        AppConstants.orderEndpoint,
        queryParameters: {'id': orderId},
      );

      developer.log('Order details response: $response', name: 'StoreRepository');

      try {
        final order = OrderModel.fromJson(response);
        developer.log('Parsed order: ${order.id}, status: ${order.status}, items: ${order.items?.length ?? 0}', name: 'StoreRepository');
        return order;
      } catch (parseError) {
        developer.log('Error parsing order: $parseError', name: 'StoreRepository');
        rethrow;
      }
    } catch (e) {
      developer.log('Error getting order details: $e', name: 'StoreRepository');
      throw Exception(e.toString());
    }
  }
}
