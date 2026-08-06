-- =====================================================================
-- Day 05 Practice Script: Subqueries, Set Operators, & CTEs
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Database Setup & Ingestion
-- ---------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS day5_practice;
USE day5_practice;

-- Drop tables in correct order
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Suppliers;

-- Create Employees Table
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary INT,
    dept VARCHAR(50)
);

-- Populate Employees Table
INSERT INTO Employees VALUES
(1, 'John', 5000, 'HR'),
(2, 'Alice', 12000, 'IT'),
(3, 'Bob', 20000, 'IT'),
(4, 'David', 35000, 'Finance'),
(5, 'Emma', 25000, 'Finance'),
(6, 'Raj', 15000, 'HR');

-- Create Customers Table
CREATE TABLE Customers (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50)
);

-- Populate Customers Table
INSERT INTO Customers VALUES
(1, 'John', 'London'),
(2, 'Alice', 'Paris'),
(3, 'Raj', 'Delhi'),
(4, 'Sara', 'Mumbai');

-- Create Suppliers Table
CREATE TABLE Suppliers (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50)
);

-- Populate Suppliers Table
INSERT INTO Suppliers VALUES
(2, 'Supplier1', 'Paris'),
(3, 'Supplier2', 'Delhi'),
(5, 'Supplier3', 'London');


-- ---------------------------------------------------------------------
-- 2. Chapter 1: Subqueries (Single-row & Multi-row)
-- ---------------------------------------------------------------------

-- A. Single-row: Earns maximum salary
SELECT emp_name, salary
FROM Employees
WHERE salary = (SELECT MAX(salary) FROM Employees);

-- B. Single-row: Earns more than Alice
SELECT emp_name, salary
FROM Employees
WHERE salary > (SELECT salary FROM Employees WHERE emp_name = 'Alice');

-- C. Multi-row: Work in same department as Bob
SELECT emp_name, dept
FROM Employees
WHERE dept IN (SELECT dept FROM Employees WHERE emp_name = 'Bob');

-- D. Multi-row: Salary > ANY in HR (Greater than minimum)
SELECT emp_name, salary, dept
FROM Employees
WHERE salary > ANY (SELECT salary FROM Employees WHERE dept = 'HR');

-- E. Multi-row: Salary > ALL in HR (Greater than maximum)
SELECT emp_name, salary, dept
FROM Employees
WHERE salary > ALL (SELECT salary FROM Employees WHERE dept = 'HR');


-- ---------------------------------------------------------------------
-- 3. Chapter 2: Set Operators (UNION, INTERSECT, and EXCEPT)
-- ---------------------------------------------------------------------

-- A. UNION (Deduplicated Stack)
SELECT city FROM Customers
UNION
SELECT city FROM Suppliers;

-- B. UNION ALL (Full Stack with Duplicates)
SELECT city FROM Customers
UNION ALL
SELECT city FROM Suppliers;

-- C. Counting occurrences across tables
SELECT city, COUNT(*) AS total_occurrences
FROM (
    SELECT city FROM Customers
    UNION ALL
    SELECT city FROM Suppliers
) AS all_cities
GROUP BY city;

-- D. Emulating INTERSECT (Common IDs)
SELECT DISTINCT c.id, c.name, c.city
FROM Customers c
INNER JOIN Suppliers s ON c.id = s.id;

-- E. Emulating EXCEPT (Customers NOT in Suppliers)
SELECT c.id, c.name, c.city
FROM Customers c
LEFT JOIN Suppliers s ON c.id = s.id AND c.name = s.name AND c.city = s.city
WHERE s.id IS NULL;


-- ---------------------------------------------------------------------
-- 4. Chapter 3: Common Table Expressions (CTEs)
-- ---------------------------------------------------------------------

-- A. Single CTE: Employees earning above average
WITH AverageSalaryCTE AS (
    SELECT AVG(salary) AS avg_sal FROM Employees
)
SELECT e.emp_name, e.salary
FROM Employees e
CROSS JOIN AverageSalaryCTE a
WHERE e.salary > a.avg_sal;

-- B. Multiple CTEs: Employees in highest total salary spend department
WITH DepartmentSalaries AS (
    SELECT dept, SUM(salary) AS total_sal
    FROM Employees
    GROUP BY dept
),
HighestSpendingDept AS (
    SELECT dept
    FROM DepartmentSalaries
    WHERE total_sal = (SELECT MAX(total_sal) FROM DepartmentSalaries)
)
SELECT e.emp_name, e.salary, e.dept
FROM Employees e
JOIN HighestSpendingDept h ON e.dept = h.dept;

-- C. Recursive CTE: Generate numbers 1 to 5
WITH RECURSIVE NumberSequence AS (
    SELECT 1 AS num
    UNION ALL
    SELECT num + 1
    FROM NumberSequence
    WHERE num < 5
)
SELECT num FROM NumberSequence;


-- ---------------------------------------------------------------------
-- 5. Chapter 4: Hands-on Practice Exercises
-- ---------------------------------------------------------------------

-- Q1. Find the employee who earns the maximum salary.
SELECT emp_name, salary
FROM Employees
WHERE salary = (SELECT MAX(salary) FROM Employees);

-- Q2. Find the employee who earns the minimum salary.
SELECT emp_name, salary
FROM Employees
WHERE salary = (SELECT MIN(salary) FROM Employees);

-- Q3. Find employees who earn more than Alice.
SELECT emp_name, salary
FROM Employees
WHERE salary > (SELECT salary FROM Employees WHERE emp_name = 'Alice');

-- Q4. Find employees who work in the same department as David.
SELECT emp_name, dept
FROM Employees
WHERE dept = (SELECT dept FROM Employees WHERE emp_name = 'David');

-- Q5. Find employees who earn more than the average salary of all employees.
SELECT emp_name, salary
FROM Employees
WHERE salary > (SELECT AVG(salary) FROM Employees);

-- Q6. Find employees who are in the same department as Raj but not Raj himself.
SELECT emp_name, dept
FROM Employees
WHERE dept = (SELECT dept FROM Employees WHERE emp_name = 'Raj')
  AND emp_name <> 'Raj';

-- Q7. Find employees who work in the same department as Bob.
SELECT emp_name, dept
FROM Employees
WHERE dept IN (SELECT dept FROM Employees WHERE emp_name = 'Bob');

-- Q8. Find employees whose salary equals any salary in the IT department.
SELECT emp_name, salary, dept
FROM Employees
WHERE salary IN (SELECT salary FROM Employees WHERE dept = 'IT');

-- Q9. Find employees who earn more than ANY employee in the HR department.
SELECT emp_name, salary, dept
FROM Employees
WHERE salary > ANY (SELECT salary FROM Employees WHERE dept = 'HR');

-- Q10. Find employees who earn more than ALL employees in the HR department.
SELECT emp_name, salary, dept
FROM Employees
WHERE salary > ALL (SELECT salary FROM Employees WHERE dept = 'HR');

-- Q11. Find employees whose salary is less than ANY salary in the Finance department.
SELECT emp_name, salary, dept
FROM Employees
WHERE salary < ANY (SELECT salary FROM Employees WHERE dept = 'Finance');

-- Q12. Find employees whose salary is less than ALL salaries in the Finance department.
SELECT emp_name, salary, dept
FROM Employees
WHERE salary < ALL (SELECT salary FROM Employees WHERE dept = 'Finance');

-- Q13. Find employees who work in departments where at least one employee earns more than 30000.
SELECT emp_name, salary, dept
FROM Employees
WHERE dept IN (SELECT DISTINCT dept FROM Employees WHERE salary > 30000);

-- Q14. Find employees who earn more than the average salary of the IT department.
SELECT emp_name, salary, dept
FROM Employees
WHERE salary > (SELECT AVG(salary) FROM Employees WHERE dept = 'IT');

-- Q15. Find employees who earn more than the lowest paid employee in the Finance department.
SELECT emp_name, salary, dept
FROM Employees
WHERE salary > (SELECT MIN(salary) FROM Employees WHERE dept = 'Finance');

-- Q16. Find the employee with the second highest salary.
SELECT emp_name, salary
FROM Employees
WHERE salary = (
    SELECT MAX(salary)
    FROM Employees
    WHERE salary < (SELECT MAX(salary) FROM Employees)
);

-- Q17. Get all employees who work in the department of the minimum salary employee.
SELECT emp_name, dept
FROM Employees
WHERE dept = (
    SELECT dept
    FROM Employees
    WHERE salary = (SELECT MIN(salary) FROM Employees)
);

-- Q18. Correlated Subquery: Employees earning more than average of their own department
SELECT e1.emp_name, e1.salary, e1.dept
FROM Employees e1
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM Employees e2
    WHERE e2.dept = e1.dept
);

-- Q19. Correlated Subquery: Employees earning more than minimum of all other employees
SELECT e1.emp_name, e1.salary
FROM Employees e1
WHERE e1.salary > (
    SELECT MIN(e2.salary)
    FROM Employees e2
    WHERE e2.emp_id <> e1.emp_id
);

-- Q20. EXISTS: Departments with at least one employee earning > 20000
SELECT DISTINCT d.dept
FROM Employees d
WHERE EXISTS (
    SELECT 1 FROM Employees e 
    WHERE e.dept = d.dept AND e.salary > 20000
);

