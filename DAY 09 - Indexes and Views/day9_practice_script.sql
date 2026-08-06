-- =====================================================================
-- Day 09 Practice Script: Views (Creating, Querying, & Check Options)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Database Setup
-- ---------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS day9_practice;
USE day9_practice;

DROP VIEW IF EXISTS v_customer_sales;
DROP VIEW IF EXISTS v_delhi_customers;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;

-- Create Base Tables
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product VARCHAR(50),
    amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Populate Tables
INSERT INTO Customers VALUES
(1, 'Rahul', 'rahul@email.com', 'Delhi'),
(2, 'Priya', 'priya@email.com', 'Mumbai'),
(3, 'Amit', 'amit@email.com', 'Delhi');

INSERT INTO Orders VALUES
(101, 1, 'Laptop', 55000.00),
(102, 2, 'Mobile', 15000.00),
(103, 1, 'Earbuds', 3000.00);


-- ---------------------------------------------------------------------
-- 2. Creating Views (Task 1 & Task 2)
-- ---------------------------------------------------------------------

-- A. Secure Filtering View (Simple View with Check Option)
CREATE VIEW v_delhi_customers AS
SELECT customer_id, name, city
FROM Customers
WHERE city = 'Delhi'
WITH CHECK OPTION;

-- B. Complex Join View (Read-Only View)
CREATE VIEW v_customer_sales AS
SELECT c.name AS customer_name, o.product, o.amount
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id;


-- ---------------------------------------------------------------------
-- 3. Querying & Updating Views (Task 3)
-- ---------------------------------------------------------------------

-- Query Views
SELECT * FROM v_delhi_customers;
SELECT * FROM v_customer_sales;

-- Task 3a: Update customer name through simple view
UPDATE v_delhi_customers
SET name = 'Rahul Sharma'
WHERE customer_id = 1;

-- Verify change propagated to underlying Customers table
SELECT * FROM Customers;

-- Task 3b: Insert valid Delhi record through view
INSERT INTO v_delhi_customers (customer_id, name, city)
VALUES (4, 'Sanjay', 'Delhi');

-- Verify change is in Customers table
SELECT * FROM Customers;

-- Task 3c: Attempt to insert invalid Mumbai record through view
-- This should FAIL due to WITH CHECK OPTION:
-- INSERT INTO v_delhi_customers (customer_id, name, city) VALUES (5, 'Karan', 'Mumbai');


-- ---------------------------------------------------------------------
-- 4. Altering and Dropping Views
-- ---------------------------------------------------------------------

-- Replace view to include email
CREATE OR REPLACE VIEW v_delhi_customers AS
SELECT customer_id, name, email, city
FROM Customers
WHERE city = 'Delhi'
WITH CHECK OPTION;

-- Inspect active views in the database:
SHOW FULL TABLES WHERE Table_type = 'VIEW';


-- ---------------------------------------------------------------------
-- 5. Creating and Inspecting B-Tree Indexes
-- ---------------------------------------------------------------------

-- Create a Single-column Index on City
CREATE INDEX idx_customers_city ON Customers(city);

-- Create a Composite Index on Name and Email
CREATE INDEX idx_customers_name_email ON Customers(name, email);

-- Inspect active indexes on Customers table
SHOW INDEX FROM Customers;

-- Inspect query execution plan using EXPLAIN
EXPLAIN SELECT * FROM Customers WHERE city = 'Delhi';

-- Clean up Indexes and Views
DROP INDEX idx_customers_city ON Customers;
DROP INDEX idx_customers_name_email ON Customers;
DROP VIEW IF EXISTS v_delhi_customers;
DROP VIEW IF EXISTS v_customer_sales;

