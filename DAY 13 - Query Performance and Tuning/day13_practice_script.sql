-- =====================================================================
-- Day 13 Practice Script: Query Performance & Tuning
-- =====================================================================

CREATE DATABASE IF NOT EXISTS day13_practice;
USE day13_practice;

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;

-- Create Base Tables
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    email VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME,
    amount DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Ingest Sample Data
INSERT INTO Customers (name, email, city) VALUES
('Rahul Sharma', 'rahul@email.com', 'Delhi'),
('Priya Singh',  'priya@email.com', 'Mumbai'),
('Amit Patel',   'amit@email.com',  'Delhi'),
('Sara Khan',    'sara@email.com',   'Chennai');

INSERT INTO Orders (customer_id, order_date, amount, status) VALUES
(1, '2026-01-15 10:30:00', 5000.00, 'Completed'),
(2, '2026-02-20 14:15:00', 1200.00, 'Completed'),
(1, '2026-03-10 11:00:00', 7500.00, 'Pending'),
(3, '2026-04-05 09:45:00', 3200.00, 'Completed'),
(4, '2026-05-12 16:20:00', 900.00,  'Cancelled'),
(2, '2026-06-18 18:00:00', 15000.00,'Completed');


-- ---------------------------------------------------------------------
-- 1. Unoptimized vs Optimized Date Filtering
-- ---------------------------------------------------------------------

-- Unoptimized (Function on column -> type: ALL, Full Table Scan)
EXPLAIN SELECT * FROM Orders WHERE YEAR(order_date) = 2026;

-- Create Index on order_date
CREATE INDEX idx_orders_date ON Orders(order_date);

-- Still Unoptimized (Function prevents index usage):
EXPLAIN SELECT * FROM Orders WHERE YEAR(order_date) = 2026;

-- Optimized (Range condition -> type: range, uses idx_orders_date):
EXPLAIN SELECT * FROM Orders 
WHERE order_date >= '2026-01-01 00:00:00' AND order_date <= '2026-12-31 23:59:59';


-- ---------------------------------------------------------------------
-- 2. Eliminating Using filesort with Composite Index
-- ---------------------------------------------------------------------

-- Query with WHERE + ORDER BY (shows Using filesort in Extra):
EXPLAIN SELECT * FROM Orders WHERE status = 'Completed' ORDER BY amount DESC;

-- Create Composite Index covering status AND amount
CREATE INDEX idx_orders_status_amount ON Orders(status, amount);

-- Re-evaluate (Using filesort eliminated!):
EXPLAIN SELECT * FROM Orders WHERE status = 'Completed' ORDER BY amount DESC;


-- ---------------------------------------------------------------------
-- 3. Achieving Covering Index (Using index)
-- ---------------------------------------------------------------------

-- Query selecting only indexed columns (shows Using index in Extra):
EXPLAIN SELECT status, amount FROM Orders WHERE status = 'Completed';


-- ---------------------------------------------------------------------
-- 4. Microsecond Benchmarking with EXPLAIN ANALYZE
-- ---------------------------------------------------------------------

EXPLAIN ANALYZE 
SELECT c.city, COUNT(*), SUM(o.amount)
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY c.city;
