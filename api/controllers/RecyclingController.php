<?php
// Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database and models
include_once 'config/database.php';
include_once 'models/RecyclingActivity.php';
include_once 'models/User.php';
include_once 'models/Coin.php';

class RecyclingController {
    // Database connection and recycling model
    private $database;
    private $db;
    private $recycling;

    // Constructor
    public function __construct() {
        // Get database connection
        $this->database = new Database();
        $this->db = $this->database->getConnection();

        // Initialize recycling model
        $this->recycling = new RecyclingActivity($this->db);
    }

    // Submit a new recycling activity
    public function submitActivity() {
        // Get posted data
        $data = json_decode(file_get_contents("php://input"));

        // Check if data is complete
        if(
            !empty($data->user_id) &&
            !empty($data->category_id) &&
            !empty($data->quantity)
        ) {
            // Set recycling property values
            $this->recycling->user_id = $data->user_id;
            $this->recycling->category_id = $data->category_id;
            $this->recycling->quantity = $data->quantity;
            $this->recycling->status = "pending";
            $this->recycling->proof_image = !empty($data->proof_image) ? $data->proof_image : "";
            $this->recycling->notes = !empty($data->notes) ? $data->notes : "";

            // Set pickup scheduling values if provided
            if(!empty($data->pickup_date)) {
                $this->recycling->pickup_date = $data->pickup_date;
                $this->recycling->pickup_time_slot = !empty($data->pickup_time_slot) ? $data->pickup_time_slot : "";
                $this->recycling->pickup_address = !empty($data->pickup_address) ? $data->pickup_address : "";
                $this->recycling->pickup_status = "scheduled";
            } else {
                $this->recycling->pickup_status = "not_required";
            }

            // Calculate coins earned
            if(!$this->recycling->calculateCoins()) {
                // Set response code - 400 bad request
                http_response_code(400);

                // Tell the user
                echo json_encode(array("message" => "Invalid category."));
                return;
            }

            // Create the recycling activity
            if($this->recycling->create()) {
                // Set response code - 201 created
                http_response_code(201);

                // Tell the user
                echo json_encode(array(
                    "message" => "Recycling activity was submitted.",
                    "id" => $this->recycling->id,
                    "coins_earned" => $this->recycling->coins_earned
                ));
            } else {
                // Set response code - 503 service unavailable
                http_response_code(503);

                // Tell the user
                echo json_encode(array("message" => "Unable to submit recycling activity."));
            }
        } else {
            // Set response code - 400 bad request
            http_response_code(400);

            // Tell the user
            echo json_encode(array("message" => "Unable to submit recycling activity. Data is incomplete."));
        }
    }

    // Get recycling activities for a user
    public function getUserActivities() {
        // Get user ID from URL
        $user_id = isset($_GET['user_id']) ? $_GET['user_id'] : die();

        // First, check for and fix any missing transactions for this user
        $this->syncUserTransactions($user_id);

        // Set user ID
        $this->recycling->user_id = $user_id;

        // Read recycling activities
        $result = $this->recycling->readByUser();

        // Check if query was successful
        if($result === false) {
            // Set response code - 500 Internal Server Error
            http_response_code(500);

            // Tell the user
            echo json_encode(array("message" => "Database error. Unable to fetch recycling activities."));
            return;
        }

        $num = mysqli_num_rows($result);

        // Activities array
        $activities_arr = array();
        $activities_arr["records"] = array();

        // Check if any activities found
        if($num > 0) {
            // Retrieve table contents
            while($row = mysqli_fetch_assoc($result)) {
                // Extract row
                extract($row);

                $activity_item = array(
                    "id" => $id,
                    "user_id" => $user_id,
                    "category_id" => $category_id,
                    "category_name" => $category_name,
                    "quantity" => $quantity,
                    "coins_earned" => $coins_earned,
                    "status" => $status,
                    "proof_image" => $proof_image,
                    "notes" => $notes,
                    "pickup_date" => $row['pickup_date'] ?? null,
                    "pickup_time_slot" => $row['pickup_time_slot'] ?? null,
                    "pickup_address" => $row['pickup_address'] ?? null,
                    "pickup_status" => $row['pickup_status'] ?? 'not_required',
                    "created_at" => $created_at,
                    "updated_at" => $updated_at
                );

                array_push($activities_arr["records"], $activity_item);
            }
        }
        // Always return 200 OK with the activities array (which may be empty)
        http_response_code(200);

        // Show activities data (empty or not)
        echo json_encode($activities_arr);
    }

    // Get a single recycling activity
    public function getActivity() {
        // Get activity ID from URL
        $id = isset($_GET['id']) ? $_GET['id'] : die();

        // Set activity ID
        $this->recycling->id = $id;

        // Read activity details
        if($this->recycling->readOne()) {
            // Create array
            $activity_arr = array(
                "id" => $this->recycling->id,
                "user_id" => $this->recycling->user_id,
                "category_id" => $this->recycling->category_id,
                "quantity" => $this->recycling->quantity,
                "coins_earned" => $this->recycling->coins_earned,
                "status" => $this->recycling->status,
                "proof_image" => $this->recycling->proof_image,
                "notes" => $this->recycling->notes,
                "pickup_date" => $this->recycling->pickup_date,
                "pickup_time_slot" => $this->recycling->pickup_time_slot,
                "pickup_address" => $this->recycling->pickup_address,
                "pickup_status" => $this->recycling->pickup_status,
                "created_at" => $this->recycling->created_at,
                "updated_at" => $this->recycling->updated_at
            );

            // Set response code - 200 OK
            http_response_code(200);

            // Make it json format
            echo json_encode($activity_arr);
        } else {
            // Set response code - 404 Not found
            http_response_code(404);

            // Tell the user
            echo json_encode(array("message" => "Recycling activity does not exist."));
        }
    }

    // Update recycling activity status
    public function updateStatus() {
        // Get posted data
        $data = json_decode(file_get_contents("php://input"));

        // Check if data is complete
        if(
            !empty($data->id) &&
            !empty($data->status)
        ) {
            // Set recycling property values
            $this->recycling->id = $data->id;

            // Read the current activity
            if(!$this->recycling->readOne()) {
                // Set response code - 404 Not found
                http_response_code(404);

                // Tell the user
                echo json_encode(array("message" => "Recycling activity does not exist."));
                return;
            }

            // Check if status is already approved
            if($this->recycling->status == "approved" && $data->status == "approved") {
                // Set response code - 400 bad request
                http_response_code(400);

                // Tell the user
                echo json_encode(array("message" => "Recycling activity is already approved."));
                return;
            }

            // Set new status and notes
            $this->recycling->status = $data->status;
            $this->recycling->notes = !empty($data->notes) ? $data->notes : $this->recycling->notes;

            // Start transaction
            mysqli_begin_transaction($this->db);

            try {
                // Update the status
                if(!$this->recycling->updateStatus()) {
                    mysqli_rollback($this->db);

                    // Set response code - 503 service unavailable
                    http_response_code(503);

                    // Tell the user
                    echo json_encode(array("message" => "Unable to update recycling activity status."));
                    return;
                }

                // If status is approved, add coins to user
                if($data->status == "approved" && $this->recycling->status != "approved") {
                    // Create coin transaction
                    $coin = new Coin($this->db);
                    $coin->user_id = $this->recycling->user_id;
                    $coin->amount = $this->recycling->coins_earned;
                    $coin->transaction_type = "earned";
                    $coin->reference_id = $this->recycling->id;
                    $coin->reference_type = "recycling";
                    $coin->description = "Coins earned from recycling activity";

                    if(!$coin->addCoins()) {
                        mysqli_rollback($this->db);

                        // Set response code - 503 service unavailable
                        http_response_code(503);

                        // Tell the user
                        echo json_encode(array("message" => "Unable to add coins to user."));
                        return;
                    }
                }

                // Commit transaction
                mysqli_commit($this->db);

                // Set response code - 200 OK
                http_response_code(200);

                // Tell the user
                echo json_encode(array("message" => "Recycling activity status was updated."));
            } catch(Exception $e) {
                mysqli_rollback($this->db);

                // Set response code - 503 service unavailable
                http_response_code(503);

                // Tell the user
                echo json_encode(array("message" => "Unable to update recycling activity status."));
            }
        } else {
            // Set response code - 400 bad request
            http_response_code(400);

            // Tell the user
            echo json_encode(array("message" => "Unable to update recycling activity status. Data is incomplete."));
        }
    }

    // Get all recycling categories
    public function getCategories() {
        // Read categories
        $result = $this->recycling->getCategories();

        // Check if query was successful
        if($result === false) {
            // Set response code - 500 Internal Server Error
            http_response_code(500);

            // Tell the user
            echo json_encode(array("message" => "Database error. Unable to fetch recycling categories."));
            return;
        }

        $num = mysqli_num_rows($result);

        // Check if any categories found
        if($num > 0) {
            // Categories array
            $categories_arr = array();
            $categories_arr["records"] = array();

            // Retrieve table contents
            while($row = mysqli_fetch_assoc($result)) {
                // Extract row
                extract($row);

                $category_item = array(
                    "id" => $id,
                    "name" => $name,
                    "description" => $description,
                    "coin_value" => $coin_value,
                    "image" => $image,
                    "created_at" => $created_at
                );

                array_push($categories_arr["records"], $category_item);
            }

            // Set response code - 200 OK
            http_response_code(200);

            // Show categories data
            echo json_encode($categories_arr);
        } else {
            // Create default categories if none exist
            $this->createDefaultCategories();

            // Try to fetch categories again
            $result = $this->recycling->getCategories();
            $num = mysqli_num_rows($result);

            if($num > 0) {
                // Categories array
                $categories_arr = array();
                $categories_arr["records"] = array();

                // Retrieve table contents
                while($row = mysqli_fetch_assoc($result)) {
                    // Extract row
                    extract($row);

                    $category_item = array(
                        "id" => $id,
                        "name" => $name,
                        "description" => $description,
                        "coin_value" => $coin_value,
                        "image" => $image,
                        "created_at" => $created_at
                    );

                    array_push($categories_arr["records"], $category_item);
                }

                // Set response code - 200 OK
                http_response_code(200);

                // Show categories data
                echo json_encode($categories_arr);
            } else {
                // Set response code - 404 Not found
                http_response_code(404);

                // Tell the user no categories found
                echo json_encode(array("message" => "No recycling categories found."));
            }
        }
    }

    // Update pickup status
    public function updatePickupStatus() {
        // Get posted data
        $data = json_decode(file_get_contents("php://input"));

        // Check if data is complete
        if(
            !empty($data->id) &&
            !empty($data->pickup_status)
        ) {
            // Set recycling property values
            $this->recycling->id = $data->id;

            // Read the current activity
            if(!$this->recycling->readOne()) {
                // Set response code - 404 Not found
                http_response_code(404);

                // Tell the user
                echo json_encode(array("message" => "Recycling activity does not exist."));
                return;
            }

            // Set new pickup status
            $this->recycling->pickup_status = $data->pickup_status;

            // Update pickup date and time slot if provided
            if(!empty($data->pickup_date)) {
                $this->recycling->pickup_date = $data->pickup_date;
            }

            if(!empty($data->pickup_time_slot)) {
                $this->recycling->pickup_time_slot = $data->pickup_time_slot;
            }

            if(!empty($data->pickup_address)) {
                $this->recycling->pickup_address = $data->pickup_address;
            }

            // Update the pickup status
            if($this->recycling->updatePickupStatus()) {
                // Set response code - 200 OK
                http_response_code(200);

                // Tell the user
                echo json_encode(array("message" => "Pickup status was updated."));
            } else {
                // Set response code - 503 service unavailable
                http_response_code(503);

                // Tell the user
                echo json_encode(array("message" => "Unable to update pickup status."));
            }
        } else {
            // Set response code - 400 bad request
            http_response_code(400);

            // Tell the user
            echo json_encode(array("message" => "Unable to update pickup status. Data is incomplete."));
        }
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

    // Create default recycling categories
    private function createDefaultCategories() {
        // Default categories
        $categories = array(
            array(
                'name' => 'Electronic Waste',
                'description' => 'Old electronics, batteries, and electronic components',
                'coin_value' => 50,
                'image' => 'e-waste.jpg'
            ),
            array(
                'name' => 'Plastic',
                'description' => 'Plastic bottles, containers, and packaging',
                'coin_value' => 10,
                'image' => 'plastic.jpg'
            ),
            array(
                'name' => 'Paper',
                'description' => 'Newspapers, magazines, cardboard, and paper packaging',
                'coin_value' => 5,
                'image' => 'paper.jpg'
            ),
            array(
                'name' => 'Metal',
                'description' => 'Aluminum cans, scrap metal, and metal containers',
                'coin_value' => 15,
                'image' => 'metal.jpg'
            ),
            array(
                'name' => 'Glass',
                'description' => 'Glass bottles and containers',
                'coin_value' => 8,
                'image' => 'glass.jpg'
            )
        );

        // Insert categories
        foreach($categories as $category) {
            $query = "INSERT INTO recycling_categories (name, description, coin_value, image)
                    VALUES ('{$category['name']}', '{$category['description']}', '{$category['coin_value']}', '{$category['image']}')";

            mysqli_query($this->db, $query);
        }
    }
}

// Process the request
$controller = new RecyclingController();

// Get the request method
$request_method = $_SERVER["REQUEST_METHOD"];

// Route the request to the appropriate method
if($request_method == "POST") {
    // Check the endpoint
    $endpoint = basename($_SERVER['REQUEST_URI']);

    if($endpoint == "submit") {
        $controller->submitActivity();
    } else if($endpoint == "update_status") {
        $controller->updateStatus();
    } else if($endpoint == "update_pickup_status") {
        $controller->updatePickupStatus();
    } else {
        // Set response code - 404 Not found
        http_response_code(404);

        // Tell the user
        echo json_encode(array("message" => "Endpoint not found."));
    }
} else if($request_method == "GET") {
    // Check the endpoint
    $endpoint = basename(strtok($_SERVER["REQUEST_URI"], '?'));

    if($endpoint == "user_activities") {
        $controller->getUserActivities();
    } else if($endpoint == "activity") {
        $controller->getActivity();
    } else if($endpoint == "categories") {
        $controller->getCategories();
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
