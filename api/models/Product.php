<?php
class Product {
    // Database connection and table name
    private $conn;
    private $table_name = "products";

    // Object properties
    public $id;
    public $category_id;
    public $name;
    public $description;
    public $coin_price;
    public $stock_quantity;
    public $image;
    public $is_featured;
    public $created_at;
    public $updated_at;

    // Constructor with database connection
    public function __construct($db) {
        $this->conn = $db;
    }

    // Read all products
    public function read() {
        // Query to read all products
        $query = "SELECT p.*, pc.name as category_name
                FROM " . $this->table_name . " p
                LEFT JOIN product_categories pc ON p.category_id = pc.id
                ORDER BY p.name";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        return $result;
    }

    // Read featured products
    public function readFeatured() {
        // Query to read featured products
        $query = "SELECT p.*, pc.name as category_name
                FROM " . $this->table_name . " p
                LEFT JOIN product_categories pc ON p.category_id = pc.id
                WHERE p.is_featured = 1
                ORDER BY p.name";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        return $result;
    }

    // Read products by category
    public function readByCategory() {
        // Sanitize category ID
        $this->category_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->category_id)));

        // Query to read products by category
        $query = "SELECT p.*, pc.name as category_name
                FROM " . $this->table_name . " p
                LEFT JOIN product_categories pc ON p.category_id = pc.id
                WHERE p.category_id = {$this->category_id}
                ORDER BY p.name";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        return $result;
    }

    // Read one product
    public function readOne() {
        // Sanitize ID
        $this->id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->id)));

        // Query to read one product
        $query = "SELECT p.*, pc.name as category_name
                FROM " . $this->table_name . " p
                LEFT JOIN product_categories pc ON p.category_id = pc.id
                WHERE p.id = {$this->id}
                LIMIT 0,1";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        // Get row count
        $num = mysqli_num_rows($result);

        // If product exists
        if($num > 0) {
            // Get record details
            $row = mysqli_fetch_assoc($result);

            // Set values to object properties
            $this->category_id = $row['category_id'];
            $this->name = $row['name'];
            $this->description = $row['description'];
            $this->coin_price = $row['coin_price'];
            $this->stock_quantity = $row['stock_quantity'];
            $this->image = $row['image'];
            $this->is_featured = $row['is_featured'];
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];

            return true;
        }

        return false;
    }

    // Get all product categories
    public function getCategories() {
        // Query to get all product categories
        $query = "SELECT * FROM product_categories ORDER BY name";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        return $result;
    }

    // Update product stock
    public function updateStock($quantity) {
        // Sanitize inputs
        $this->id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->id)));
        $quantity = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($quantity)));

        // Query to update product stock
        $query = "UPDATE " . $this->table_name . "
                SET
                    stock_quantity = stock_quantity - {$quantity}
                WHERE
                    id = {$this->id}";

        // Execute query
        if(mysqli_query($this->conn, $query)) {
            return true;
        }

        return false;
    }

    // Check if product is in stock
    public function isInStock($quantity) {
        // Sanitize ID
        $this->id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->id)));

        // Query to check if product is in stock
        $query = "SELECT stock_quantity FROM " . $this->table_name . " WHERE id = {$this->id} LIMIT 0,1";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        // Get row count
        $num = mysqli_num_rows($result);

        // If product exists
        if($num > 0) {
            // Get record details
            $row = mysqli_fetch_assoc($result);

            // Check if stock is sufficient
            return $row['stock_quantity'] >= $quantity;
        }

        return false;
    }
}
?>
