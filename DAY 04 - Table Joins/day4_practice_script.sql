-- =====================================================================
-- Day 04 Practice Script: Table Joins (Restructured & Enhanced)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Database Setup & Ingestion
-- ---------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS day4_practice;
USE day4_practice;

-- Drop dependent tables first
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS DiscountRules;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Sizes;
DROP TABLE IF EXISTS Colors;

-- Create Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(50),
    city VARCHAR(50)
);

-- Create Products Table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    price DECIMAL(10,2)
);

-- Create Orders Table (Allows NULL customer_id for full outer join testing)
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Create OrderDetails Table
CREATE TABLE OrderDetails (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Create DiscountRules Table
CREATE TABLE DiscountRules (
    discount_level VARCHAR(20),
    min_spend DECIMAL(10,2),
    max_spend DECIMAL(10,2),
    discount_percent INT
);

-- Create Employees Table
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(50),
    role VARCHAR(50),
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES Employees(emp_id)
);

-- Create Sizes & Colors Tables
CREATE TABLE Sizes (
    size VARCHAR(5)
);

CREATE TABLE Colors (
    color VARCHAR(15)
);

-- Populate Tables
INSERT INTO Customers VALUES
(1, 'Alice',   'alice@email.com',   'Delhi'),
(2, 'Bob',     'bob@email.com',     'Mumbai'),
(3, 'Charlie', 'charlie@email.com', 'Delhi'),
(4, 'David',   'david@email.com',   'Chennai'),
(5, 'Eve',     'eve@email.com',     'Hyderabad');

INSERT INTO Products VALUES
(101, 'Laptop',   50000.00),
(102, 'Mobile',   15000.00),
(103, 'Tablet',   12000.00),
(104, 'Earbuds',   2000.00),
(105, 'Smartwatch', 5000.00);

INSERT INTO Orders VALUES
(1001, 1,    '2026-07-20', 52000.00),
(1002, 2,    '2026-07-21', 15000.00),
(1003, 1,    '2026-07-22', 12000.00),
(1004, 4,    '2026-07-23',  2000.00),
(1005, NULL, '2026-07-24',  7000.00); 

INSERT INTO OrderDetails VALUES
(1001, 101, 1),
(1001, 104, 1),
(1002, 102, 1),
(1003, 103, 1),
(1004, 104, 1);

INSERT INTO DiscountRules VALUES
('Bronze',  0.00,    5000.00,   0),
('Silver',  5001.00,  20000.00,  5),
('Gold',    20001.00, 99999.00,  10);

INSERT INTO Employees VALUES
(1, 'Alice', 'CEO', NULL),
(2, 'Bob', 'Manager', 1),
(3, 'Charlie', 'Developer', 2),
(4, 'David', 'Developer', 2);

INSERT INTO Sizes VALUES ('S'), ('M'), ('L');
INSERT INTO Colors VALUES ('Red'), ('Black');


-- ---------------------------------------------------------------------
-- 2. Chapter 2: Inner, Equi, and Non-Equi Joins
-- ---------------------------------------------------------------------

-- A. Standard INNER JOIN (Equi Join)
SELECT c.name, o.order_id
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id;

-- B. Implicit WHERE Join (Old-Style)
SELECT c.name, o.order_id
FROM Customers c, Orders o
WHERE c.customer_id = o.customer_id;

-- C. INNER JOIN using USING clause (matching column names)
SELECT c.name, o.order_id
FROM Customers c
INNER JOIN Orders o USING (customer_id);


-- C. Non-Equi Join (Salary / Spend Grades)
-- Join Orders to DiscountRules based on spending bracket ranges
SELECT o.order_id, o.total_amount, dr.discount_level, dr.discount_percent
FROM Orders o
INNER JOIN DiscountRules dr ON o.total_amount BETWEEN dr.min_spend AND dr.max_spend;


-- ---------------------------------------------------------------------
-- 3. Chapter 3: Outer Joins (Left and Right Join)
-- ---------------------------------------------------------------------

-- A. LEFT JOIN (Preserves all customers, even those with no orders)
SELECT c.name, o.order_id, o.product
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id;

-- B. LEFT JOIN with NULL filter (Finds customers who never placed an order)
SELECT c.name, c.city
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- ---------------------------------------------------------------------
-- 4. Chapter 4: Full Outer and Natural Joins
-- ---------------------------------------------------------------------

-- A. Emulated FULL OUTER JOIN (Combines LEFT and RIGHT join with UNION)
SELECT c.name, o.order_id
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
UNION
SELECT c.name, o.order_id
FROM Customers c
RIGHT JOIN Orders o ON c.customer_id = o.customer_id;

-- B. NATURAL JOIN (Implicit column match)
SELECT c.name, o.order_id
FROM Customers c
NATURAL JOIN Orders o;


-- ---------------------------------------------------------------------
-- 5. Chapter 5: Self and Cross Joins
-- ---------------------------------------------------------------------

-- A. SELF JOIN (Org Hierarchy)
SELECT e.name AS Employee_Name, e.role AS Employee_Role, m.name AS Manager_Name
FROM Employees e
LEFT JOIN Employees m ON e.manager_id = m.emp_id;

-- B. CROSS JOIN (Cartesian Product of sizes & colors)
SELECT s.size, c.color
FROM Sizes s
CROSS JOIN Colors c;

-- C. CROSS JOIN (Cartesian Product of students & subjects)
DROP TABLE IF EXISTS Students_Cross;
CREATE TABLE Students_Cross (
    sname VARCHAR(50)
);
INSERT INTO Students_Cross VALUES ('Rahul'), ('Priya');

DROP TABLE IF EXISTS Subjects_Cross;
CREATE TABLE Subjects_Cross (
    subname VARCHAR(50)
);
INSERT INTO Subjects_Cross VALUES ('Math'), ('Science'), ('English');

SELECT s.sname, sub.subname
FROM Students_Cross s
CROSS JOIN Subjects_Cross sub;


-- ---------------------------------------------------------------------
-- 6. Chapter 6: Join Optimization and Performance
-- ---------------------------------------------------------------------

-- STRAIGHT_JOIN hint (Forces query order: Employees -> Customers)
SELECT /*+ STRAIGHT_JOIN */ e.name, c.city
FROM Employees e
STRAIGHT_JOIN Customers c ON e.emp_id = c.customer_id;


-- ---------------------------------------------------------------------
-- 7. Chapter 7: Hands-on Practice and Exercises
-- ---------------------------------------------------------------------

-- Q1. Retrieve Customer Names and Their Order Dates
SELECT c.name AS customer_name, o.order_id, o.order_date
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id;

-- Q2. List Customer Names and Order Totals Including Those with No Orders
SELECT c.name AS customer_name, COALESCE(o.total_amount, 0) AS total_spent
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id;

-- Q3. Find Customer Names and Product Names Ordered (Multi-Table Join)
SELECT c.name AS customer_name, p.product_name, od.quantity
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN OrderDetails od ON o.order_id = od.order_id
INNER JOIN Products p ON od.product_id = p.product_id;

-- Q6. Pair Customers in the Same City (Self Join)
SELECT c1.name AS customer_1, c2.name AS customer_2, c1.city
FROM Customers c1
INNER JOIN Customers c2 ON c1.city = c2.city AND c1.customer_id < c2.customer_id;


-- ---------------------------------------------------------------------
-- 8. Practice Exercises: Non-Equi Joins
-- ---------------------------------------------------------------------

-- Create practice tables
DROP TABLE IF EXISTS Employees_HR;
CREATE TABLE Employees_HR (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary INT
);

DROP TABLE IF EXISTS Salary_Grades;
CREATE TABLE Salary_Grades (
    grade CHAR(1),
    min_sal INT,
    max_sal INT
);

-- Ingest data
INSERT INTO Employees_HR VALUES
(1, 'John', 5000),
(2, 'Alice', 12000),
(3, 'Bob', 20000),
(4, 'David', 35000);

INSERT INTO Salary_Grades VALUES
('A', 0, 10000),
('B', 10001, 20000),
('C', 20001, 40000);

-- Q1. Find the salary grade of each employee.
SELECT e.emp_name, e.salary, s.grade
FROM Employees_HR e
JOIN Salary_Grades s ON e.salary BETWEEN s.min_sal AND s.max_sal;

-- Q2. List employees who fall under grade 'B'.
SELECT e.emp_name, e.salary
FROM Employees_HR e
JOIN Salary_Grades s ON e.salary BETWEEN s.min_sal AND s.max_sal
WHERE s.grade = 'B';

-- Q3. Show employees whose salary is less than the minimum salary of grade 'B'.
SELECT e.emp_name, e.salary
FROM Employees_HR e
JOIN Salary_Grades s ON e.salary < s.min_sal
WHERE s.grade = 'B';

-- Q4. Find employees whose salary is greater than the maximum salary of grade 'A'.
SELECT e.emp_name, e.salary
FROM Employees_HR e
JOIN Salary_Grades s ON e.salary > s.max_sal
WHERE s.grade = 'A';

-- Q5. Display all grades and the employees in each grade (if any).
SELECT s.grade, e.emp_name, e.salary
FROM Salary_Grades s
LEFT JOIN Employees_HR e ON e.salary BETWEEN s.min_sal AND s.max_sal;

-- Q6. Find employees who are in the highest salary grade.
SELECT e.emp_name, e.salary, s.grade
FROM Employees_HR e
JOIN Salary_Grades s ON e.salary BETWEEN s.min_sal AND s.max_sal
WHERE s.grade = (SELECT MAX(grade) FROM Salary_Grades);


-- ---------------------------------------------------------------------
-- 9. Practice Exercises: Self Joins
-- ---------------------------------------------------------------------

-- Create Org table
DROP TABLE IF EXISTS Employees_Org;
CREATE TABLE Employees_Org (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES Employees_Org(emp_id)
);

-- Ingest Org data
INSERT INTO Employees_Org VALUES
(1, 'John', NULL),
(2, 'Alice', 1),
(3, 'Bob', 1),
(4, 'David', 2),
(5, 'Emma', 2);

-- Q1. Find each employee along with their manager's name.
SELECT e.emp_name AS Employee, m.emp_name AS Manager
FROM Employees_Org e
LEFT JOIN Employees_Org m ON e.manager_id = m.emp_id;

-- Q2. Find employees who report directly to John.
SELECT e.emp_name
FROM Employees_Org e
JOIN Employees_Org m ON e.manager_id = m.emp_id
WHERE m.emp_name = 'John';

-- Q3. List employees who don't have any manager (top-level bosses).
SELECT emp_name
FROM Employees_Org
WHERE manager_id IS NULL;

-- Q4. Find all managers who have at least one employee reporting to them.
SELECT DISTINCT m.emp_name AS Manager
FROM Employees_Org e
JOIN Employees_Org m ON e.manager_id = m.emp_id;

-- Q5. Find employees who share the same manager.
SELECT e1.emp_name AS Employee1, e2.emp_name AS Employee2, m.emp_name AS Manager
FROM Employees_Org e1
JOIN Employees_Org e2 ON e1.manager_id = e2.manager_id AND e1.emp_id < e2.emp_id
JOIN Employees_Org m ON e1.manager_id = m.emp_id;

-- Q6. Show all employees with their manager and manager's manager (grand boss).
SELECT e.emp_name AS Employee,
       m.emp_name AS Manager,
       gm.emp_name AS Grand_Manager
FROM Employees_Org e
LEFT JOIN Employees_Org m ON e.manager_id = m.emp_id
LEFT JOIN Employees_Org gm ON m.manager_id = gm.emp_id;

-- Q7. Find pairs of employees where one is the manager of the other.
SELECT e.emp_name AS Employee, m.emp_name AS Manager
FROM Employees_Org e
JOIN Employees_Org m ON e.manager_id = m.emp_id;

-- Q8. Find employees who are managers but also report to someone else.
SELECT DISTINCT e.emp_name
FROM Employees_Org e
WHERE e.emp_id IN (SELECT DISTINCT manager_id FROM Employees_Org)
  AND e.manager_id IS NOT NULL;

