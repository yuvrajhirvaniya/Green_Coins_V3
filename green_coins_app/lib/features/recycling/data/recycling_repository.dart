import 'package:green_coins_app/core/constants/app_constants.dart';
import 'package:green_coins_app/core/network/api_service.dart';
import 'package:green_coins_app/features/recycling/domain/models/recycling_activity_model.dart';
import 'package:green_coins_app/features/recycling/domain/models/recycling_category_model.dart';

class RecyclingRepository {
  final ApiService _apiService;

  RecyclingRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Get all recycling categories
  Future<List<RecyclingCategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get(AppConstants.recyclingCategoriesEndpoint);
      print('API Response for categories: $response');

      final List<RecyclingCategoryModel> categories = [];

      if (response != null && response['records'] != null) {
        print('Records found: ${response['records'].length}');
        for (var category in response['records']) {
          print('Processing category: $category');
          try {
            final categoryModel = RecyclingCategoryModel.fromJson(category);
            categories.add(categoryModel);
          } catch (parseError) {
            print('Error parsing category: $parseError');
          }
        }
      } else {
        print('No records found in response');
      }

      return categories;
    } catch (e) {
      print('Error in getCategories: $e');
      // Return empty list instead of throwing exception
      return [];
    }
  }

  // Submit recycling activity
  Future<Map<String, dynamic>> submitActivity({
    required int userId,
    required int categoryId,
    required double quantity,
    String? proofImage,
    String? notes,
    String? pickupDate,
    String? pickupTimeSlot,
    String? pickupAddress,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'category_id': categoryId,
        'quantity': quantity,
        'proof_image': proofImage,
        'notes': notes,
      };

      // Add pickup information if provided
      if (pickupDate != null) {
        data['pickup_date'] = pickupDate;
        data['pickup_time_slot'] = pickupTimeSlot;
        data['pickup_address'] = pickupAddress;
      }

      final response = await _apiService.post(AppConstants.submitRecyclingEndpoint, data: data);

      return {
        'id': response['id'],
        'coins_earned': response['coins_earned'],
      };
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Update pickup status
  Future<bool> updatePickupStatus({
    required int activityId,
    required String pickupStatus,
    String? pickupDate,
    String? pickupTimeSlot,
    String? pickupAddress,
  }) async {
    try {
      final data = {
        'id': activityId,
        'pickup_status': pickupStatus,
      };

      // Add optional fields if provided
      if (pickupDate != null) {
        data['pickup_date'] = pickupDate;
      }

      if (pickupTimeSlot != null) {
        data['pickup_time_slot'] = pickupTimeSlot;
      }

      if (pickupAddress != null) {
        data['pickup_address'] = pickupAddress;
      }

      await _apiService.post(AppConstants.updatePickupStatusEndpoint, data: data);

      return true;
    } catch (e) {
      print('Error in updatePickupStatus: $e');
      return false;
    }
  }

  // Get user recycling activities
  Future<List<RecyclingActivityModel>> getUserActivities(int userId) async {
    try {
      print('Fetching user activities for user ID: $userId');
      final response = await _apiService.get(
        AppConstants.userRecyclingActivitiesEndpoint,
        queryParameters: {'user_id': userId},
      );

      print('User activities API response: $response');
      final List<RecyclingActivityModel> activities = [];

      // Handle different response formats
      if (response != null) {
        if (response is Map && response.containsKey('records')) {
          // Standard format with 'records' key
          print('Standard response format with records key');
          if (response['records'] != null) {
            print('Records found: ${response['records'].length}');
            for (var activity in response['records']) {
              try {
                print('Processing activity: $activity');
                final activityModel = RecyclingActivityModel.fromJson(activity);
                activities.add(activityModel);
              } catch (parseError) {
                print('Error parsing activity: $parseError');
              }
            }
          }
        } else if (response is List) {
          // Direct list format
          print('Response is a direct list of activities');
          for (var activity in response) {
            try {
              print('Processing activity from list: $activity');
              final activityModel = RecyclingActivityModel.fromJson(activity);
              activities.add(activityModel);
            } catch (parseError) {
              print('Error parsing activity from list: $parseError');
            }
          }
        } else {
          print('Unexpected response format: ${response.runtimeType}');
        }
      } else {
        print('Response is null');
      }

      print('Returning ${activities.length} activities');
      return activities;
    } catch (e) {
      // Check if the error is a 404 (no activities found)
      if (e.toString().contains('404') || e.toString().contains('Resource not found')) {
        // This is expected for new users with no activities
        print('No activities found (404): $e');
        return [];
      } else {
        // For other errors, still return empty list but log the error
        print('Error fetching user activities: $e');
        return [];
      }
    }
  }

  // Get recycling activity details
  Future<RecyclingActivityModel> getActivity(int activityId) async {
    try {
      final response = await _apiService.get(
        AppConstants.recyclingActivityEndpoint,
        queryParameters: {'id': activityId},
      );

      return RecyclingActivityModel.fromJson(response);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
