-- =====================================================================
-- Day 14 Capstone Project: ShopSphere E-Commerce System
-- Complete Production Database Schema & Verification Script
-- =====================================================================

CREATE DATABASE IF NOT EXISTS shopsphere_db;
USE shopsphere_db;

-- Drop existing objects
DROP VIEW IF EXISTS v_out_of_stock_products;
DROP VIEW IF EXISTS v_customer_revenue_ranking;
DROP PROCEDURE IF EXISTS PlaceOrder;
DROP TRIGGER IF EXISTS after_order_item_inserted;

DROP TABLE IF EXISTS PAYMENTS;
DROP TABLE IF EXISTS ORDER_ITEMS;
DROP TABLE IF EXISTS ORDERS;
DROP TABLE IF EXISTS PRODUCTS;
DROP TABLE IF EXISTS CATEGORIES;
DROP TABLE IF EXISTS USERS;
DROP TABLE IF EXISTS AUDIT_LOG;


-- ---------------------------------------------------------------------
-- 1. Table Definitions (Normalized 3NF)
-- ---------------------------------------------------------------------

CREATE TABLE USERS (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE CATEGORIES (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE PRODUCTS (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    FOREIGN KEY (category_id) REFERENCES CATEGORIES(category_id) ON DELETE RESTRICT
);

CREATE TABLE ORDERS (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR(30) DEFAULT 'Pending',
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE
);

CREATE TABLE ORDER_ITEMS (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id) ON DELETE CASCADE
);

CREATE TABLE PAYMENTS (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(30) DEFAULT 'Success',
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES ORDERS(order_id) ON DELETE CASCADE
);

CREATE TABLE AUDIT_LOG (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    log_message VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ---------------------------------------------------------------------
-- 2. Indexes for Query Performance
-- ---------------------------------------------------------------------

CREATE INDEX idx_orders_user ON ORDERS(user_id);
CREATE INDEX idx_order_items_product ON ORDER_ITEMS(product_id);
CREATE INDEX idx_products_category ON PRODUCTS(category_id);
CREATE INDEX idx_orders_date ON ORDERS(order_date);


-- ---------------------------------------------------------------------
-- 3. Seed Data Ingestion
-- ---------------------------------------------------------------------

INSERT INTO USERS (full_name, email, city) VALUES
('Rahul Sharma', 'rahul@email.com', 'Delhi'),
('Priya Singh',  'priya@email.com', 'Mumbai'),
('Amit Patel',   'amit@email.com',  'Delhi'),
('Sara Khan',    'sara@email.com',   'Chennai'),
('John Doe',     'john@email.com',   'Bangalore');

INSERT INTO CATEGORIES (category_name) VALUES
('Electronics'),
('Apparel'),
('Home Appliances');

INSERT INTO PRODUCTS (category_id, product_name, price, stock_quantity) VALUES
(1, 'Laptop Pro 15', 75000.00, 15),
(1, 'Wireless Earbuds', 3000.00, 50),
(1, 'Smartphone 5G', 25000.00, 30),
(2, 'Cotton T-Shirt',    800.00, 100),
(3, 'Coffee Maker',     4500.00,  0);


-- ---------------------------------------------------------------------
-- 4. Automation Trigger: Auto Stock Reduction & Audit Log
-- ---------------------------------------------------------------------

DELIMITER //

CREATE TRIGGER after_order_item_inserted
AFTER INSERT ON ORDER_ITEMS
FOR EACH ROW
BEGIN
    -- Deduct stock count in PRODUCTS
    UPDATE PRODUCTS
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;

    -- Write record to AUDIT_LOG
    INSERT INTO AUDIT_LOG (log_message)
    VALUES (CONCAT('Stock deducted for Product #', NEW.product_id, ' (Qty: ', NEW.quantity, ') for Order #', NEW.order_id));
END //

DELIMITER ;


-- ---------------------------------------------------------------------
-- 5. Stored Procedure: PlaceOrder (ACID Compliant)
-- ---------------------------------------------------------------------

DELIMITER //

CREATE PROCEDURE PlaceOrder(
    IN p_user_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_order_id INT,
    OUT p_status VARCHAR(100)
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_total DECIMAL(10,2);

    -- Exit Handler for SQL Exception (Automatic Rollback)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_order_id = NULL;
        SET p_status = 'ERROR: Order processing failed. Transaction rolled back.';
    END;

    START TRANSACTION;

    -- Check product availability and price
    SELECT price, stock_quantity INTO v_price, v_stock
    FROM PRODUCTS
    WHERE product_id = p_product_id;

    -- Validate stock quantity
    IF v_stock < p_quantity THEN
        ROLLBACK;
        SET p_order_id = NULL;
        SET p_status = 'ERROR: Insufficient stock available.';
    ELSE
        -- Calculate total
        SET v_total = v_price * p_quantity;

        -- Insert master order
        INSERT INTO ORDERS (user_id, order_status, total_amount)
        VALUES (p_user_id, 'Completed', v_total);

        SET p_order_id = LAST_INSERT_ID();

        -- Insert line item (triggers stock reduction)
        INSERT INTO ORDER_ITEMS (order_id, product_id, quantity, unit_price)
        VALUES (p_order_id, p_product_id, p_quantity, v_price);

        -- Insert payment
        INSERT INTO PAYMENTS (order_id, payment_method, payment_status, amount_paid)
        VALUES (p_order_id, 'Credit Card', 'Success', v_total);

        COMMIT;
        SET p_status = 'SUCCESS: Order placed successfully.';
    END IF;
END //

DELIMITER ;


-- ---------------------------------------------------------------------
-- 6. Analytical Views
-- ---------------------------------------------------------------------

CREATE VIEW v_customer_revenue_ranking AS
SELECT 
    u.user_id,
    u.full_name,
    u.city,
    COUNT(DISTINCT o.order_id) AS total_orders_placed,
    IFNULL(SUM(o.total_amount), 0) AS lifetime_spend,
    DENSE_RANK() OVER (ORDER BY IFNULL(SUM(o.total_amount), 0) DESC) AS revenue_rank
FROM USERS u
LEFT JOIN ORDERS o ON u.user_id = o.user_id
GROUP BY u.user_id, u.full_name, u.city;

CREATE VIEW v_out_of_stock_products AS
SELECT p.product_id, p.product_name, c.category_name, p.price
FROM PRODUCTS p
JOIN CATEGORIES c ON p.category_id = c.category_id
WHERE p.stock_quantity = 0;


-- ---------------------------------------------------------------------
-- 7. Verification & End-to-End Execution
-- ---------------------------------------------------------------------

-- Test Case 1: Rahul (User 1) places order for 2 Laptops (Product 1)
CALL PlaceOrder(1, 1, 2, @ord1, @stat1);
SELECT @ord1 AS order_id_1, @stat1 AS status_1;

-- Test Case 2: Priya (User 2) places order for 1 Smartphone (Product 3)
CALL PlaceOrder(2, 3, 1, @ord2, @stat2);
SELECT @ord2 AS order_id_2, @stat2 AS status_2;

-- Test Case 3: Insufficient Stock Test (Attempt 99 Coffee Makers -> Should Fail)
CALL PlaceOrder(3, 5, 99, @ord3, @stat3);
SELECT @ord3 AS order_id_3, @stat3 AS status_3;

-- Verify Updated Laptop Stock (15 -> 13)
SELECT product_id, product_name, stock_quantity FROM PRODUCTS WHERE product_id = 1;

-- Verify Audit Log entries
SELECT * FROM AUDIT_LOG;

-- Verify Customer Revenue Rankings
SELECT * FROM v_customer_revenue_ranking;

-- Verify Out of Stock View (Coffee Maker should appear)
SELECT * FROM v_out_of_stock_products;

-- Verify Query Execution Plan
EXPLAIN SELECT * FROM ORDERS WHERE user_id = 1;
