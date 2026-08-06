-- =====================================================================
-- Day 10 Practice Script: Stored Procedures & Functions
-- =====================================================================

CREATE DATABASE IF NOT EXISTS day10_practice;
USE day10_practice;

DROP TABLE IF EXISTS AuditLog;
DROP TABLE IF EXISTS Employees;

CREATE TABLE Employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    dept VARCHAR(50),
    salary DECIMAL(10,2),
    birth_date DATE
);

CREATE TABLE AuditLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    log_message VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Employees (name, dept, salary, birth_date) VALUES
('Rahul Sharma', 'IT',      65000.00, '1995-04-12'),
('Priya Singh',  'IT',      48000.00, '1998-08-25'),
('Amit Patel',   'HR',      35000.00, '1992-11-05'),
('Sara Khan',    'Finance', 72000.00, '1990-02-18'),
('John Doe',     'Finance', 55000.00, '1996-09-30');


-- ---------------------------------------------------------------------
-- 1. Procedure with IN Parameter
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS GetEmployeesBySalary;

DELIMITER //
CREATE PROCEDURE GetEmployeesBySalary(IN min_sal DECIMAL(10,2))
BEGIN
    SELECT * FROM Employees WHERE salary >= min_sal ORDER BY salary DESC;
END //
DELIMITER ;

CALL GetEmployeesBySalary(50000.00);


-- ---------------------------------------------------------------------
-- 2. Procedure with OUT Parameter
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS GetDeptPayroll;

DELIMITER //
CREATE PROCEDURE GetDeptPayroll(IN p_dept VARCHAR(50), OUT p_total DECIMAL(10,2))
BEGIN
    SELECT IFNULL(SUM(salary), 0) INTO p_total 
    FROM Employees 
    WHERE dept = p_dept;
END //
DELIMITER ;

CALL GetDeptPayroll('IT', @it_payroll);
SELECT @it_payroll AS IT_Total_Payroll;


-- ---------------------------------------------------------------------
-- 3. Procedure with INOUT Parameter
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS ApplyBonus;

DELIMITER //
CREATE PROCEDURE ApplyBonus(INOUT p_val DECIMAL(10,2), IN p_bonus DECIMAL(10,2))
BEGIN
    SET p_val = p_val + p_bonus;
END //
DELIMITER ;

SET @current_bonus = 5000.00;
CALL ApplyBonus(@current_bonus, 1500.00);
SELECT @current_bonus AS updated_bonus;


-- ---------------------------------------------------------------------
-- 4. User-Defined Function (UDF): CalculateAge
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS CalculateAge;

DELIMITER //
CREATE FUNCTION CalculateAge(dob DATE)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, dob, CURDATE());
END //
DELIMITER ;

SELECT name, birth_date, CalculateAge(birth_date) AS age FROM Employees;


-- ---------------------------------------------------------------------
-- 5. Procedure with IF-ELSE Control Flow
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS ClassifySalary;

DELIMITER //
CREATE PROCEDURE ClassifySalary(IN p_emp_id INT, OUT p_tier VARCHAR(20))
BEGIN
    DECLARE v_sal DECIMAL(10,2);
    SELECT salary INTO v_sal FROM Employees WHERE emp_id = p_emp_id;
    
    IF v_sal >= 70000 THEN
        SET p_tier = 'High Earner';
    ELSEIF v_sal >= 45000 THEN
        SET p_tier = 'Mid Earner';
    ELSE
        SET p_tier = 'Entry Level';
    END IF;
END //
DELIMITER ;

CALL ClassifySalary(1, @emp1_tier);
SELECT @emp1_tier AS Rahul_Salary_Tier;


-- ---------------------------------------------------------------------
-- 6. Procedure with WHILE Loop
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS PopulateLogs;

DELIMITER //
CREATE PROCEDURE PopulateLogs(IN p_count INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= p_count DO
        INSERT INTO AuditLog (log_message) VALUES (CONCAT('Automated Log Entry #', i));
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL PopulateLogs(3);
SELECT * FROM AuditLog;


-- ---------------------------------------------------------------------
-- 7. Procedure with Error Exit Handler
-- ---------------------------------------------------------------------
DROP PROCEDURE IF EXISTS SafeInsertEmployee;

DELIMITER //
CREATE PROCEDURE SafeInsertEmployee(
    IN p_id INT,
    IN p_name VARCHAR(50),
    IN p_dept VARCHAR(50),
    IN p_sal DECIMAL(10,2),
    OUT p_res VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_res = 'ERROR: Duplicate ID or Invalid Input. Transaction Aborted.';
    END;

    START TRANSACTION;
    INSERT INTO Employees (emp_id, name, dept, salary, birth_date)
    VALUES (p_id, p_name, p_dept, p_sal, '2000-01-01');
    COMMIT;
    
    SET p_res = 'SUCCESS: Employee inserted successfully.';
END //
DELIMITER ;

-- Test successful insert:
CALL SafeInsertEmployee(10, 'Karan Mehta', 'HR', 40000.00, @msg1);
SELECT @msg1;

-- Test failure insert (Duplicate PK = 10):
CALL SafeInsertEmployee(10, 'Duplicate User', 'HR', 40000.00, @msg2);
SELECT @msg2;
