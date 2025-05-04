<?php
class RecyclingActivity {
    // Database connection and table name
    private $conn;
    private $table_name = "recycling_activities";

    // Object properties
    public $id;
    public $user_id;
    public $category_id;
    public $quantity;
    public $coins_earned;
    public $status;
    public $proof_image;
    public $notes;
    public $pickup_date;
    public $pickup_time_slot;
    public $pickup_address;
    public $pickup_status;
    public $created_at;
    public $updated_at;

    // Constructor with database connection
    public function __construct($db) {
        $this->conn = $db;
    }

    // Create new recycling activity
    public function create() {
        // Sanitize inputs
        $this->user_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->user_id)));
        $this->category_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->category_id)));
        $this->quantity = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->quantity)));
        $this->coins_earned = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->coins_earned)));
        $this->status = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->status)));
        $this->proof_image = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->proof_image)));
        $this->notes = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->notes)));

        // Sanitize pickup fields if they exist
        $this->pickup_date = isset($this->pickup_date) ? mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->pickup_date))) : null;
        $this->pickup_time_slot = isset($this->pickup_time_slot) ? mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->pickup_time_slot))) : null;
        $this->pickup_address = isset($this->pickup_address) ? mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->pickup_address))) : null;
        $this->pickup_status = isset($this->pickup_status) ? mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->pickup_status))) : 'not_required';

        // Query to insert new recycling activity
        $query = "INSERT INTO " . $this->table_name . "
                (user_id, category_id, quantity, coins_earned, status, proof_image, notes,
                pickup_date, pickup_time_slot, pickup_address, pickup_status)
                VALUES
                ('{$this->user_id}', '{$this->category_id}', '{$this->quantity}', '{$this->coins_earned}',
                '{$this->status}', '{$this->proof_image}', '{$this->notes}',
                " . ($this->pickup_date ? "'{$this->pickup_date}'" : "NULL") . ",
                " . ($this->pickup_time_slot ? "'{$this->pickup_time_slot}'" : "NULL") . ",
                " . ($this->pickup_address ? "'{$this->pickup_address}'" : "NULL") . ",
                '{$this->pickup_status}')";

        // Execute query
        if(mysqli_query($this->conn, $query)) {
            // Get the ID of the newly created activity
            $this->id = mysqli_insert_id($this->conn);
            return true;
        }

        return false;
    }

    // Read all recycling activities for a user
    public function readByUser() {
        // Sanitize user ID
        $this->user_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->user_id)));

        // Query to read all recycling activities for a user
        $query = "SELECT ra.*, rc.name as category_name, rc.coin_value
                FROM " . $this->table_name . " ra
                LEFT JOIN recycling_categories rc ON ra.category_id = rc.id
                WHERE ra.user_id = '{$this->user_id}'
                ORDER BY ra.created_at DESC";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        return $result;
    }

    // Read one recycling activity
    public function readOne() {
        // Sanitize ID
        $this->id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->id)));

        // Query to read one recycling activity
        $query = "SELECT ra.*, rc.name as category_name, rc.coin_value
                FROM " . $this->table_name . " ra
                LEFT JOIN recycling_categories rc ON ra.category_id = rc.id
                WHERE ra.id = '{$this->id}'
                LIMIT 0,1";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        // Get row count
        $num = mysqli_num_rows($result);

        // If recycling activity exists
        if($num > 0) {
            // Get record details
            $row = mysqli_fetch_assoc($result);

            // Set values to object properties
            $this->user_id = $row['user_id'];
            $this->category_id = $row['category_id'];
            $this->quantity = $row['quantity'];
            $this->coins_earned = $row['coins_earned'];
            $this->status = $row['status'];
            $this->proof_image = $row['proof_image'];
            $this->notes = $row['notes'];
            $this->pickup_date = $row['pickup_date'] ?? null;
            $this->pickup_time_slot = $row['pickup_time_slot'] ?? null;
            $this->pickup_address = $row['pickup_address'] ?? null;
            $this->pickup_status = $row['pickup_status'] ?? 'not_required';
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];

            return true;
        }

        return false;
    }

    // Update recycling activity status
    public function updateStatus() {
        // Sanitize inputs
        $this->id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->id)));
        $this->status = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->status)));
        $this->notes = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->notes)));

        // Query to update recycling activity status
        $query = "UPDATE " . $this->table_name . "
                SET
                    status = '{$this->status}',
                    notes = '{$this->notes}'
                WHERE
                    id = '{$this->id}'";

        // Execute query
        if(mysqli_query($this->conn, $query)) {
            return true;
        }

        return false;
    }

    // Get all recycling categories
    public function getCategories() {
        // Query to get all recycling categories
        $query = "SELECT * FROM recycling_categories ORDER BY name";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        return $result;
    }

    // Update pickup status
    public function updatePickupStatus() {
        // Sanitize inputs
        $this->id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->id)));
        $this->pickup_status = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->pickup_status)));

        // Sanitize optional fields
        $pickup_date_sql = $this->pickup_date ? "pickup_date = '{$this->pickup_date}'" : "";
        $pickup_time_slot_sql = $this->pickup_time_slot ? "pickup_time_slot = '{$this->pickup_time_slot}'" : "";
        $pickup_address_sql = $this->pickup_address ? "pickup_address = '{$this->pickup_address}'" : "";

        // Build the SET clause
        $set_clause = "pickup_status = '{$this->pickup_status}'";

        if($pickup_date_sql) {
            $set_clause .= ", " . $pickup_date_sql;
        }

        if($pickup_time_slot_sql) {
            $set_clause .= ", " . $pickup_time_slot_sql;
        }

        if($pickup_address_sql) {
            $set_clause .= ", " . $pickup_address_sql;
        }

        // Query to update pickup status
        $query = "UPDATE " . $this->table_name . "
                SET {$set_clause}
                WHERE id = '{$this->id}'";

        // Execute query
        if(mysqli_query($this->conn, $query)) {
            return true;
        }

        return false;
    }

    // Calculate coins based on category and quantity
    public function calculateCoins() {
        // Sanitize category ID
        $this->category_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->category_id)));

        // Query to get coin value for the category
        $query = "SELECT coin_value FROM recycling_categories WHERE id = '{$this->category_id}' LIMIT 0,1";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        // Get row count
        $num = mysqli_num_rows($result);

        // If category exists
        if($num > 0) {
            // Get record details
            $row = mysqli_fetch_assoc($result);

            // Calculate coins earned
            $this->coins_earned = $row['coin_value'] * $this->quantity;

            return true;
        }

        return false;
    }
}
?>
