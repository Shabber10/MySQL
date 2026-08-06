-- =====================================================================
-- Day 14 Capstone Project: ShopSphere Enterprise E-Commerce Database
-- =====================================================================

CREATE DATABASE IF NOT EXISTS shopsphere_db;
USE shopsphere_db;

-- 1. Table Definitions
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS PriceAudit;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category_id INT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE SET NULL
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE DEFAULT (CURRENT_DATE),
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'PENDING',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE OrderItems (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
);

CREATE TABLE PriceAudit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Initial Data Ingestion
INSERT INTO Customers (name, email, city) VALUES
('Rahul Sharma', 'rahul@example.com', 'Hyderabad'),
('Priya Singh', 'priya@example.com', 'Bengaluru'),
('Amit Patel', 'amit@example.com', 'Mumbai');

INSERT INTO Categories (category_name) VALUES
('Electronics'),
('Clothing'),
('Books');

INSERT INTO Products (product_name, category_id, price, stock_quantity) VALUES
('Smartphone X', 1, 25000.00, 30),
('Wireless Earbuds', 1, 3000.00, 50),
('Cotton T-Shirt', 2, 800.00, 100),
('Database Design Book', 3, 1200.00, 40);

-- 3. Audit Trigger Definition
DELIMITER //
CREATE TRIGGER trg_audit_product_price
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO PriceAudit (product_id, old_price, new_price)
        VALUES (OLD.product_id, OLD.price, NEW.price);
    END IF;
END //
DELIMITER ;

-- 4. Order Processing Transaction Stored Procedure
DELIMITER //
CREATE PROCEDURE ProcessOrder(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_order_id INT;

    START TRANSACTION;

    SELECT price, stock_quantity INTO v_price, v_stock
    FROM Products WHERE product_id = p_product_id FOR UPDATE;

    IF v_stock >= p_quantity THEN
        UPDATE Products SET stock_quantity = stock_quantity - p_quantity WHERE product_id = p_product_id;

        INSERT INTO Orders (customer_id, order_date, total_amount, status)
        VALUES (p_customer_id, CURDATE(), v_price * p_quantity, 'COMPLETED');

        SET v_order_id = LAST_INSERT_ID();

        INSERT INTO OrderItems (order_id, product_id, quantity, unit_price)
        VALUES (v_order_id, p_product_id, p_quantity, v_price);

        COMMIT;
        SELECT 'Order Processed Successfully!' AS result;
    ELSE
        ROLLBACK;
        SELECT 'Order Failed: Insufficient Inventory!' AS result;
    END IF;
END //
DELIMITER ;

-- 5. Analytical Views
CREATE VIEW vw_SalesSummary AS
SELECT 
    c.category_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_revenue
FROM Categories c
JOIN Products p ON c.category_id = p.category_id
JOIN Orders o ON p.product_id = o.product_id
GROUP BY c.category_name;

-- 6. Indexing for Search Optimization
CREATE INDEX idx_products_category ON Products(category_id);
CREATE INDEX idx_orders_customer ON Orders(customer_id);

-- Test Procedure
CALL ProcessOrder(1, 1, 2);
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Products WHERE product_id = 1;
