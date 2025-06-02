class AppConstants {
  // API Base URL
  // static const String baseUrl = 'http://10.0.2.2:3030/api'; // For Android emulator (10.0.2.2 points to host machine's localhost)
  static const String baseUrl = 'http://localhost:3030/api'; // For iOS simulator or web
  // static const String baseUrl = 'http://192.168.17.157:3030/api'; // For physical device - using computer's IP address

  // API Endpoints
  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';
  static const String userProfileEndpoint = '/users/profile';
  static const String updateProfileEndpoint = '/users/update_profile';
  static const String updatePasswordEndpoint = '/users/update_password';
  static const String coinBalanceEndpoint = '/users/coin_balance';
  static const String coinTransactionsEndpoint = '/users/coin_transactions';
  static const String transactionSyncEndpoint = '/transaction_sync.php';

  // No need to add duplicate keys

  static const String recyclingCategoriesEndpoint = '/recycling/categories';
  static const String submitRecyclingEndpoint = '/recycling/submit';
  static const String userRecyclingActivitiesEndpoint = '/recycling/user_activities';
  static const String recyclingActivityEndpoint = '/recycling/activity';
  static const String updatePickupStatusEndpoint = '/recycling/update_pickup_status';

  static const String productsEndpoint = '/products/all';
  static const String featuredProductsEndpoint = '/products/featured';
  static const String productsByCategoryEndpoint = '/products/by_category';
  static const String productEndpoint = '/products/product';
  static const String productCategoriesEndpoint = '/products/categories';

  static const String createOrderEndpoint = '/orders/create';
  static const String userOrdersEndpoint = '/orders/user_orders';
  static const String orderEndpoint = '/orders/order';

  // Shared Preferences Keys
  static const String tokenKey = 'token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';
  static const String emailKey = 'email';
  static const String fullNameKey = 'full_name';
  static const String coinBalanceKey = 'coin_balance';

  // App Settings
  static const String appName = 'Green Coins';
  static const String appVersion = '1.0.0';

  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred. Please try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String registerSuccessMessage = 'Registration successful! Please login.';
  static const String recyclingSubmitSuccessMessage = 'Recycling activity submitted successfully!';
  static const String orderSuccessMessage = 'Order placed successfully!';
  static const String profileUpdateSuccessMessage = 'Profile updated successfully!';
  static const String passwordUpdateSuccessMessage = 'Password updated successfully!';
}
