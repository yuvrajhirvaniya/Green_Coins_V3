import 'package:flutter/material.dart';
import 'package:green_coins_app/features/recycling/data/recycling_repository.dart';
import 'package:green_coins_app/features/recycling/domain/models/recycling_activity_model.dart';
import 'package:green_coins_app/features/recycling/domain/models/recycling_category_model.dart';

enum RecyclingStatus {
  initial,
  loading,
  success,
  error,
}

class RecyclingProvider extends ChangeNotifier {
  final RecyclingRepository _recyclingRepository;

  RecyclingStatus _status = RecyclingStatus.initial;
  List<RecyclingCategoryModel> _categories = [];
  List<RecyclingActivityModel> _activities = [];
  RecyclingActivityModel? _selectedActivity;
  String _errorMessage = '';

  RecyclingProvider({required RecyclingRepository recyclingRepository})
      : _recyclingRepository = recyclingRepository;

  // Getters
  RecyclingStatus get status => _status;
  List<RecyclingCategoryModel> get categories => _categories;
  List<RecyclingActivityModel> get activities => _activities;
  RecyclingActivityModel? get selectedActivity => _selectedActivity;
  String get errorMessage => _errorMessage;

  // Get all recycling categories
  Future<void> getCategories() async {
    _status = RecyclingStatus.loading;
    notifyListeners();

    try {
      final categories = await _recyclingRepository.getCategories();
      print('Recycling categories loaded: ${categories.length}');
      if (categories.isNotEmpty) {
        print('First category: ${categories[0].name}, ID: ${categories[0].id}, Coin Value: ${categories[0].coinValue}');
      }
      _categories = categories;
      _status = RecyclingStatus.success;
    } catch (e) {
      print('Error loading recycling categories: $e');
      _status = RecyclingStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
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
    _status = RecyclingStatus.loading;
    notifyListeners();

    try {
      final result = await _recyclingRepository.submitActivity(
        userId: userId,
        categoryId: categoryId,
        quantity: quantity,
        proofImage: proofImage,
        notes: notes,
        pickupDate: pickupDate,
        pickupTimeSlot: pickupTimeSlot,
        pickupAddress: pickupAddress,
      );

      _status = RecyclingStatus.success;
      notifyListeners();

      return result;
    } catch (e) {
      _status = RecyclingStatus.error;
      _errorMessage = e.toString();
      notifyListeners();

      return {'error': e.toString()};
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
    _status = RecyclingStatus.loading;
    notifyListeners();

    try {
      final result = await _recyclingRepository.updatePickupStatus(
        activityId: activityId,
        pickupStatus: pickupStatus,
        pickupDate: pickupDate,
        pickupTimeSlot: pickupTimeSlot,
        pickupAddress: pickupAddress,
      );

      _status = RecyclingStatus.success;
      notifyListeners();

      return result;
    } catch (e) {
      _status = RecyclingStatus.error;
      _errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // Get user recycling activities
  Future<void> getUserActivities(int userId) async {
    _status = RecyclingStatus.loading;
    notifyListeners();

    try {
      print('RecyclingProvider: Getting user activities for user ID: $userId');
      final activities = await _recyclingRepository.getUserActivities(userId);
      print('RecyclingProvider: Received ${activities.length} activities');

      _activities = activities;
      _status = RecyclingStatus.success;
      print('RecyclingProvider: Status set to success');
    } catch (e) {
      print('RecyclingProvider: Error getting user activities: $e');
      // Just set empty activities and success status instead of error
      // This prevents the UI from showing an error when there are no activities
      _activities = [];
      _status = RecyclingStatus.success;

      // Store the error message but don't show it to the user
      _errorMessage = e.toString();
    }

    print('RecyclingProvider: Notifying listeners with status: $_status and ${_activities.length} activities');
    notifyListeners();
  }

  // Get recycling activity details
  Future<void> getActivity(int activityId) async {
    _status = RecyclingStatus.loading;
    notifyListeners();

    try {
      final activity = await _recyclingRepository.getActivity(activityId);
      _selectedActivity = activity;
      _status = RecyclingStatus.success;
    } catch (e) {
      _status = RecyclingStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Reset selected activity
  void resetSelectedActivity() {
    _selectedActivity = null;
    notifyListeners();
  }

  // Reset error
  void resetError() {
    _errorMessage = '';
    notifyListeners();
  }
}
