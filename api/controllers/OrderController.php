<?php
// Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database and models
include_once 'config/database.php';
include_once 'models/Order.php';
include_once 'models/Product.php';
include_once 'models/User.php';
include_once 'models/Coin.php';

class OrderController {
    // Database connection and order model
    private $database;
    private $db;
    private $order;

    // Constructor
    public function __construct() {
        // Get database connection
        $this->database = new Database();
        $this->db = $this->database->getConnection();

        // Initialize order model
        $this->order = new Order($this->db);
    }

    // Create a new order
    public function createOrder() {
        // Get posted data
        $data = json_decode(file_get_contents("php://input"));

        // Check if data is complete
        if(
            !empty($data->user_id) &&
            !empty($data->items) &&
            !empty($data->shipping_address) &&
            !empty($data->contact_phone)
        ) {
            // Set order property values
            $this->order->user_id = $data->user_id;
            $this->order->shipping_address = $data->shipping_address;
            $this->order->contact_phone = $data->contact_phone;
            $this->order->notes = !empty($data->notes) ? $data->notes : "";
            $this->order->status = "pending";

            // Check if user has enough coins
            $coin = new Coin($this->db);
            $coin->user_id = $data->user_id;
            $user_balance = $coin->getUserBalance();

            // Process order items
            $this->order->items = array();
            $total_coins = 0;

            foreach($data->items as $item) {
                // Check if product exists and is in stock
                $product = new Product($this->db);
                $product->id = $item->product_id;

                if(!$product->readOne()) {
                    // Set response code - 400 bad request
                    http_response_code(400);

                    // Tell the user
                    echo json_encode(array("message" => "Product with ID " . $item->product_id . " does not exist."));
                    return;
                }

                if(!$product->isInStock($item->quantity)) {
                    // Set response code - 400 bad request
                    http_response_code(400);

                    // Tell the user
                    echo json_encode(array("message" => "Product " . $product->name . " is out of stock or has insufficient quantity."));
                    return;
                }

                // Add item to order
                $order_item = array(
                    "product_id" => $item->product_id,
                    "quantity" => $item->quantity,
                    "coin_price" => $product->coin_price
                );

                array_push($this->order->items, $order_item);

                // Add to total coins
                $total_coins += $product->coin_price * $item->quantity;
            }

            // Check if user has enough coins
            if($user_balance < $total_coins) {
                // Set response code - 400 bad request
                http_response_code(400);

                // Tell the user
                echo json_encode(array(
                    "message" => "Insufficient coins. Required: " . $total_coins . ", Available: " . $user_balance
                ));
                return;
            }

            // Set total coin amount
            $this->order->total_coin_amount = $total_coins;

            // Create the order
            if($this->order->create()) {
                // Set response code - 201 created
                http_response_code(201);

                // Tell the user
                echo json_encode(array(
                    "message" => "Order was created.",
                    "id" => $this->order->id,
                    "total_coin_amount" => $this->order->total_coin_amount
                ));
            } else {
                // Set response code - 503 service unavailable
                http_response_code(503);

                // Tell the user
                echo json_encode(array("message" => "Unable to create order."));
            }
        } else {
            // Set response code - 400 bad request
            http_response_code(400);

            // Tell the user
            echo json_encode(array("message" => "Unable to create order. Data is incomplete."));
        }
    }

    // Get orders for a user
    public function getUserOrders() {
        // Get user ID from URL
        $user_id = isset($_GET['user_id']) ? $_GET['user_id'] : die();

        // Set user ID
        $this->order->user_id = $user_id;

        // Read orders
        $result = $this->order->readByUser();
        $num = mysqli_num_rows($result);

        // Check if any orders found
        if($num > 0) {
            // Orders array
            $orders_arr = array();
            $orders_arr["records"] = array();

            // Retrieve table contents
            while($row = mysqli_fetch_assoc($result)) {
                // Extract row
                extract($row);

                $order_item = array(
                    "id" => $id,
                    "user_id" => $user_id,
                    "total_coin_amount" => $total_coin_amount,
                    "status" => $status,
                    "shipping_address" => $shipping_address,
                    "contact_phone" => $contact_phone,
                    "notes" => $notes,
                    "created_at" => $created_at,
                    "updated_at" => $updated_at
                );

                array_push($orders_arr["records"], $order_item);
            }

            // Set response code - 200 OK
            http_response_code(200);

            // Show orders data
            echo json_encode($orders_arr);
        } else {
            // Set response code - 404 Not found
            http_response_code(404);

            // Tell the user no orders found
            echo json_encode(array("message" => "No orders found."));
        }
    }

    // Get a single order with its items
    public function getOrder() {
        // Get order ID from URL
        $id = isset($_GET['id']) ? $_GET['id'] : die();

        // Set order ID
        $this->order->id = $id;

        // Read order details
        if($this->order->readOne()) {
            // Create array
            $order_arr = array(
                "id" => $this->order->id,
                "user_id" => $this->order->user_id,
                "total_coin_amount" => $this->order->total_coin_amount,
                "status" => $this->order->status,
                "shipping_address" => $this->order->shipping_address,
                "contact_phone" => $this->order->contact_phone,
                "notes" => $this->order->notes,
                "created_at" => $this->order->created_at,
                "updated_at" => $this->order->updated_at,
                "items" => $this->order->items
            );

            // Set response code - 200 OK
            http_response_code(200);

            // Make it json format
            echo json_encode($order_arr);
        } else {
            // Set response code - 404 Not found
            http_response_code(404);

            // Tell the user
            echo json_encode(array("message" => "Order does not exist."));
        }
    }

    // Update order status
    public function updateStatus() {
        // Get posted data
        $data = json_decode(file_get_contents("php://input"));

        // Check if data is complete
        if(
            !empty($data->id) &&
            !empty($data->status)
        ) {
            // Set order property values
            $this->order->id = $data->id;
            $this->order->status = $data->status;
            $this->order->notes = !empty($data->notes) ? $data->notes : "";

            // Update the order status
            if($this->order->updateStatus()) {
                // Set response code - 200 OK
                http_response_code(200);

                // Tell the user
                echo json_encode(array("message" => "Order status was updated."));
            } else {
                // Set response code - 503 service unavailable
                http_response_code(503);

                // Tell the user
                echo json_encode(array("message" => "Unable to update order status."));
            }
        } else {
            // Set response code - 400 bad request
            http_response_code(400);

            // Tell the user
            echo json_encode(array("message" => "Unable to update order status. Data is incomplete."));
        }
    }
}

// Process the request
$controller = new OrderController();

// Get the request method
$request_method = $_SERVER["REQUEST_METHOD"];

// Route the request to the appropriate method
if($request_method == "POST") {
    // Check the endpoint
    $endpoint = basename($_SERVER['REQUEST_URI']);

    if($endpoint == "create") {
        $controller->createOrder();
    } else if($endpoint == "update_status") {
        $controller->updateStatus();
    } else {
        // Set response code - 404 Not found
        http_response_code(404);

        // Tell the user
        echo json_encode(array("message" => "Endpoint not found."));
    }
} else if($request_method == "GET") {
    // Check the endpoint
    $endpoint = basename(strtok($_SERVER["REQUEST_URI"], '?'));

    if($endpoint == "user_orders") {
        $controller->getUserOrders();
    } else if($endpoint == "order") {
        $controller->getOrder();
    } else {
        // Set response code - 404 Not found
        http_response_code(404);

        // Tell the user
        echo json_encode(array("message" => "Endpoint not found."));
    }
} else {
    // Set response code - 405 Method not allowed
    http_response_code(405);

    // Tell the user
    echo json_encode(array("message" => "Method not allowed."));
}
?>
