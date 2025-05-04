<?php
class Coin {
    // Database connection and table name
    private $conn;
    private $table_name = "coin_transactions";

    // Object properties
    public $id;
    public $user_id;
    public $amount;
    public $transaction_type;
    public $reference_id;
    public $reference_type;
    public $description;
    public $created_at;

    // Constructor with database connection
    public function __construct($db) {
        $this->conn = $db;
    }

    // Create new coin transaction
    public function create() {
        // Sanitize inputs
        $this->user_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->user_id)));
        $this->amount = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->amount)));
        $this->transaction_type = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->transaction_type)));
        $this->reference_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->reference_id)));
        $this->reference_type = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->reference_type)));
        $this->description = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->description)));

        // Query to insert new coin transaction
        $query = "INSERT INTO " . $this->table_name . "
                (user_id, amount, transaction_type, reference_id, reference_type, description)
                VALUES
                ('{$this->user_id}', '{$this->amount}', '{$this->transaction_type}',
                '{$this->reference_id}', '{$this->reference_type}', '{$this->description}')";

        // Execute query
        if(mysqli_query($this->conn, $query)) {
            return true;
        }

        return false;
    }

    // Read all coin transactions for a user
    public function readByUser() {
        // Sanitize user ID
        $this->user_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->user_id)));

        // Query to read all coin transactions for a user
        $query = "SELECT * FROM " . $this->table_name . "
                WHERE user_id = '{$this->user_id}'
                ORDER BY created_at DESC";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        return $result;
    }

    // Get user's coin balance
    public function getUserBalance() {
        // Sanitize user ID
        $this->user_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->user_id)));

        // Query to get user's coin balance
        $query = "SELECT coin_balance FROM users WHERE id = '{$this->user_id}' LIMIT 0,1";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        // Get row count
        $num = mysqli_num_rows($result);

        // If user exists
        if($num > 0) {
            // Get record details
            $row = mysqli_fetch_assoc($result);

            // Return coin balance
            return $row['coin_balance'];
        }

        return 0;
    }

    // Add coins to user
    public function addCoins() {
        // Start transaction
        mysqli_begin_transaction($this->conn);

        try {
            // Create coin transaction
            if(!$this->create()) {
                mysqli_rollback($this->conn);
                return false;
            }

            // Sanitize inputs
            $this->user_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->user_id)));
            $this->amount = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->amount)));

            // Update user's coin balance
            $query = "UPDATE users
                    SET coin_balance = coin_balance + '{$this->amount}'
                    WHERE id = '{$this->user_id}'";

            // Execute query
            if(!mysqli_query($this->conn, $query)) {
                mysqli_rollback($this->conn);
                return false;
            }

            // Commit transaction
            mysqli_commit($this->conn);
            return true;
        } catch(Exception $e) {
            mysqli_rollback($this->conn);
            return false;
        }
    }

    // Spend coins
    public function spendCoins() {
        // Start transaction
        mysqli_begin_transaction($this->conn);

        try {
            // Check if user has enough coins
            $balance = $this->getUserBalance();
            if($balance < abs($this->amount)) {
                mysqli_rollback($this->conn);
                return false;
            }

            // Create coin transaction (amount should be negative for spending)
            if(!$this->create()) {
                mysqli_rollback($this->conn);
                return false;
            }

            // Sanitize inputs
            $this->user_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->user_id)));
            $this->amount = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->amount)));

            // Update user's coin balance
            $query = "UPDATE users
                    SET coin_balance = coin_balance + '{$this->amount}'
                    WHERE id = '{$this->user_id}'";

            // Execute query
            if(!mysqli_query($this->conn, $query)) {
                mysqli_rollback($this->conn);
                return false;
            }

            // Commit transaction
            mysqli_commit($this->conn);
            return true;
        } catch(Exception $e) {
            mysqli_rollback($this->conn);
            return false;
        }
    }
}
?>
