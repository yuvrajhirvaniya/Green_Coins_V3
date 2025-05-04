<?php
// Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database and models
include_once 'config/database.php';
include_once 'models/Product.php';

class ProductController {
    // Database connection and product model
    private $database;
    private $db;
    private $product;

    // Constructor
    public function __construct() {
        // Get database connection
        $this->database = new Database();
        $this->db = $this->database->getConnection();

        // Initialize product model
        $this->product = new Product($this->db);
    }

    // Get all products
    public function getProducts() {
        // Read products
        $result = $this->product->read();
        $num = mysqli_num_rows($result);

        // Check if any products found
        if($num > 0) {
            // Products array
            $products_arr = array();
            $products_arr["records"] = array();

            // Retrieve table contents
            while($row = mysqli_fetch_assoc($result)) {
                // Extract row
                extract($row);

                $product_item = array(
                    "id" => $id,
                    "category_id" => $category_id,
                    "category_name" => $category_name,
                    "name" => $name,
                    "description" => $description,
                    "coin_price" => $coin_price,
                    "stock_quantity" => $stock_quantity,
                    "image" => $image,
                    "is_featured" => $is_featured,
                    "created_at" => $created_at,
                    "updated_at" => $updated_at
                );

                array_push($products_arr["records"], $product_item);
            }

            // Set response code - 200 OK
            http_response_code(200);

            // Show products data
            echo json_encode($products_arr);
        } else {
            // Set response code - 404 Not found
            http_response_code(404);

            // Tell the user no products found
            echo json_encode(array("message" => "No products found."));
        }
    }

    // Get featured products
    public function getFeaturedProducts() {
        // Read featured products
        $result = $this->product->readFeatured();
        $num = mysqli_num_rows($result);

        // Check if any products found
        if($num > 0) {
            // Products array
            $products_arr = array();
            $products_arr["records"] = array();

            // Retrieve table contents
            while($row = mysqli_fetch_assoc($result)) {
                // Extract row
                extract($row);

                $product_item = array(
                    "id" => $id,
                    "category_id" => $category_id,
                    "category_name" => $category_name,
                    "name" => $name,
                    "description" => $description,
                    "coin_price" => $coin_price,
                    "stock_quantity" => $stock_quantity,
                    "image" => $image,
                    "is_featured" => $is_featured,
                    "created_at" => $created_at,
                    "updated_at" => $updated_at
                );

                array_push($products_arr["records"], $product_item);
            }

            // Set response code - 200 OK
            http_response_code(200);

            // Show products data
            echo json_encode($products_arr);
        } else {
            // Set response code - 404 Not found
            http_response_code(404);

            // Tell the user no products found
            echo json_encode(array("message" => "No featured products found."));
        }
    }

    // Get products by category
    public function getProductsByCategory() {
        // Get category ID from URL
        $category_id = isset($_GET['category_id']) ? $_GET['category_id'] : die();

        // Set category ID
        $this->product->category_id = $category_id;

        // Read products by category
        $result = $this->product->readByCategory();
        $num = mysqli_num_rows($result);

        // Check if any products found
        if($num > 0) {
            // Products array
            $products_arr = array();
            $products_arr["records"] = array();

            // Retrieve table contents
            while($row = mysqli_fetch_assoc($result)) {
                // Extract row
                extract($row);

                $product_item = array(
                    "id" => $id,
                    "category_id" => $category_id,
                    "category_name" => $category_name,
                    "name" => $name,
                    "description" => $description,
                    "coin_price" => $coin_price,
                    "stock_quantity" => $stock_quantity,
                    "image" => $image,
                    "is_featured" => $is_featured,
                    "created_at" => $created_at,
                    "updated_at" => $updated_at
                );

                array_push($products_arr["records"], $product_item);
            }

            // Set response code - 200 OK
            http_response_code(200);

            // Show products data
            echo json_encode($products_arr);
        } else {
            // Set response code - 404 Not found
            http_response_code(404);

            // Tell the user no products found
            echo json_encode(array("message" => "No products found in this category."));
        }
    }

    // Get a single product
    public function getProduct() {
        // Get product ID from URL
        $id = isset($_GET['id']) ? $_GET['id'] : die();

        // Set product ID
        $this->product->id = $id;

        // Read product details
        if($this->product->readOne()) {
            // Create array
            $product_arr = array(
                "id" => $this->product->id,
                "category_id" => $this->product->category_id,
                "name" => $this->product->name,
                "description" => $this->product->description,
                "coin_price" => $this->product->coin_price,
                "stock_quantity" => $this->product->stock_quantity,
                "image" => $this->product->image,
                "is_featured" => $this->product->is_featured,
                "created_at" => $this->product->created_at,
                "updated_at" => $this->product->updated_at
            );

            // Set response code - 200 OK
            http_response_code(200);

            // Make it json format
            echo json_encode($product_arr);
        } else {
            // Set response code - 404 Not found
            http_response_code(404);

            // Tell the user
            echo json_encode(array("message" => "Product does not exist."));
        }
    }

    // Get all product categories
    public function getCategories() {
        // Read categories
        $result = $this->product->getCategories();
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
            echo json_encode(array("message" => "No product categories found."));
        }
    }
}

// Process the request
$controller = new ProductController();

// Get the request method
$request_method = $_SERVER["REQUEST_METHOD"];

// Route the request to the appropriate method
if($request_method == "GET") {
    // Check the endpoint
    $endpoint = basename(strtok($_SERVER["REQUEST_URI"], '?'));

    if($endpoint == "all") {
        $controller->getProducts();
    } else if($endpoint == "featured") {
        $controller->getFeaturedProducts();
    } else if($endpoint == "by_category") {
        $controller->getProductsByCategory();
    } else if($endpoint == "product") {
        $controller->getProduct();
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
