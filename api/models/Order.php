<?php
class Order {
    // Database connection and table names
    private $conn;
    private $table_name = "orders";
    private $items_table = "order_items";

    // Object properties
    public $id;
    public $user_id;
    public $total_coin_amount;
    public $status;
    public $shipping_address;
    public $contact_phone;
    public $notes;
    public $created_at;
    public $updated_at;
    public $items = array(); // Array of order items

    // Constructor with database connection
    public function __construct($db) {
        $this->conn = $db;
    }

    // Create new order
    public function create() {
        // Start transaction
        mysqli_begin_transaction($this->conn);

        try {
            // Sanitize inputs
            $this->user_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->user_id)));
            $this->total_coin_amount = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->total_coin_amount)));
            $this->status = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->status)));
            $this->shipping_address = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->shipping_address)));
            $this->contact_phone = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->contact_phone)));
            $this->notes = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->notes)));

            // Query to insert new order
            $query = "INSERT INTO " . $this->table_name . "
                    (user_id, total_coin_amount, status, shipping_address, contact_phone, notes)
                    VALUES
                    ('{$this->user_id}', '{$this->total_coin_amount}', '{$this->status}',
                    '{$this->shipping_address}', '{$this->contact_phone}', '{$this->notes}')";

            // Execute query
            if(!mysqli_query($this->conn, $query)) {
                mysqli_rollback($this->conn);
                return false;
            }

            // Get the ID of the newly created order
            $this->id = mysqli_insert_id($this->conn);

            // Create order items
            foreach($this->items as $item) {
                // Sanitize item data
                $product_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($item['product_id'])));
                $quantity = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($item['quantity'])));
                $coin_price = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($item['coin_price'])));

                // Query to insert order item
                $query = "INSERT INTO " . $this->items_table . "
                        (order_id, product_id, quantity, coin_price)
                        VALUES
                        ('{$this->id}', '{$product_id}', '{$quantity}', '{$coin_price}')";

                // Execute query
                if(!mysqli_query($this->conn, $query)) {
                    mysqli_rollback($this->conn);
                    return false;
                }

                // Update product stock
                $product = new Product($this->conn);
                $product->id = $item['product_id'];
                if(!$product->updateStock($item['quantity'])) {
                    mysqli_rollback($this->conn);
                    return false;
                }
            }

            // Create coin transaction for the order
            $coin = new Coin($this->conn);
            $coin->user_id = $this->user_id;
            $coin->amount = -$this->total_coin_amount; // Negative amount for spending
            $coin->transaction_type = "spent";
            $coin->reference_id = $this->id;
            $coin->reference_type = "purchase";
            $coin->description = "Purchase of products";

            if(!$coin->spendCoins()) {
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

    // Read all orders for a user
    public function readByUser() {
        // Sanitize user ID
        $this->user_id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->user_id)));

        // Query to read all orders for a user
        $query = "SELECT * FROM " . $this->table_name . "
                WHERE user_id = '{$this->user_id}'
                ORDER BY created_at DESC";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        return $result;
    }

    // Read one order with its items
    public function readOne() {
        // Sanitize ID
        $this->id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->id)));

        // Query to read one order
        $query = "SELECT * FROM " . $this->table_name . "
                WHERE id = '{$this->id}'
                LIMIT 0,1";

        // Execute query
        $result = mysqli_query($this->conn, $query);

        // Get row count
        $num = mysqli_num_rows($result);

        // If order exists
        if($num > 0) {
            // Get record details
            $row = mysqli_fetch_assoc($result);

            // Set values to object properties
            $this->user_id = $row['user_id'];
            $this->total_coin_amount = $row['total_coin_amount'];
            $this->status = $row['status'];
            $this->shipping_address = $row['shipping_address'];
            $this->contact_phone = $row['contact_phone'];
            $this->notes = $row['notes'];
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];

            // Query to read order items
            $query = "SELECT oi.*, p.name as product_name, p.image as product_image
                    FROM " . $this->items_table . " oi
                    LEFT JOIN products p ON oi.product_id = p.id
                    WHERE oi.order_id = '{$this->id}'";

            // Execute query
            $items_result = mysqli_query($this->conn, $query);

            // Get order items
            $this->items = array();
            while($row = mysqli_fetch_assoc($items_result)) {
                $item = array(
                    "id" => $row['id'],
                    "product_id" => $row['product_id'],
                    "product_name" => $row['product_name'],
                    "product_image" => $row['product_image'],
                    "quantity" => $row['quantity'],
                    "coin_price" => $row['coin_price'],
                    "total_price" => $row['quantity'] * $row['coin_price']
                );
                array_push($this->items, $item);
            }

            return true;
        }

        return false;
    }

    // Update order status
    public function updateStatus() {
        // Sanitize inputs
        $this->id = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->id)));
        $this->status = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->status)));
        $this->notes = mysqli_real_escape_string($this->conn, htmlspecialchars(strip_tags($this->notes)));

        // Query to update order status
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

    // Calculate total coin amount for items
    public function calculateTotal() {
        $total = 0;

        foreach($this->items as $item) {
            $total += $item['quantity'] * $item['coin_price'];
        }

        $this->total_coin_amount = $total;

        return $total;
    }
}
?>
