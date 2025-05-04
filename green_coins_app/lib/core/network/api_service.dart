import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from shared preferences
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.tokenKey);

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
            print('REQUEST BODY: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
            print('RESPONSE DATA: ${response.data}');
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
            print('ERROR MESSAGE: ${e.message}');
            print('ERROR DATA: ${e.response?.data}');
          }

          return handler.next(e);
        },
      ),
    );
  }

  // GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      // Special handling for recycling endpoints - allow 404 responses
      if (endpoint == AppConstants.userRecyclingActivitiesEndpoint ||
          endpoint == AppConstants.recyclingCategoriesEndpoint) {
        try {
          print('ApiService: Making GET request to $endpoint with params: $queryParameters');
          final response = await _dio.get(
            endpoint,
            queryParameters: queryParameters,
          );

          print('ApiService: Response received for $endpoint: ${response.statusCode}');
          print('ApiService: Response data: ${response.data}');

          // Check if the response data is valid
          if (response.data == null) {
            print('ApiService: Response data is null, returning empty records');
            return {'records': []};
          }

          // Check if the response data has the expected format
          if (response.data is Map && !response.data.containsKey('records')) {
            print('ApiService: Response data does not contain records key, adding it');
            return {'records': response.data is List ? response.data : []};
          }

          return response.data;
        } on DioException catch (e) {
          print('ApiService: DioException for $endpoint: ${e.message}');
          // If it's a 404, return an empty records array
          if (e.response?.statusCode == 404) {
            print('ApiService: 404 response, returning empty records');
            return {'records': []};
          }
          // Otherwise, handle the error normally
          _handleError(e);
        }
      } else {
        // Normal handling for other endpoints
        print('ApiService: Making GET request to $endpoint with params: $queryParameters');
        final response = await _dio.get(
          endpoint,
          queryParameters: queryParameters,
        );

        print('ApiService: Response received for $endpoint: ${response.statusCode}');
        print('ApiService: Response data: ${response.data}');

        return response.data;
      }
    } on DioException catch (e) {
      _handleError(e);
    } on SocketException {
      throw Exception(AppConstants.networkErrorMessage);
    } catch (e) {
      throw Exception(AppConstants.unknownErrorMessage);
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data is String ? data : jsonEncode(data),
      );

      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    } on SocketException {
      throw Exception(AppConstants.networkErrorMessage);
    } catch (e) {
      throw Exception(AppConstants.unknownErrorMessage);
    }
  }

  // PUT request
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data is String ? data : jsonEncode(data),
      );

      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    } on SocketException {
      throw Exception(AppConstants.networkErrorMessage);
    } catch (e) {
      throw Exception(AppConstants.unknownErrorMessage);
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data is String ? data : jsonEncode(data),
      );

      return response.data;
    } on DioException catch (e) {
      _handleError(e);
    } on SocketException {
      throw Exception(AppConstants.networkErrorMessage);
    } catch (e) {
      throw Exception(AppConstants.unknownErrorMessage);
    }
  }

  // Handle Dio errors
  void _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw Exception('Connection timeout. Please try again.');

      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        } else if (e.response?.statusCode == 404) {
          throw Exception('Resource not found.');
        } else if (e.response?.statusCode == 500) {
          throw Exception(AppConstants.serverErrorMessage);
        } else {
          final errorMessage = e.response?.data['message'] ?? AppConstants.unknownErrorMessage;
          throw Exception(errorMessage);
        }

      case DioExceptionType.cancel:
        throw Exception('Request was cancelled.');

      case DioExceptionType.connectionError:
        throw Exception(AppConstants.networkErrorMessage);

      default:
        throw Exception(AppConstants.unknownErrorMessage);
    }
  }
}
