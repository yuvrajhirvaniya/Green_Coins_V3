<?php
// Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database and models
include_once 'config/database.php';
include_once 'models/User.php';
include_once 'models/Coin.php';

class UserController {
    // Database connection and user model
    private $database;
    private $db;
    private $user;

    // Constructor
    public function __construct() {
        // Get database connection
        $this->database = new Database();
        $this->db = $this->database->getConnection();

        // Initialize user model
        $this->user = new User($this->db);
    }

    // Register a new user
    public function register() {
        // Get posted data
        $data = json_decode(file_get_contents("php://input"));

        // Check if data is complete
        if(
            !empty($data->username) &&
            !empty($data->email) &&
            !empty($data->password) &&
            !empty($data->full_name)
        ) {
            // Set user property values
            $this->user->username = $data->username;
            $this->user->email = $data->email;
            $this->user->password = $data->password;
            $this->user->full_name = $data->full_name;
            $this->user->phone = !empty($data->phone) ? $data->phone : "";
            $this->user->address = !empty($data->address) ? $data->address : "";
            $this->user->profile_image = !empty($data->profile_image) ? $data->profile_image : "";

            // Check if username already exists
            if($this->user->usernameExists()) {
                // Set response code - 400 bad request
                http_response_code(400);

                // Tell the user
                echo json_encode(array("message" => "Username already exists."));
                return;
            }

            // Check if email already exists
            if($this->user->emailExists()) {
                // Set response code - 400 bad request
                http_response_code(400);

                // Tell the user
                echo json_encode(array("message" => "Email already exists."));
                return;
            }

            // Create the user
            if($this->user->create()) {
                // Set response code - 201 created
                http_response_code(201);

                // Tell the user
                echo json_encode(array("message" => "User was created."));
            } else {
                // Set response code - 503 service unavailable
                http_response_code(503);

                // Tell the user
                echo json_encode(array("message" => "Unable to create user."));
            }
        } else {
            // Set response code - 400 bad request
            http_response_code(400);

            // Tell the user
            echo json_encode(array("message" => "Unable to create user. Data is incomplete."));
        }
    }

    // Login a user
    public function login() {
        // Get posted data
        $data = json_decode(file_get_contents("php://input"));

        // Check if data is complete
        if(
            !empty($data->username) &&
            !empty($data->password)
        ) {
            // Set user property values
            $this->user->username = $data->username;
            $this->user->password = $data->password;

            // Login the user
            if($this->user->login()) {
                // Generate JWT token (simplified for now)
                $token = bin2hex(random_bytes(16));

                // Set response code - 200 OK
                http_response_code(200);

                // Tell the user
                echo json_encode(array(
                    "message" => "Login successful.",
                    "token" => $token,
                    "user" => array(
                        "id" => $this->user->id,
                        "username" => $this->user->username,
                        "email" => $this->user->email,
                        "full_name" => $this->user->full_name,
                        "coin_balance" => $this->user->coin_balance
                    )
                ));
            } else {
                // Set response code - 401 unauthorized
                http_response_code(401);

                // Tell the user
                echo json_encode(array("message" => "Invalid username or password."));
            }
        } else {
            // Set response code - 400 bad request
            http_response_code(400);

            // Tell the user
            echo json_encode(array("message" => "Unable to login. Data is incomplete."));
        }
    }

    // Get user profile
    public function getProfile() {
        // Get user ID from URL
        $user_id = isset($_GET['id']) ? $_GET['id'] : die();

        // Set user ID
        $this->user->id = $user_id;

        // Read user details
        if($this->user->readOne()) {
            // Create array
            $user_arr = array(
                "id" => $this->user->id,
                "username" => $this->user->username,
                "email" => $this->user->email,
                "full_name" => $this->user->full_name,
                "phone" => $this->user->phone,
                "address" => $this->user->address,
                "profile_image" => $this->user->profile_image,
                "coin_balance" => $this->user->coin_balance,
                "created_at" => $this->user->created_at
            );

            // Set response code - 200 OK
            http_response_code(200);

            // Make it json format
            echo json_encode($user_arr);
        } else {
            // Set response code - 404 Not found
            http_response_code(404);

            // Tell the user
            echo json_encode(array("message" => "User does not exist."));
        }
    }

    // Update user profile
    public function updateProfile() {
        // Get posted data
        $data = json_decode(file_get_contents("php://input"));

        // Check if data is complete
        if(
            !empty($data->id) &&
            !empty($data->username) &&
            !empty($data->email) &&
            !empty($data->full_name)
        ) {
            // Set user property values
            $this->user->id = $data->id;
            $this->user->username = $data->username;
            $this->user->email = $data->email;
            $this->user->full_name = $data->full_name;
            $this->user->phone = !empty($data->phone) ? $data->phone : "";
            $this->user->address = !empty($data->address) ? $data->address : "";
            $this->user->profile_image = !empty($data->profile_image) ? $data->profile_image : "";

            // Update the user
            if($this->user->update()) {
                // Set response code - 200 OK
                http_response_code(200);

                // Tell the user
                echo json_encode(array("message" => "User was updated."));
            } else {
                // Set response code - 503 service unavailable
                http_response_code(503);

                // Tell the user
                echo json_encode(array("message" => "Unable to update user."));
            }
        } else {
            // Set response code - 400 bad request
            http_response_code(400);

            // Tell the user
            echo json_encode(array("message" => "Unable to update user. Data is incomplete."));
        }
    }

    // Update user password
    public function updatePassword() {
        // Get posted data
        $data = json_decode(file_get_contents("php://input"));

        // Check if data is complete
        if(
            !empty($data->id) &&
            !empty($data->password)
        ) {
            // Set user property values
            $this->user->id = $data->id;
            $this->user->password = $data->password;

            // Update the password
            if($this->user->updatePassword()) {
                // Set response code - 200 OK
                http_response_code(200);

                // Tell the user
                echo json_encode(array("message" => "Password was updated."));
            } else {
                // Set response code - 503 service unavailable
                http_response_code(503);

                // Tell the user
                echo json_encode(array("message" => "Unable to update password."));
            }
        } else {
            // Set response code - 400 bad request
            http_response_code(400);

            // Tell the user
            echo json_encode(array("message" => "Unable to update password. Data is incomplete."));
        }
    }

    // Get user coin balance
    public function getCoinBalance() {
        // Get user ID from URL
        $user_id = isset($_GET['id']) ? $_GET['id'] : die();

        // First, check for and fix any missing transactions for this user
        $this->syncUserTransactions($user_id);

        // Create coin object
        $coin = new Coin($this->db);
        $coin->user_id = $user_id;

        // Get user's coin balance
        $balance = $coin->getUserBalance();

        // Set response code - 200 OK
        http_response_code(200);

        // Make it json format
        echo json_encode(array("coin_balance" => $balance));
    }

    // Sync missing transactions for a user
    private function syncUserTransactions($user_id) {
        // Find all approved activities without corresponding transactions for this user
        $query = "SELECT ra.id, ra.user_id, ra.coins_earned, ra.status, ra.created_at
                  FROM recycling_activities ra
                  WHERE ra.user_id = '$user_id'
                  AND ra.status = 'approved'
                  AND NOT EXISTS (
                      SELECT 1 FROM coin_transactions ct
                      WHERE ct.reference_id = ra.id
                      AND ct.reference_type = 'recycling'
                  )";

        $result = mysqli_query($this->db, $query);

        if (!$result) {
            // Log error but continue
            error_log("Database error checking for missing transactions for user $user_id");
            return;
        }

        $num = mysqli_num_rows($result);

        if ($num > 0) {
            // Process each missing transaction
            while ($row = mysqli_fetch_assoc($result)) {
                $this->createMissingTransaction($row['id'], $row['user_id'], $row['coins_earned']);
            }
        }
    }

    // Create a missing transaction
    private function createMissingTransaction($activity_id, $user_id, $coins_earned) {
        // Start transaction
        mysqli_begin_transaction($this->db);

        try {
            // Create coin transaction
            $coin = new Coin($this->db);
            $coin->user_id = $user_id;
            $coin->amount = $coins_earned;
            $coin->transaction_type = "earned";
            $coin->reference_id = $activity_id;
            $coin->reference_type = "recycling";
            $coin->description = "Coins earned from recycling activity (auto-sync)";

            if (!$coin->create()) {
                mysqli_rollback($this->db);
                error_log("Failed to create coin transaction for activity ID: $activity_id");
                return false;
            }

            // Update user's coin balance
            $query = "UPDATE users
                    SET coin_balance = coin_balance + '$coins_earned'
                    WHERE id = '$user_id'";

            if (!mysqli_query($this->db, $query)) {
                mysqli_rollback($this->db);
                error_log("Failed to update user balance for activity ID: $activity_id");
                return false;
            }

            // Commit transaction
            mysqli_commit($this->db);

            return true;
        } catch (Exception $e) {
            mysqli_rollback($this->db);
            error_log("Transaction failed for activity ID: $activity_id - " . $e->getMessage());
            return false;
        }
    }

    // Get user coin transactions
    public function getCoinTransactions() {
        // Get user ID from URL
        $user_id = isset($_GET['id']) ? $_GET['id'] : die();

        // First, check for and fix any missing transactions for this user
        $this->syncUserTransactions($user_id);

        // Create coin object
        $coin = new Coin($this->db);
        $coin->user_id = $user_id;

        // Read coin transactions
        $result = $coin->readByUser();
        $num = mysqli_num_rows($result);

        // Check if any transactions found
        if($num > 0) {
            // Transactions array
            $transactions_arr = array();
            $transactions_arr["records"] = array();

            // Retrieve table contents
            while($row = mysqli_fetch_assoc($result)) {
                // Extract row
                extract($row);

                $transaction_item = array(
                    "id" => $id,
                    "user_id" => $user_id,
                    "amount" => $amount,
                    "transaction_type" => $transaction_type,
                    "reference_id" => $reference_id,
                    "reference_type" => $reference_type,
                    "description" => $description,
                    "created_at" => $created_at
                );

                array_push($transactions_arr["records"], $transaction_item);
            }

            // Set response code - 200 OK
            http_response_code(200);

            // Show transactions data
            echo json_encode($transactions_arr);
        } else {
            // Set response code - 404 Not found
            http_response_code(404);

            // Tell the user no transactions found
            echo json_encode(array("message" => "No transactions found."));
        }
    }
}

// Process the request
$controller = new UserController();

// Get the request method
$request_method = $_SERVER["REQUEST_METHOD"];

// Route the request to the appropriate method
if($request_method == "POST") {
    // Check the endpoint
    $endpoint = basename($_SERVER['REQUEST_URI']);

    if($endpoint == "register") {
        $controller->register();
    } else if($endpoint == "login") {
        $controller->login();
    } else if($endpoint == "update_profile") {
        $controller->updateProfile();
    } else if($endpoint == "update_password") {
        $controller->updatePassword();
    } else {
        // Set response code - 404 Not found
        http_response_code(404);

        // Tell the user
        echo json_encode(array("message" => "Endpoint not found."));
    }
} else if($request_method == "GET") {
    // Check the endpoint
    $endpoint = basename(strtok($_SERVER["REQUEST_URI"], '?'));

    if($endpoint == "profile") {
        $controller->getProfile();
    } else if($endpoint == "coin_balance") {
        $controller->getCoinBalance();
    } else if($endpoint == "coin_transactions") {
        $controller->getCoinTransactions();
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
