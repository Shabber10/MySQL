-- =====================================================================
-- Day 10 Practice Script: Stored Procedures & Functions
-- =====================================================================

CREATE DATABASE IF NOT EXISTS day10_practice;
USE day10_practice;

-- 1. Setup Sample Tables
DROP TABLE IF EXISTS cust;
CREATE TABLE cust (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50)
);

INSERT INTO cust VALUES
(1, 'Raju', 'Hyderabad'),
(2, 'Rajesh', 'Bengaluru'),
(3, 'Ram', 'Chennai'),
(4, 'Pooja', 'Amritsar');

DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    city VARCHAR(50)
);

INSERT INTO Employees (name, department, salary, city) VALUES
('Raju', 'HR', 45000.00, 'Hyderabad'),
('Rajesh', 'IT', 65000.00, 'Bengaluru'),
('Ram', 'IT', 72000.00, 'Chennai'),
('Pooja', 'Finance', 58000.00, 'Amritsar'),
('Sita', 'HR', 48000.00, 'Delhi');

-- ---------------------------------------------------------------------
-- 2. Stored Procedure Definitions
-- ---------------------------------------------------------------------

-- A. Select All Customers Procedure
DROP PROCEDURE IF EXISTS GetAllCustomers;
DELIMITER //
CREATE PROCEDURE GetAllCustomers()
BEGIN
   SELECT * FROM cust;
END //
DELIMITER ;

-- Test Procedure
CALL GetAllCustomers();


-- B. Select Customer By ID Procedure
DROP PROCEDURE IF EXISTS GetCustomerById;
DELIMITER //
CREATE PROCEDURE GetCustomerById(IN cust_id INT)
BEGIN
   SELECT * FROM cust WHERE id = cust_id;
END //
DELIMITER ;

-- Test Procedure
CALL GetCustomerById(2);


-- C. Insert Customer Procedure
DROP PROCEDURE IF EXISTS InsertCustomer;
DELIMITER //
CREATE PROCEDURE InsertCustomer(
    IN cust_id INT,
    IN cust_name VARCHAR(50),
    IN cust_city VARCHAR(50)
)
BEGIN
   INSERT INTO cust (id, name, city) VALUES (cust_id, cust_name, cust_city);
   SELECT 'Customer Inserted Successfully!' AS message;
END //
DELIMITER ;

-- Test Procedure
CALL InsertCustomer(5, 'Ravi', 'Delhi');
SELECT * FROM cust;


-- D. Update Customer City Procedure
DROP PROCEDURE IF EXISTS UpdateCustomerCity;
DELIMITER //
CREATE PROCEDURE UpdateCustomerCity(
    IN cust_id INT,
    IN new_city VARCHAR(50)
)
BEGIN
   UPDATE cust SET city = new_city WHERE id = cust_id;
   SELECT 'Customer Updated Successfully!' AS message;
END //
DELIMITER ;

-- Test Procedure
CALL UpdateCustomerCity(3, 'Pune');
SELECT * FROM cust;


-- E. Delete Customer Procedure
DROP PROCEDURE IF EXISTS DeleteCustomer;
DELIMITER //
CREATE PROCEDURE DeleteCustomer(IN cust_id INT)
BEGIN
   DELETE FROM cust WHERE id = cust_id;
   SELECT 'Customer Deleted Successfully!' AS message;
END //
DELIMITER ;

-- Test Procedure
CALL DeleteCustomer(4);
SELECT * FROM cust;


-- ---------------------------------------------------------------------
-- 3. Stored Function Definitions
-- ---------------------------------------------------------------------

-- A. Tax Calculation Function
DROP FUNCTION IF EXISTS CalculateTax;
DELIMITER //
CREATE FUNCTION CalculateTax(salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE tax DECIMAL(10,2);
    IF salary > 50000 THEN
        SET tax = salary * 0.20;
    ELSE
        SET tax = salary * 0.10;
    END IF;
    RETURN tax;
END //
DELIMITER ;

-- Test Function
SELECT name, salary, CalculateTax(salary) AS tax_amount FROM Employees;


-- B. Annual Salary Function
DROP FUNCTION IF EXISTS GetAnnualSalary;
DELIMITER //
CREATE FUNCTION GetAnnualSalary(monthly_sal DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN monthly_sal * 12;
END //
DELIMITER ;

-- Test Function
SELECT name, salary, GetAnnualSalary(salary) AS annual_salary FROM Employees;
