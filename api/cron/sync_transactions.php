<?php
// This script is designed to be run as a scheduled task (cron job)
// It will check for and fix any missing transactions

// Include database and models
include_once '../config/database.php';
include_once '../models/RecyclingActivity.php';
include_once '../models/User.php';
include_once '../models/Coin.php';

// Create database connection
$database = new Database();
$db = $database->getConnection();

// Find all approved activities without corresponding transactions
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

if (!$result) {
    echo "Database error checking for missing transactions\n";
    exit(1);
}

$num = mysqli_num_rows($result);

if ($num > 0) {
    echo "Found $num missing transactions\n";
    
    $fixed_count = 0;
    $error_count = 0;
    
    // Process each missing transaction
    while ($row = mysqli_fetch_assoc($result)) {
        $activity_id = $row['id'];
        $user_id = $row['user_id'];
        $coins_earned = $row['coins_earned'];
        $username = $row['username'];
        
        echo "Processing: Activity ID: $activity_id, User: $username, Coins: $coins_earned\n";
        
        // Start transaction
        mysqli_begin_transaction($db);
        
        try {
            // Create coin transaction
            $coin = new Coin($db);
            $coin->user_id = $user_id;
            $coin->amount = $coins_earned;
            $coin->transaction_type = "earned";
            $coin->reference_id = $activity_id;
            $coin->reference_type = "recycling";
            $coin->description = "Coins earned from recycling activity (auto-sync)";
            
            if (!$coin->create()) {
                mysqli_rollback($db);
                echo "  Error: Failed to create coin transaction\n";
                $error_count++;
                continue;
            }
            
            // Update user's coin balance
            $query = "UPDATE users
                    SET coin_balance = coin_balance + '$coins_earned'
                    WHERE id = '$user_id'";
            
            if (!mysqli_query($db, $query)) {
                mysqli_rollback($db);
                echo "  Error: Failed to update user balance\n";
                $error_count++;
                continue;
            }
            
            // Get updated coin balance
            $user = new User($db);
            $user->id = $user_id;
            $user->readOne();
            
            // Commit transaction
            mysqli_commit($db);
            
            echo "  Success: Transaction created, new balance: {$user->coin_balance}\n";
            $fixed_count++;
        } catch (Exception $e) {
            mysqli_rollback($db);
            echo "  Error: Transaction failed - " . $e->getMessage() . "\n";
            $error_count++;
        }
    }
    
    echo "Summary: Fixed $fixed_count transactions, $error_count errors\n";
} else {
    echo "No missing transactions found\n";
}

echo "Transaction sync completed\n";
?>
