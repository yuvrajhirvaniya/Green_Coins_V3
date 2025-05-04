-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 04, 2025 at 06:27 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `green_coins`
--

-- --------------------------------------------------------

--
-- Table structure for table `coin_transactions`
--

CREATE TABLE `coin_transactions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `transaction_type` enum('earned','spent','refunded') NOT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `reference_type` enum('recycling','purchase','admin') NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `coin_transactions`
--

INSERT INTO `coin_transactions` (`id`, `user_id`, `amount`, `transaction_type`, `reference_id`, `reference_type`, `description`, `created_at`) VALUES
(9, 27, 50, 'earned', 17, 'recycling', 'Coins earned from recycling activity (auto-sync)', '2025-04-25 08:57:27'),
(10, 27, 500, 'earned', 18, 'recycling', 'Coins earned from recycling activity (auto-sync)', '2025-04-25 09:27:59'),
(11, 27, -100, 'spent', 1, 'purchase', 'Purchase of products', '2025-04-25 09:29:24'),
(12, 27, -100, 'spent', 2, 'purchase', 'Purchase of products', '2025-04-25 09:40:56'),
(13, 27, -100, 'spent', 3, 'purchase', 'Purchase of products', '2025-04-25 10:16:29'),
(14, 27, -100, 'spent', 4, 'purchase', 'Purchase of products', '2025-04-26 20:12:43'),
(15, 27, 50, 'earned', 19, 'recycling', 'Coins earned from recycling activity (auto-sync)', '2025-04-26 20:14:44'),
(16, 27, 5000, 'earned', 20, 'recycling', 'Coins earned from recycling activity (auto-sync)', '2025-04-26 20:14:49'),
(17, 27, -200, 'spent', 5, 'purchase', 'Purchase of products', '2025-04-26 20:15:33'),
(18, 27, -180, 'spent', 6, 'purchase', 'Purchase of products', '2025-04-29 09:24:01'),
(19, 27, -200, 'spent', 7, 'purchase', 'Purchase of products', '2025-04-29 09:51:03'),
(20, 29, 100, 'earned', 21, 'recycling', 'Coins earned from recycling activity (auto-sync)', '2025-05-02 09:28:53'),
(21, 29, -100, 'spent', 8, 'purchase', 'Purchase of products', '2025-05-02 09:29:44');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `total_coin_amount` int(11) NOT NULL,
  `status` enum('pending','processing','shipped','delivered','cancelled') DEFAULT 'pending',
  `shipping_address` text NOT NULL,
  `contact_phone` varchar(20) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `total_coin_amount`, `status`, `shipping_address`, `contact_phone`, `notes`, `created_at`, `updated_at`) VALUES
(1, 27, 100, 'delivered', 'surendranagar', '1234567891', 'call first', '2025-04-25 09:29:24', '2025-04-25 10:08:46'),
(2, 27, 100, 'cancelled', 'surendranagar', '9327968163', 'call first', '2025-04-25 09:40:56', '2025-04-26 20:17:09'),
(3, 27, 100, 'shipped', 'police ground road', '1234567891', 'notes', '2025-04-25 10:16:29', '2025-04-26 20:16:52'),
(4, 27, 100, 'processing', 'surendranagar', '9327968163', 'call first...', '2025-04-26 20:12:43', '2025-04-26 20:16:57'),
(5, 27, 200, 'pending', 'surendranagar', '9327968163', 'call first...', '2025-04-26 20:15:33', '2025-04-26 20:15:33'),
(6, 27, 180, 'pending', 'address', '1234567890', 'ntg', '2025-04-29 09:24:00', '2025-04-29 09:24:00'),
(7, 27, 200, 'pending', 'police ground road', '1234567891', '', '2025-04-29 09:51:03', '2025-04-29 09:51:03'),
(8, 29, 100, 'pending', 'Ahmedabad', '1234567891', '', '2025-05-02 09:29:44', '2025-05-02 09:29:44');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `coin_price` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `quantity`, `coin_price`, `created_at`) VALUES
(1, 1, 22, 1, 100, '2025-04-25 09:29:24'),
(2, 2, 22, 1, 100, '2025-04-25 09:40:56'),
(3, 3, 22, 1, 100, '2025-04-25 10:16:29'),
(4, 4, 22, 1, 100, '2025-04-26 20:12:43'),
(5, 5, 17, 1, 200, '2025-04-26 20:15:33'),
(6, 6, 20, 1, 180, '2025-04-29 09:24:01'),
(7, 7, 22, 2, 100, '2025-04-29 09:51:03'),
(8, 8, 22, 1, 100, '2025-05-02 09:29:44');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `coin_price` int(11) NOT NULL,
  `stock_quantity` int(11) NOT NULL DEFAULT 0,
  `image` varchar(255) DEFAULT NULL,
  `is_featured` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `category_id`, `name`, `description`, `coin_price`, `stock_quantity`, `image`, `is_featured`, `created_at`, `updated_at`) VALUES
(17, 1, 'Bamboo Cutlery Set', 'Eco-friendly bamboo cutlery set with carrying case', 200, 49, 'bamboo-cutlery.jpg', 1, '2025-04-24 16:18:55', '2025-04-26 20:15:33'),
(18, 1, 'Recycled Glass Vase', 'Beautiful vase made from recycled glass', 300, 30, 'glass-vase.jpg', 0, '2025-04-24 16:18:55', '2025-04-24 16:18:55'),
(19, 2, 'Reusable Water Bottle', 'Stainless steel water bottle, BPA free', 250, 100, 'water-bottle.jpg', 1, '2025-04-24 16:18:55', '2025-04-24 16:18:55'),
(20, 2, 'Beeswax Food Wraps', 'Reusable food wraps made with organic cotton and beeswax', 180, 74, 'beeswax-wraps.jpg', 0, '2025-04-24 16:18:55', '2025-04-29 09:24:01'),
(21, 3, 'Organic Cotton Tote Bag', 'Durable tote bag made from organic cotton', 150, 200, 'tote-bag.jpg', 1, '2025-04-24 16:18:55', '2025-04-24 16:18:55'),
(22, 3, 'Bamboo Toothbrush', 'Biodegradable toothbrush with bamboo handle', 100, 143, 'bamboo-toothbrush.jpg', 0, '2025-04-24 16:18:55', '2025-05-02 09:29:44'),
(23, 4, 'Solar Power Bank', 'Portable power bank with solar charging capability', 500, 25, 'solar-powerbank.jpg', 1, '2025-04-24 16:18:55', '2025-04-24 16:18:55'),
(24, 4, 'LED Light Bulbs (Pack of 4)', 'Energy-efficient LED light bulbs', 220, 60, 'led-bulbs.jpg', 0, '2025-04-24 16:18:55', '2025-04-24 16:18:55');

-- --------------------------------------------------------

--
-- Table structure for table `product_categories`
--

CREATE TABLE `product_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product_categories`
--

INSERT INTO `product_categories` (`id`, `name`, `description`, `image`, `created_at`) VALUES
(1, 'Eco-Friendly Home', 'Sustainable products for your home', 'eco-home.jpg', '2025-04-24 16:18:55'),
(2, 'Reusable Items', 'Products that replace single-use items', 'reusable.jpg', '2025-04-24 16:18:55'),
(3, 'Organic Products', 'Organic and natural products', 'organic.jpg', '2025-04-24 16:18:55'),
(4, 'Energy Savers', 'Products that help save energy', 'energy.jpg', '2025-04-24 16:18:55');

-- --------------------------------------------------------

--
-- Table structure for table `recycling_activities`
--

CREATE TABLE `recycling_activities` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `quantity` float NOT NULL,
  `coins_earned` int(11) NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `proof_image` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `pickup_date` date DEFAULT NULL,
  `pickup_time_slot` varchar(50) DEFAULT NULL,
  `pickup_address` text DEFAULT NULL,
  `pickup_status` enum('scheduled','completed','cancelled','not_required') DEFAULT 'not_required',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `recycling_activities`
--

INSERT INTO `recycling_activities` (`id`, `user_id`, `category_id`, `quantity`, `coins_earned`, `status`, `proof_image`, `notes`, `pickup_date`, `pickup_time_slot`, `pickup_address`, `pickup_status`, `created_at`, `updated_at`) VALUES
(17, 27, 11, 1, 50, 'approved', '', 'laptop', '2025-04-26', '1:00 PM - 3:00 PM', 'aaja jaha aana ho waha ', 'scheduled', '2025-04-25 08:56:56', '2025-04-25 08:57:27'),
(18, 27, 11, 10, 500, 'approved', '', 'laptop', '2025-04-27', '1:00 PM - 3:00 PM', 'ahmedabad', 'scheduled', '2025-04-25 09:27:36', '2025-04-25 09:27:59'),
(19, 27, 11, 1, 50, 'approved', '', 'Laptop', '2025-04-29', '5:00 PM - 7:00 PM', 'pickup at 6 pm', 'scheduled', '2025-04-26 20:08:51', '2025-04-26 20:14:44'),
(20, 27, 11, 100, 5000, 'approved', '', '', '2025-04-29', '5:00 PM - 7:00 PM', 'ahmedabad', 'scheduled', '2025-04-26 20:13:38', '2025-04-26 20:14:49'),
(21, 29, 11, 2, 100, 'approved', '', 'call', '2025-05-16', '5:00 PM - 7:00 PM', 'Ahmedabad ', 'scheduled', '2025-05-02 09:28:02', '2025-05-02 09:28:52');

-- --------------------------------------------------------

--
-- Table structure for table `recycling_categories`
--

CREATE TABLE `recycling_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `coin_value` int(11) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `recycling_categories`
--

INSERT INTO `recycling_categories` (`id`, `name`, `description`, `coin_value`, `image`, `created_at`) VALUES
(11, 'Electronic Waste', 'Old electronics, batteries, and electronic components', 50, 'e-waste.jpg', '2025-04-24 16:18:55'),
(12, 'Plastic', 'Plastic bottles, containers, and packaging', 10, 'plastic.jpg', '2025-04-24 16:18:55'),
(13, 'Paper', 'Newspapers, magazines, cardboard, and paper packaging', 5, 'paper.jpg', '2025-04-24 16:18:55'),
(14, 'Metal', 'Aluminum cans, scrap metal, and metal containers', 15, 'metal.jpg', '2025-04-24 16:18:55'),
(15, 'Glass', 'Glass bottles and containers', 8, 'glass.jpg', '2025-04-24 16:18:55');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `coin_balance` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `full_name`, `phone`, `address`, `profile_image`, `coin_balance`, `created_at`, `updated_at`) VALUES
(27, 'yuvraj', 'yuvraj@gmail.com', '$2y$10$GFxzhb8fkESoxQeh9oe7VOXBpJDJDjsdl4F4WMfFh8PObh3DpJTsG', 'yuvraj hirvaniya', '1234567891', 'police ground road', '', 4620, '2025-04-25 08:55:50', '2025-04-29 09:51:03'),
(28, 'dax', 'dax@gmail.com', '$2y$10$fq4n1tzpP2lSGQqieL67Rude0/0PQEJPfOoNqNaMjzEq/LZNrU7HS', 'Dax Mistry', '1234567892', 'asdflkjh', '', 0, '2025-04-26 09:58:21', '2025-04-26 09:58:21'),
(29, 'popat', 'popat@gmail.com', '$2y$10$IW3ob0ta23mS4Z6tBywTeefy5.BAO77wZmKkifl3OlHqqTbtYPHhm', 'popat MODHWADIYA', '1234567891', 'porbander', '', 0, '2025-05-02 09:26:35', '2025-05-02 09:29:44');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `coin_transactions`
--
ALTER TABLE `coin_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `product_categories`
--
ALTER TABLE `product_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `recycling_activities`
--
ALTER TABLE `recycling_activities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `recycling_categories`
--
ALTER TABLE `recycling_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `coin_transactions`
--
ALTER TABLE `coin_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `product_categories`
--
ALTER TABLE `product_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `recycling_activities`
--
ALTER TABLE `recycling_activities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `recycling_categories`
--
ALTER TABLE `recycling_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `coin_transactions`
--
ALTER TABLE `coin_transactions`
  ADD CONSTRAINT `coin_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `product_categories` (`id`);

--
-- Constraints for table `recycling_activities`
--
ALTER TABLE `recycling_activities`
  ADD CONSTRAINT `recycling_activities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `recycling_activities_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `recycling_categories` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
