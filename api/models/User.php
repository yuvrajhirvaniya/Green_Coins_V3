<?php
class User {
    // Database connection and table name
    private $conn;
    private $table_name = "users";

    // Object properties
    public $id;
    public $username;
    public $email;
    public $password;
    public $full_name;
    public $phone;
    public $address;
    public $profile_image;
    public $coin_balance;
    public $created_at;
    public $updated_at;

    // Constructor with database connection
    public function __construct($db) {
        $this->conn = $db;
    }

    // Create new user
    public function create() {
        // Sanitize inputs
        $this->username = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->username)));
        $this->email = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->email)));
        $this->full_name = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->full_name)));
        $this->phone = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->phone)));
        $this->address = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->address)));
        $this->profile_image = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->profile_image)));

        // Hash the password
        $this->password = password_hash($this->password, PASSWORD_BCRYPT);

        // Query to insert new user
        $query = "INSERT INTO " . $this->table_name . "
                (username, email, password, full_name, phone, address, profile_image, coin_balance)
                VALUES
                ('{$this->username}', '{$this->email}', '{$this->password}', '{$this->full_name}',
                '{$this->phone}', '{$this->address}', '{$this->profile_image}', 0)";

        // Execute query
        if(mysqli_query($this->conn, $query)) {
            return true;
        }

        return false;
    }

    // Login user
    public function login() {
        // Sanitize username
        $this->username = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->username)));

        // Query to check if username exists
        $query = "SELECT id, username, email, password, full_name, coin_balance
                FROM " . $this->table_name . "
                WHERE username = '{$this->username}'
                LIMIT 0,1";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        // Get row count
        $num = mysqli_num_rows($result);

        // If user exists
        if($num > 0) {
            // Get record details
            $row = mysqli_fetch_assoc($result);

            // Verify password
            if(password_verify($this->password, $row['password'])) {
                // Set values to object properties
                $this->id = $row['id'];
                $this->email = $row['email'];
                $this->full_name = $row['full_name'];
                $this->coin_balance = $row['coin_balance'];

                return true;
            }
        }

        return false;
    }

    // Get user by ID
    public function readOne() {
        // Sanitize ID
        $this->id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->id)));

        // Query to read one user
        $query = "SELECT * FROM " . $this->table_name . " WHERE id = {$this->id} LIMIT 0,1";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        // Get row count
        $num = mysqli_num_rows($result);

        // If user exists
        if($num > 0) {
            // Get record details
            $row = mysqli_fetch_assoc($result);

            // Set values to object properties
            $this->username = $row['username'];
            $this->email = $row['email'];
            $this->full_name = $row['full_name'];
            $this->phone = $row['phone'];
            $this->address = $row['address'];
            $this->profile_image = $row['profile_image'];
            $this->coin_balance = $row['coin_balance'];
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];

            return true;
        }

        return false;
    }

    // Update user
    public function update() {
        // Sanitize inputs
        $this->id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->id)));
        $this->username = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->username)));
        $this->email = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->email)));
        $this->full_name = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->full_name)));
        $this->phone = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->phone)));
        $this->address = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->address)));
        $this->profile_image = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->profile_image)));

        // Query to update user
        $query = "UPDATE " . $this->table_name . "
                SET
                    username = '{$this->username}',
                    email = '{$this->email}',
                    full_name = '{$this->full_name}',
                    phone = '{$this->phone}',
                    address = '{$this->address}',
                    profile_image = '{$this->profile_image}'
                WHERE
                    id = {$this->id}";

        // Execute query
        if(mysqli_query($this->conn, $query)) {
            return true;
        }

        return false;
    }

    // Update password
    public function updatePassword() {
        // Sanitize inputs
        $this->id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->id)));

        // Hash the password
        $this->password = password_hash($this->password, PASSWORD_BCRYPT);

        // Query to update password
        $query = "UPDATE " . $this->table_name . "
                SET
                    password = '{$this->password}'
                WHERE
                    id = {$this->id}";

        // Execute query
        if(mysqli_query($this->conn, $query)) {
            return true;
        }

        return false;
    }

    // Update coin balance
    public function updateCoinBalance($amount) {
        // Sanitize inputs
        $this->id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->id)));
        $amount = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($amount)));

        // Query to update coin balance
        $query = "UPDATE " . $this->table_name . "
                SET
                    coin_balance = coin_balance + {$amount}
                WHERE
                    id = {$this->id}";

        // Execute query
        if(mysqli_query($this->conn, $query)) {
            // Update the object's coin balance
            $this->coin_balance += $amount;
            return true;
        }

        return false;
    }

    // Check if username exists
    public function usernameExists() {
        // Sanitize username
        $this->username = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->username)));

        // Query to check if username exists
        $query = "SELECT id FROM " . $this->table_name . " WHERE username = '{$this->username}' LIMIT 0,1";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        // Get row count
        $num = mysqli_num_rows($result);

        // If username exists
        if($num > 0) {
            return true;
        }

        return false;
    }

    // Check if email exists
    public function emailExists() {
        // Sanitize email
        $this->email = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->email)));

        // Query to check if email exists
        $query = "SELECT id FROM " . $this->table_name . " WHERE email = '{$this->email}' LIMIT 0,1";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        // Get row count
        $num = mysqli_num_rows($result);

        // If email exists
        if($num > 0) {
            return true;
        }

        return false;
    }
}
?>
