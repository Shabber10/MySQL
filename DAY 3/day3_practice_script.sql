-- =====================================================================
-- Day 3 Practice Script: Aggregations, Grouping, & Scalar Functions
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Table Setup & Data Ingestion
-- ---------------------------------------------------------------------

-- Create and select a practice database
CREATE DATABASE IF NOT EXISTS day3_practice;
USE day3_practice;

-- Drop tables if they already exist
DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS students;

-- Create Sales Table
CREATE TABLE Sales (
    id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    product VARCHAR(50),
    quantity INT,
    price DECIMAL(10,2),
    city VARCHAR(50)
);

-- Insert Sales Data
INSERT INTO Sales VALUES
(1, 'Alice',  'Laptop',   1, 50000.00, 'Delhi'),
(2, 'Bob',    'Mobile',   2, 15000.00, 'Mumbai'),
(3, 'Charlie','Laptop',   1, 52000.00, 'Delhi'),
(4, 'David',  'Tablet',   3, 12000.00, 'Chennai'),
(5, 'Eve',    'Mobile',   1, 15000.00, 'Mumbai'),
(6, 'Frank',  'Laptop',   2, 50000.00, 'Delhi'),
(7, 'Grace',  'Tablet',   1, 12000.00, 'Chennai');

-- Create Students Table
CREATE TABLE students (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    marks INT,
    city VARCHAR(50)
);

-- Insert Students Data
INSERT INTO students VALUES
(1, 'Amit', 18, 85, 'Delhi'),
(2, 'Sara', 19, 72, 'Mumbai'),
(3, 'John', 18, 90, 'Delhi'),
(4, 'Ravi', 20, 60, 'Chennai'),
(5, 'Meena', 21, 50, 'Hyderabad');


-- ---------------------------------------------------------------------
-- 2. Aggregate Functions (COUNT, SUM, AVG, MAX, MIN)
-- ---------------------------------------------------------------------

-- COUNT Examples
SELECT COUNT(*) AS total_sales_records FROM Sales;
SELECT COUNT(marks) AS active_marks_count FROM students;
SELECT COUNT(DISTINCT city) AS unique_sales_cities FROM Sales;

-- SUM, AVG, MAX, MIN Examples
SELECT SUM(quantity) AS total_items_sold FROM Sales;
SELECT AVG(price) AS average_product_price FROM Sales;
SELECT MAX(price) AS highest_price, MIN(price) AS lowest_price FROM Sales;


-- ---------------------------------------------------------------------
-- 3. GROUP BY and ORDER BY Queries
-- ---------------------------------------------------------------------

-- Total sales per product
SELECT product, SUM(price * quantity) AS total_sales
FROM Sales
GROUP BY product;

-- Order count per city
SELECT city, COUNT(*) AS total_orders
FROM Sales
GROUP BY city;

-- Sorting grouped results
SELECT product, SUM(price * quantity) AS total_sales
FROM Sales
GROUP BY product
ORDER BY total_sales DESC;

-- Multi-column grouping
SELECT city, product, SUM(quantity) AS total_qty
FROM Sales
GROUP BY city, product;


-- ---------------------------------------------------------------------
-- 4. HAVING vs WHERE Queries
-- ---------------------------------------------------------------------

-- Filtering grouped results with HAVING
SELECT product, SUM(price * quantity) AS total_sales
FROM Sales
GROUP BY product
HAVING total_sales > 50000;

-- Combining WHERE, GROUP BY, and HAVING
SELECT product, AVG(quantity) AS avg_qty
FROM Sales
WHERE city = 'Delhi'
GROUP BY product
HAVING avg_qty > 1
ORDER BY avg_qty DESC;


-- ---------------------------------------------------------------------
-- 5. Logical Negation (NOT Operators)
-- ---------------------------------------------------------------------

-- NOT Example
SELECT name, city FROM students WHERE NOT city = 'Delhi';

-- NOT IN Example
SELECT name, city FROM students WHERE city NOT IN ('Delhi', 'Mumbai');

-- NOT LIKE Example
SELECT name FROM students WHERE name NOT LIKE 'A%';

-- NOT BETWEEN Example
SELECT name, marks FROM students WHERE marks NOT BETWEEN 60 AND 90;


-- ---------------------------------------------------------------------
-- 6. Math & Scalar Functions
-- ---------------------------------------------------------------------

-- Absolute Value
SELECT ABS(-7200);

-- Integer Division and Modulo
SELECT 105 DIV 10 AS boxes, MOD(105, 10) AS leftover;

-- Rounding vs Truncation
SELECT ROUND(456.789, 2) AS rounded, TRUNCATE(456.789, 2) AS truncated;

-- Ceiling and Floor
SELECT CEIL(499.1) AS rounded_up, FLOOR(499.9) AS rounded_down;

-- Power, Square Root, and Pi
SELECT POW(2, 5) AS power_calc, SQRT(144) AS square_root, PI();

-- Random Sorting Demo
SELECT * FROM Sales ORDER BY RAND() LIMIT 1;


-- ---------------------------------------------------------------------
-- 7. String Functions
-- ---------------------------------------------------------------------

-- Concatenation
SELECT CONCAT('Raju', ' ', 'Sharma') AS full_name;
SELECT CONCAT_WS('-', '2026', '07', '25') AS formatted_date;

-- Case conversion and Lengths
SELECT UPPER('mysql') AS upper_case, LOWER('MYSQL') AS lower_case;
SELECT LENGTH('Cat') AS byte_length, CHAR_LENGTH('Cat') AS char_length;

-- Slicing and Extracting
SELECT SUBSTRING('Database', 1, 4) AS part1, SUBSTRING('Database', 5) AS part2;
SELECT LEFT('Masterclass', 6) AS left_slice, RIGHT('Masterclass', 5) AS right_slice;

-- Find and Replace
SELECT REPLACE('I love SQL Server', 'SQL Server', 'MySQL') AS replaced;
SELECT INSTR('MySQL', 'SQL') AS index_position;
SELECT TRIM('  hello  ') AS trimmed;
