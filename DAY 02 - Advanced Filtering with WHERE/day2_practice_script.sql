-- ====================================================
-- DAY 02: MySQL Hands-On Practice Script
-- Database: company_db
-- ====================================================

-- ----------------------------------------------------
-- 1. DATABASE SETUP
-- ----------------------------------------------------
-- Drop database if it already exists to start fresh
DROP DATABASE IF EXISTS company_db;

-- Create database
CREATE DATABASE company_db;

-- Select database to use
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

-- Inspect table structure
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

-- Verify inserted data
SELECT * FROM employees;


-- ----------------------------------------------------
-- 4. LOGICAL COMBINATIONS AND COMPARISONS
-- ----------------------------------------------------

-- Find IT or Sales employees who earn more than $60,000
SELECT first_name, department, salary 
FROM employees
WHERE (department = 'IT' OR department = 'Sales') AND salary > 60000.00;

-- Exclude Sales employees using NOT
SELECT first_name, department, salary 
FROM employees
WHERE NOT department = 'Sales';


-- ----------------------------------------------------
-- 5. RANGE (BETWEEN) & SET (IN) SEARCHES
-- ----------------------------------------------------

-- Find employees making between $50,000 and $80,000
SELECT first_name, salary 
FROM employees
WHERE salary BETWEEN 50000.00 AND 80000.00;

-- Find employees working in IT, HR, or Marketing
SELECT first_name, department 
FROM employees
WHERE department IN ('IT', 'HR', 'Marketing');


-- ----------------------------------------------------
-- 6. TEXT PATTERNS (LIKE & WILDCARDS)
-- ----------------------------------------------------

-- Names starting with 'A'
SELECT first_name, last_name 
FROM employees
WHERE first_name LIKE 'A%';

-- Names with 'i' as the second letter of their last name
SELECT first_name, last_name 
FROM employees
WHERE last_name LIKE '_i%';


-- ----------------------------------------------------
-- 7. NULL CHECKING
-- ----------------------------------------------------

-- Find employees missing email addresses
SELECT first_name, last_name, email 
FROM employees
WHERE email IS NULL;

-- Find employees who DO have email addresses
SELECT first_name, last_name, email 
FROM employees
WHERE email IS NOT NULL;


-- ----------------------------------------------------
-- 8. SORTING & RESTRICTING RESULTS (ORDER BY & LIMIT)
-- ----------------------------------------------------

-- Get top 3 highest paid employees
SELECT first_name, department, salary 
FROM employees
ORDER BY salary DESC
LIMIT 3;

-- Find the oldest employee (hired earliest)
SELECT first_name, join_date 
FROM employees
ORDER BY join_date ASC
LIMIT 1;


-- ----------------------------------------------------
-- 9. LOGICAL NEGATION SCENARIO (students TABLE)
-- ----------------------------------------------------
CREATE TABLE IF NOT EXISTS students (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    marks INT,
    city VARCHAR(50)
);

-- Clean up any old data
TRUNCATE TABLE students;

INSERT INTO students VALUES
(1, 'Amit', 18, 85, 'Delhi'),
(2, 'Sara', 19, 72, 'Mumbai'),
(3, 'John', 18, 90, 'Delhi'),
(4, 'Ravi', 20, 60, 'Chennai'),
(5, 'Meena', 21, 50, 'Hyderabad');

-- Q1. Display students who are NOT from Delhi
SELECT name, city FROM students WHERE NOT city = 'Delhi';

-- Q2. Display students who are NOT IN Delhi and Mumbai
SELECT name, city FROM students WHERE city NOT IN ('Delhi', 'Mumbai');

-- Q3. Display students whose names DO NOT start with 'A'
SELECT name FROM students WHERE name NOT LIKE 'A%';

-- Q4. Display students whose names DO NOT end with 'a'
SELECT name FROM students WHERE name NOT LIKE '%a';

-- Q5. Display students whose marks are NOT greater than 70
SELECT name, marks FROM students WHERE NOT marks > 70;

-- Q6. Display students whose marks are NOT BETWEEN 60 and 90
SELECT name, marks FROM students WHERE marks NOT BETWEEN 60 AND 90;

-- Q7. Display students whose age is NOT between 18 and 20
SELECT name, age FROM students WHERE age NOT BETWEEN 18 AND 20;

-- Q8. Display students who are NOT from Chennai AND NOT from Delhi
SELECT name, city FROM students WHERE city NOT IN ('Chennai', 'Delhi');

-- Q9. Display students whose names do not contain the letter 'o'
SELECT name FROM students WHERE name NOT LIKE '%o%';

-- Q10. Display students who are NOT from Delhi AND marks NOT above 80
SELECT name, marks, city
FROM students
WHERE NOT city = 'Delhi' AND NOT marks > 80;
