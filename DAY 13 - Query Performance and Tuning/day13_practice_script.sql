-- =====================================================================
-- Day 13 Practice Script: Query Performance and Tuning
-- =====================================================================

CREATE DATABASE IF NOT EXISTS day13_practice;
USE day13_practice;

-- 1. Setup Table
DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_email VARCHAR(100),
    order_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(20)
);

INSERT INTO Orders (customer_email, order_date, total_amount, status) VALUES
('alice@example.com', '2026-01-10', 150.00, 'COMPLETED'),
('bob@example.com', '2026-02-15', 300.00, 'PENDING'),
('charlie@example.com', '2026-03-20', 450.00, 'COMPLETED'),
('david@example.com', '2026-04-05', 120.00, 'CANCELLED'),
('eve@example.com', '2026-05-12', 600.00, 'COMPLETED');

-- 2. Query Profiling
SET profiling = 1;

SELECT * FROM Orders WHERE customer_email = 'alice@example.com';
SELECT COUNT(*) FROM Orders WHERE total_amount > 200;

SHOW PROFILES;

-- 3. EXPLAIN Analysis Before Indexing
EXPLAIN SELECT * FROM Orders WHERE customer_email = 'alice@example.com';

-- 4. Create Index & EXPLAIN Analysis After Indexing
CREATE INDEX idx_customer_email ON Orders(customer_email);

EXPLAIN SELECT * FROM Orders WHERE customer_email = 'alice@example.com';
