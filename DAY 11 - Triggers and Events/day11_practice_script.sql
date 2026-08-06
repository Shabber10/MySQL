-- =====================================================================
-- Day 11 Practice Script: Triggers & Events
-- =====================================================================

CREATE DATABASE IF NOT EXISTS day11_practice;
USE day11_practice;

-- 1. Setup Tables
DROP TABLE IF EXISTS Products;
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT
);

INSERT INTO Products (product_name, price, stock_quantity) VALUES
('Laptop', 50000.00, 10),
('Smartphone', 20000.00, 25),
('Headphones', 2500.00, 50);

DROP TABLE IF EXISTS PriceAudit;
CREATE TABLE PriceAudit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Create AFTER UPDATE Trigger for Price Auditing
DROP TRIGGER IF EXISTS trg_price_change;

DELIMITER //
CREATE TRIGGER trg_price_change
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO PriceAudit (product_id, old_price, new_price)
        VALUES (OLD.product_id, OLD.price, NEW.price);
    END IF;
END //
DELIMITER ;

-- Test Trigger
UPDATE Products SET price = 48000.00 WHERE product_id = 1;
SELECT * FROM PriceAudit;

-- 3. Enable Event Scheduler & Create Recurring Event
SET GLOBAL event_scheduler = ON;

DROP TABLE IF EXISTS LowStockAlerts;
CREATE TABLE LowStockAlerts (
    alert_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    product_name VARCHAR(50),
    stock INT,
    alert_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP EVENT IF EXISTS evt_check_low_stock;

DELIMITER //
CREATE EVENT evt_check_low_stock
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    INSERT INTO LowStockAlerts (product_id, product_name, stock)
    SELECT product_id, product_name, stock_quantity
    FROM Products
    WHERE stock_quantity < 15;
END //
DELIMITER ;

SHOW TRIGGERS;
SHOW EVENTS;
