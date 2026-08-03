-- =====================================================================
-- Day 03 Practice Script: Aggregations, Grouping, & Scalar Functions
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
-- 7. String Functions (Extended)
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
SELECT INSTR('MySQL', 'SQL') AS index_position_instr;
SELECT LOCATE('SQL', 'MySQL Database') AS index_position_locate;
SELECT TRIM('  hello  ') AS trimmed, LTRIM('  hi') AS ltrimmed, RTRIM('bye  ') AS rtrimmed;

-- Extended String Functions
SELECT ASCII('A') AS ascii_val, ORD('A') AS ord_val;
SELECT FORMAT(12345.6789, 2) AS formatted_num;
SELECT REPEAT('SQL', 3) AS repeated_str, REVERSE('MySQL') AS reversed_str;
SELECT CONCAT('My', SPACE(3), 'SQL') AS spaced_str;
SELECT INSERT('Database', 2, 3, 'XX') AS inserted_str;


-- ---------------------------------------------------------------------
-- 8. System Information Functions
-- ---------------------------------------------------------------------
SELECT DATABASE() AS current_db;
SELECT USER() AS current_user;
SELECT VERSION() AS mysql_version;


-- ---------------------------------------------------------------------
-- 9. Advanced & Conditional Control Flow Functions
-- ---------------------------------------------------------------------

-- CASE WHEN Demo 1 (Sales)
SELECT id, customer_name, price,
   CASE 
     WHEN price > 50000 THEN 'High Price'
     WHEN price > 15000 THEN 'Medium Price'
     ELSE 'Low Price'
   END AS price_level
FROM Sales;

-- CASE WHEN Demo 2 (Products Table from user notes)
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    pname VARCHAR(50),
    pprice DECIMAL(10,2)
);
INSERT INTO products VALUES 
('mobile', 10000.90),
('watch', 12001.00),
('buds', NULL),
('bike', 78787.99),
('bike', 78787.99),
('bike', NULL);

SELECT pname, pprice,
   CASE 
     WHEN pprice > 50000 THEN 'high' 
     WHEN pprice > 11000 THEN 'medium' 
     ELSE 'low' 
   END AS level_salaries 
FROM products;

-- IF Ternary Demo
SELECT IF(10 > 5, 'Yes', 'No') AS ternary_if;

-- IFNULL and ISNULL Demo
SELECT IFNULL(NULL, 'Default Value') AS if_null_demo;
SELECT ISNULL(NULL) AS is_null_true, ISNULL('abc') AS is_null_false;

-- COALESCE Demo
SELECT COALESCE(NULL, NULL, 'First Non-Null', 'Fallback') AS coalesce_demo;

-- NULLIF Demo
SELECT NULLIF(10, 10) AS equal_null, NULLIF(10, 20) AS unequal_first;

-- CAST Demo
SELECT CAST('123' AS UNSIGNED) AS cast_unsigned;

-- BIN and BINARY Demo
SELECT BIN(10) AS binary_string;
SELECT 'abc' = BINARY 'ABC' AS case_sensitive_match, 'abc' = 'ABC' AS default_match;


-- ---------------------------------------------------------------------
-- 10. String and Advanced Functions Exercises (Q1 - Q20)
-- ---------------------------------------------------------------------

-- Q1. display 'hello world' in uppercase.
SELECT UPPER('hello world') AS Q1_result;

-- Q2. convert 'MYSQL Functions' into lowercase.
SELECT LOWER('MYSQL Functions') AS Q2_result;

-- Q3. find length of 'Database'.
SELECT LENGTH('Database') AS Q3_result;

-- Q4. find character length of 'My SQL'.
SELECT CHAR_LENGTH('My SQL') AS Q4_result;

-- Q5. Concatenate 'My' and 'SQL'.
SELECT CONCAT('My', 'SQL') AS Q5_result;

-- Q6. Combine 'John' and 'Doe' with a space.
SELECT CONCAT('John', ' ', 'Doe') AS Q6_full_name;

-- Q7. Extract first 4 characters from 'Database'.
SELECT SUBSTRING('Database', 1, 4) AS Q7_result;

-- Q8. Extract characters from position 3 to 6 from 'Functions'.
SELECT SUBSTRING('Functions', 3, 4) AS Q8_result;

-- Q9. Remove spaces from both sides of ' SQL '.
SELECT TRIM(' SQL ') AS Q9_result;

-- Q10. Remove only left-side spaces from ' MySQL'.
SELECT LTRIM(' MySQL') AS Q10_result;

-- Q11. Remove only right-side spaces from 'Hello '.
SELECT RTRIM('Hello ') AS Q11_result;

-- Q12. Replace 'Java' with 'SQL' in 'I like Java'.
SELECT REPLACE('I like Java', 'Java', 'SQL') AS Q12_result;

-- Q13. Change 'Good Morning' into 'Good Evening'.
SELECT REPLACE('Good Morning', 'Morning', 'Evening') AS Q13_result;

-- Q14. Insert 'XX' into 'Database' starting from position 2, replacing 3 characters.
SELECT INSERT('Database', 2, 3, 'XX') AS Q14_result;

-- Q15. Replace 2 characters from position 4 in 'Learning' with 'SQL'.
SELECT INSERT('Learning', 4, 2, 'SQL') AS Q15_result;

-- Q16. Reverse the string 'MySQL'.
SELECT REVERSE('MySQL') AS Q16_result;

-- Q17. Repeat the string 'Raju' 3 times.
SELECT REPEAT('Raju', 3) AS Q17_result;

-- Q18. Find position of 'SQL' in 'I am learning SQL'.
SELECT LOCATE('SQL', 'I am learning SQL') AS Q18_result;

-- Q19. Find position of 'a' in 'Database'.
SELECT INSTR('Database', 'a') AS Q19_result;

-- Q20. Force case-sensitive comparison of 'abc' and 'ABC'.
SELECT 'abc' = BINARY 'ABC' AS Q20_match;

