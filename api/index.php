<?php
// Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get request URI
$request_uri = $_SERVER['REQUEST_URI'];

// Remove query string from URI
$request_uri = strtok($request_uri, '?');

// Extract the endpoint from the URI
$uri_parts = explode('/', trim($request_uri, '/'));

// Find the API part in the URI
$api_index = array_search('api', $uri_parts);

// If API part is found, get the controller and endpoint
if ($api_index !== false && isset($uri_parts[$api_index + 1])) {
    $controller = $uri_parts[$api_index + 1];
    $endpoint = isset($uri_parts[$api_index + 2]) ? $uri_parts[$api_index + 2] : '';

    // Route to the appropriate controller
    switch ($controller) {
        case 'users':
            include_once 'controllers/UserController.php';
            break;

        case 'recycling':
            include_once 'controllers/RecyclingController.php';
            break;

        case 'products':
            include_once 'controllers/ProductController.php';
            break;

        case 'orders':
            include_once 'controllers/OrderController.php';
            break;

        default:
            // Set response code - 404 Not found
            http_response_code(404);

            // Tell the user
            echo json_encode(array("message" => "Controller not found."));
            break;
    }
} else {
    // API documentation
    echo json_encode(array(
        "message" => "Welcome to Green Coins API",
        "version" => "1.0.0",
        "endpoints" => array(
            "users" => array(
                "register" => "POST /api/users/register",
                "login" => "POST /api/users/login",
                "profile" => "GET /api/users/profile?id={user_id}",
                "update_profile" => "POST /api/users/update_profile",
                "update_password" => "POST /api/users/update_password",
                "coin_balance" => "GET /api/users/coin_balance?id={user_id}",
                "coin_transactions" => "GET /api/users/coin_transactions?id={user_id}"
            ),
            "recycling" => array(
                "submit" => "POST /api/recycling/submit",
                "user_activities" => "GET /api/recycling/user_activities?user_id={user_id}",
                "activity" => "GET /api/recycling/activity?id={activity_id}",
                "update_status" => "POST /api/recycling/update_status",
                "update_pickup_status" => "POST /api/recycling/update_pickup_status",
                "categories" => "GET /api/recycling/categories"
            ),
            "products" => array(
                "all" => "GET /api/products/all",
                "featured" => "GET /api/products/featured",
                "by_category" => "GET /api/products/by_category?category_id={category_id}",
                "product" => "GET /api/products/product?id={product_id}",
                "categories" => "GET /api/products/categories"
            ),
            "orders" => array(
                "create" => "POST /api/orders/create",
                "user_orders" => "GET /api/orders/user_orders?user_id={user_id}",
                "order" => "GET /api/orders/order?id={order_id}",
                "update_status" => "POST /api/orders/update_status"
            )
        )
    ));
}
?>
