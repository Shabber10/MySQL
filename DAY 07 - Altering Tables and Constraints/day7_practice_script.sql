-- =====================================================================
-- Day 07 Practice Script: Altering Tables & Constraints
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Table Setup
-- ---------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS day7_practice;
USE day7_practice;

DROP TABLE IF EXISTS StaffDetails;
DROP TABLE IF EXISTS LegacyStaff;

-- Create legacy, unconstrained table
CREATE TABLE LegacyStaff (
    id INT,
    name VARCHAR(30),
    salary DECIMAL(10,2)
);

-- Insert some dummy records
INSERT INTO LegacyStaff VALUES
(1, 'Amit', 1500.00),
(2, 'Sara', 2400.00);


-- ---------------------------------------------------------------------
-- 2. Running Schema alterations (Chapter 1 & Chapter 3 Tasks)
-- ---------------------------------------------------------------------

-- Task 1: Rename the table
RENAME TABLE LegacyStaff TO StaffDetails;

-- Task 2: Add primary key to ID (requires NOT NULL modification first)
ALTER TABLE StaffDetails
MODIFY COLUMN id INT NOT NULL;

ALTER TABLE StaffDetails
ADD PRIMARY KEY (id);

-- Task 3: Add new email column after the name column
ALTER TABLE StaffDetails
ADD COLUMN email VARCHAR(80) NOT NULL AFTER name;

-- Update emails for existing records (since email is NOT NULL)
UPDATE StaffDetails SET email = 'amit@email.com' WHERE id = 1;
UPDATE StaffDetails SET email = 'sara@email.com' WHERE id = 2;

-- Task 4: Add Unique constraint on Email
ALTER TABLE StaffDetails
ADD CONSTRAINT uq_staff_email UNIQUE (email);

-- Task 5: Add Check constraint on Salary
ALTER TABLE StaffDetails
ADD CONSTRAINT chk_min_salary CHECK (salary >= 1000.00);


-- ---------------------------------------------------------------------
-- 3. Verifying Constraints (Testing Failure Cases)
-- ---------------------------------------------------------------------

-- A. Test Primary Key Constraint (Duplicate ID)
-- This should FAIL:
-- INSERT INTO StaffDetails (id, name, email, salary) VALUES (1, 'Rohan', 'rohan@email.com', 1200.00);

-- B. Test Unique Constraint (Duplicate Email)
-- This should FAIL:
-- INSERT INTO StaffDetails (id, name, email, salary) VALUES (3, 'Rohan', 'amit@email.com', 1200.00);

-- C. Test Check Constraint (Salary < 1000)
-- This should FAIL:
-- INSERT INTO StaffDetails (id, name, email, salary) VALUES (3, 'Rohan', 'rohan@email.com', 950.00);


-- ---------------------------------------------------------------------
-- 4. Reversing constraints (Task 6)
-- ---------------------------------------------------------------------

-- Task 6: Drop the unique constraint from email (drops its index in MySQL)
ALTER TABLE StaffDetails
DROP INDEX uq_staff_email;

-- Verify that duplicate emails are now allowed:
INSERT INTO StaffDetails (id, name, email, salary) VALUES 
(3, 'Rohan', 'amit@email.com', 1200.00);

-- Inspect final table details
DESCRIBE StaffDetails;
SELECT * FROM StaffDetails;


-- ---------------------------------------------------------------------
-- 5. Special Alterations: Generated Columns & Defaults
-- ---------------------------------------------------------------------

-- Add a default status column
ALTER TABLE StaffDetails
ADD COLUMN status VARCHAR(20);

ALTER TABLE StaffDetails
ALTER COLUMN status SET DEFAULT 'Active';

-- Add a computed bonus column (10% of salary)
ALTER TABLE StaffDetails
ADD COLUMN annual_bonus DECIMAL(10,2) GENERATED ALWAYS AS (salary * 0.10) STORED;

-- Verify default and generated columns
INSERT INTO StaffDetails (id, name, email, salary) VALUES
(4, 'Vikram', 'vikram@email.com', 5000.00);

SELECT * FROM StaffDetails WHERE id = 4;

