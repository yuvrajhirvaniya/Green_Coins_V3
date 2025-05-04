<?php
class Database {
    // Database credentials
    private $host = "localhost";  // MySQL typically runs on default port 3306
    private $db_name = "green_coins";
    private $username = "root";
    private $password = "";
    public $conn;

    // Get database connection
    public function getConnection() {
        $this->conn = null;

        // Create connection using mysqli
        $this->conn = mysqli_connect($this->host, $this->username, $this->password, $this->db_name);

        // Check connection
        if (!$this->conn) {
            echo "Connection error: " . mysqli_connect_error();
        } else {
            // Set charset to utf8
            mysqli_set_charset($this->conn, "utf8");
        }

        return $this->conn;
    }
}
?>

