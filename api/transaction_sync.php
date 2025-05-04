<?php
// Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database and models
include_once 'config/database.php';
include_once 'models/RecyclingActivity.php';
include_once 'models/User.php';
include_once 'models/Coin.php';

class TransactionSyncController {
    // Database connection
    private $database;
    private $db;

    // Constructor
    public function __construct() {
        // Get database connection
        $this->database = new Database();
        $this->db = $this->database->getConnection();
    }

    // Sync all missing transactions
    public function syncTransactions() {
        // Get user ID from URL if provided
        $user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;

        // Find all approved activities without corresponding transactions
        $query = "SELECT ra.id, ra.user_id, ra.coins_earned, ra.status, ra.created_at
                  FROM recycling_activities ra
                  WHERE ra.status = 'approved'
                  AND NOT EXISTS (
                      SELECT 1 FROM coin_transactions ct
                      WHERE ct.reference_id = ra.id
                      AND ct.reference_type = 'recycling'
                  )";

        // Add user filter if provided
        if ($user_id !== null) {
            $query .= " AND ra.user_id = '$user_id'";
        }

        $result = mysqli_query($this->db, $query);

        if (!$result) {
            // Set response code - 500 Internal Server Error
            http_response_code(500);

            // Tell the user
            echo json_encode(array("message" => "Database error. Unable to check for missing transactions."));
            return;
        }

        $num = mysqli_num_rows($result);

        if ($num > 0) {
            $fixed_transactions = array();
            $errors = array();

            // Process each missing transaction
            while ($row = mysqli_fetch_assoc($result)) {
                $transaction_result = $this->createMissingTransaction($row['id'], $row['user_id'], $row['coins_earned']);

                if (isset($transaction_result['success'])) {
                    $fixed_transactions[] = $transaction_result;
                } else {
                    $errors[] = $transaction_result;
                }
            }

            // Set response code - 200 OK
            http_response_code(200);

            // Tell the user
            echo json_encode(array(
                "message" => "Transaction sync completed",
                "fixed_count" => count($fixed_transactions),
                "error_count" => count($errors),
                "fixed_transactions" => $fixed_transactions,
                "errors" => $errors,
                "timestamp" => date('Y-m-d H:i:s')
            ));
        } else {
            // Set response code - 200 OK
            http_response_code(200);

            // Tell the user
            echo json_encode(array(
                "message" => "No missing transactions found",
                "fixed_count" => 0,
                "error_count" => 0,
                "timestamp" => date('Y-m-d H:i:s')
            ));
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
                return array("error" => "Failed to create coin transaction for activity ID: $activity_id");
            }

            // Update user's coin balance
            $query = "UPDATE users
                    SET coin_balance = coin_balance + '$coins_earned'
                    WHERE id = '$user_id'";

            if (!mysqli_query($this->db, $query)) {
                mysqli_rollback($this->db);
                return array("error" => "Failed to update user balance for activity ID: $activity_id");
            }

            // Get updated coin balance
            $user = new User($this->db);
            $user->id = $user_id;
            $user->readOne();

            // Commit transaction
            mysqli_commit($this->db);

            return array(
                "success" => true,
                "activity_id" => $activity_id,
                "user_id" => $user_id,
                "coins_earned" => $coins_earned,
                "updated_balance" => $user->coin_balance
            );
        } catch (Exception $e) {
            mysqli_rollback($this->db);
            return array("error" => "Transaction failed for activity ID: $activity_id - " . $e->getMessage());
        }
    }
}

// Process the request
$controller = new TransactionSyncController();
$controller->syncTransactions();
?>
