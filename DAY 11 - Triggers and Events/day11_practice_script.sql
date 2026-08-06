-- =====================================================================
-- Day 11 Practice Script: Triggers & Events
-- =====================================================================

CREATE DATABASE IF NOT EXISTS day11_practice;
USE day11_practice;

-- Drop existing objects
DROP EVENT IF EXISTS e_hourly_sales_summary;
DROP TRIGGER IF EXISTS after_order_inserted;
DROP TRIGGER IF EXISTS before_order_stock_check;
DROP TABLE IF EXISTS AuditLog;
DROP TABLE IF EXISTS HourlySalesSummary;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;

-- Create Base Tables
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(50),
    product_id INT,
    quantity INT,
    amount DECIMAL(10,2),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE AuditLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    log_message VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE HourlySalesSummary (
    summary_id INT PRIMARY KEY AUTO_INCREMENT,
    summary_hour TIMESTAMP,
    total_sales DECIMAL(10,2),
    total_orders INT
);

-- Ingest Sample Data
INSERT INTO Products VALUES
(101, 'Laptop', 50000.00, 10),
(102, 'Mobile', 15000.00, 20),
(103, 'Tablet', 12000.00, 5);


-- ---------------------------------------------------------------------
-- 1. BEFORE INSERT Trigger: Stock Validation & Signal Error
-- ---------------------------------------------------------------------
DELIMITER //

CREATE TRIGGER before_order_stock_check
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;
    
    SELECT stock_quantity INTO current_stock
    FROM Products
    WHERE product_id = NEW.product_id;
    
    IF current_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Cannot place order. Insufficient product stock!';
    END IF;
END //

DELIMITER ;


-- ---------------------------------------------------------------------
-- 2. AFTER INSERT Trigger: Inventory Auto-Deduction & Audit Logging
-- ---------------------------------------------------------------------
DELIMITER //

CREATE TRIGGER after_order_inserted
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    -- Deduct stock count from Products
    UPDATE Products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    
    -- Insert Audit Log entry
    INSERT INTO AuditLog (log_message)
    VALUES (CONCAT('Order #', NEW.order_id, ' created for Customer: ', NEW.customer_name, ' (Qty: ', NEW.quantity, ')'));
END //

DELIMITER ;


-- ---------------------------------------------------------------------
-- 3. Testing Triggers
-- ---------------------------------------------------------------------

-- Test Valid Order (Order 2 laptops for Rahul):
INSERT INTO Orders (customer_name, product_id, quantity, amount) 
VALUES ('Rahul Sharma', 101, 2, 100000.00);

-- Verify Products stock updated (Laptop stock should be 8):
SELECT * FROM Products WHERE product_id = 101;

-- Verify Audit Log entry:
SELECT * FROM AuditLog;

-- Test Invalid Order (Order 999 laptops -> should FAIL with custom error):
-- INSERT INTO Orders (customer_name, product_id, quantity, amount) VALUES ('Error User', 101, 999, 50000000.00);


-- ---------------------------------------------------------------------
-- 4. Scheduled Event Setup
-- ---------------------------------------------------------------------

-- Enable Global Event Scheduler
SET GLOBAL event_scheduler = ON;

-- Create Scheduled Event (Runs every 1 hour)
DELIMITER //

CREATE EVENT e_hourly_sales_summary
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    INSERT INTO HourlySalesSummary (summary_hour, total_sales, total_orders)
    SELECT 
        NOW(),
        IFNULL(SUM(amount), 0),
        COUNT(*)
    FROM Orders;
END //

DELIMITER ;

-- Inspect active events
SHOW EVENTS FROM day11_practice;
