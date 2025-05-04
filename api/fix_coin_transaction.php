<?php
// Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Include database and models
include_once 'config/database.php';
include_once 'models/RecyclingActivity.php';
include_once 'models/User.php';
include_once 'models/Coin.php';

// Create database connection
$database = new Database();
$db = $database->getConnection();

// Initialize models
$recycling = new RecyclingActivity($db);
$user = new User($db);
$coin = new Coin($db);

// Function to fix missing coin transaction
function fixMissingCoinTransaction($db, $activityId) {
    // Get the recycling activity
    $recycling = new RecyclingActivity($db);
    $recycling->id = $activityId;
    
    // Check if activity exists and is approved
    if (!$recycling->readOne()) {
        return array("error" => "Activity not found");
    }
    
    if ($recycling->status != "approved") {
        return array("error" => "Activity is not approved");
    }
    
    // Check if a coin transaction already exists for this activity
    $query = "SELECT id FROM coin_transactions 
              WHERE reference_id = '{$activityId}' 
              AND reference_type = 'recycling' 
              AND transaction_type = 'earned'";
    
    $result = mysqli_query($db, $query);
    
    if (mysqli_num_rows($result) > 0) {
        return array("error" => "Coin transaction already exists for this activity");
    }
    
    // Create coin transaction
    $coin = new Coin($db);
    $coin->user_id = $recycling->user_id;
    $coin->amount = $recycling->coins_earned;
    $coin->transaction_type = "earned";
    $coin->reference_id = $recycling->id;
    $coin->reference_type = "recycling";
    $coin->description = "Coins earned from recycling activity";
    
    // Start transaction
    mysqli_begin_transaction($db);
    
    try {
        // Create the coin transaction
        if (!$coin->create()) {
            mysqli_rollback($db);
            return array("error" => "Failed to create coin transaction");
        }
        
        // Update user's coin balance
        $query = "UPDATE users
                SET coin_balance = coin_balance + '{$coin->amount}'
                WHERE id = '{$coin->user_id}'";
        
        if (!mysqli_query($db, $query)) {
            mysqli_rollback($db);
            return array("error" => "Failed to update user's coin balance");
        }
        
        // Commit transaction
        mysqli_commit($db);
        
        // Get updated coin balance
        $user = new User($db);
        $user->id = $recycling->user_id;
        $user->readOne();
        
        return array(
            "success" => true,
            "message" => "Coin transaction created successfully",
            "transaction" => array(
                "user_id" => $coin->user_id,
                "amount" => $coin->amount,
                "transaction_type" => $coin->transaction_type,
                "reference_id" => $coin->reference_id,
                "reference_type" => $coin->reference_type,
                "description" => $coin->description
            ),
            "updated_balance" => $user->coin_balance
        );
    } catch (Exception $e) {
        mysqli_rollback($db);
        return array("error" => "Transaction failed: " . $e->getMessage());
    }
}

// Check if activity ID is provided
if (isset($_GET['activity_id'])) {
    $activityId = $_GET['activity_id'];
    
    // Fix the missing coin transaction
    $result = fixMissingCoinTransaction($db, $activityId);
    
    // Return the result
    echo json_encode($result);
} else {
    // List all approved activities without coin transactions
    $query = "SELECT ra.id, ra.user_id, ra.coins_earned, ra.status, ra.created_at, u.username 
              FROM recycling_activities ra
              JOIN users u ON ra.user_id = u.id
              WHERE ra.status = 'approved' 
              AND NOT EXISTS (
                  SELECT 1 FROM coin_transactions ct 
                  WHERE ct.reference_id = ra.id 
                  AND ct.reference_type = 'recycling'
              )";
    
    $result = mysqli_query($db, $query);
    
    if ($result && mysqli_num_rows($result) > 0) {
        $activities = array();
        
        while ($row = mysqli_fetch_assoc($result)) {
            $activities[] = $row;
        }
        
        echo json_encode(array(
            "message" => "The following approved activities have no coin transactions",
            "activities" => $activities
        ));
    } else {
        echo json_encode(array("message" => "No missing coin transactions found"));
    }
}
?>
