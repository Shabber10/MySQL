-- ====================================================
-- DAY 02: MySQL Hands-On Practice Script
-- Database: company_db
-- ====================================================

-- ----------------------------------------------------
-- 1. DATABASE SETUP
-- ----------------------------------------------------
DROP DATABASE IF EXISTS company_db;
CREATE DATABASE company_db;
USE company_db;


-- ----------------------------------------------------
-- 2. CREATE TABLE
-- ----------------------------------------------------
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    email VARCHAR(100),
    join_date DATE
);

DESCRIBE employees;


-- ----------------------------------------------------
-- 3. POPULATE DATA
-- ----------------------------------------------------
INSERT INTO employees (first_name, last_name, department, salary, email, join_date)
VALUES 
('Alice', 'Smith', 'IT', 75000.00, 'alice.smith@company.com', '2024-03-15'),
('Bob', 'Jones', 'HR', 55000.00, NULL, '2023-08-20'),
('Charles', 'Miller', 'IT', 90000.00, 'charles.m@company.com', '2022-11-10'),
('David', 'Davis', 'Sales', 62000.00, 'david.d@company.com', '2025-01-05'),
('Emma', 'Wilson', 'Marketing', 48000.00, 'emma.w@company.com', '2025-06-01'),
('Frank', 'Taylor', 'Sales', 52000.00, NULL, '2024-05-18'),
('Grace', 'Thomas', 'IT', 68000.00, 'grace.t@company.com', '2025-02-28'),
('Henry', 'White', 'Finance', 85000.00, 'henry.w@company.com', '2023-01-14');

SELECT * FROM employees;


-- ----------------------------------------------------
-- 4. LOGICAL COMBINATIONS AND COMPARISONS
-- ----------------------------------------------------
SELECT first_name, department, salary 
FROM employees
WHERE (department = 'IT' OR department = 'Sales') AND salary > 60000.00;

SELECT first_name, department, salary 
FROM employees
WHERE NOT department = 'Sales';


-- ----------------------------------------------------
-- 5. RANGE (BETWEEN) & SET (IN) SEARCHES
-- ----------------------------------------------------
SELECT first_name, salary 
FROM employees
WHERE salary BETWEEN 50000.00 AND 80000.00;

SELECT first_name, department 
FROM employees
WHERE department IN ('IT', 'HR', 'Marketing');


-- ----------------------------------------------------
-- 6. TEXT PATTERNS (LIKE & REGEXP)
-- ----------------------------------------------------
SELECT first_name, last_name FROM employees WHERE first_name LIKE 'A%';
SELECT first_name, last_name FROM employees WHERE last_name LIKE '_i%';

-- REGEXP / RLIKE Pattern Matching
SELECT first_name FROM employees WHERE first_name REGEXP '^[ABC]';
SELECT first_name, email FROM employees WHERE email REGEXP 'company\.com$';


-- ----------------------------------------------------
-- 7. NULL CHECKING & NULL-SAFE EQUAL (<=>)
-- ----------------------------------------------------
SELECT first_name, last_name, email FROM employees WHERE email IS NULL;
SELECT first_name, last_name, email FROM employees WHERE email IS NOT NULL;
SELECT first_name, ISNULL(email) AS is_missing FROM employees;

-- NULL-Safe Equal Operator (<=>)
SELECT first_name, email FROM employees WHERE email <=> NULL;


-- ----------------------------------------------------
-- 8. SORTING & PAGINATION (ORDER BY & LIMIT OFFSET)
-- ----------------------------------------------------
SELECT first_name, department, salary 
FROM employees
ORDER BY salary DESC
LIMIT 3;

-- Pagination (Limit with Offset)
SELECT first_name, salary FROM employees ORDER BY employee_id LIMIT 3 OFFSET 0; -- Page 1
SELECT first_name, salary FROM employees ORDER BY employee_id LIMIT 3 OFFSET 3; -- Page 2


-- ----------------------------------------------------
-- 9. ARITHMETIC, BITWISE & ASSIGNMENT OPERATORS
-- ----------------------------------------------------
-- Arithmetic calculations
SELECT first_name, salary, (salary * 0.10) AS bonus, (salary % 3) AS remainder FROM employees;

-- Bitwise operations (Low-level)
SELECT 5 & 3 AS bit_and, 5 | 3 AS bit_or, 5 ^ 3 AS bit_xor, 5 << 1 AS left_shift;

-- Session Variables Assignment
SET @target_dept = 'IT';
SELECT * FROM employees WHERE department = @target_dept;


-- ----------------------------------------------------
-- 10. STUDENTS PRACTICE TABLE
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS students (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    marks INT,
    city VARCHAR(50)
);

TRUNCATE TABLE students;

INSERT INTO students VALUES
(1, 'Amit', 18, 85, 'Delhi'),
(2, 'Sara', 19, 72, 'Mumbai'),
(3, 'John', 18, 90, 'Delhi'),
(4, 'Ravi', 20, 60, 'Chennai'),
(5, 'Meena', 21, 50, 'Hyderabad');

SELECT name, city FROM students WHERE NOT city = 'Delhi';
SELECT name, city FROM students WHERE city NOT IN ('Delhi', 'Mumbai');
SELECT name FROM students WHERE name NOT LIKE 'A%';
SELECT name, marks FROM students WHERE marks NOT BETWEEN 60 AND 90;
