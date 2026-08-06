-- =====================================================================
-- Day 12 Practice Script: User Management & Security
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Database & Table Setup (Run as root)
-- ---------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS college;
USE college;

DROP VIEW IF EXISTS student_public;
DROP TABLE IF EXISTS student;

CREATE TABLE student (
    sid INT PRIMARY KEY AUTO_INCREMENT,
    sname VARCHAR(50),
    subject VARCHAR(50),
    marks INT,
    phone VARCHAR(15),
    city VARCHAR(50)
);

INSERT INTO student (sname, subject, marks, phone, city) VALUES
('Rahul', 'Math', 85, '9999911111', 'Delhi'),
('Priya', 'Physics', 91, '9000011111', 'Bangalore'),
('Amit', 'Chemistry', 78, '9888822222', 'Delhi'),
('Sara', 'Math', 95, '9777733333', 'Mumbai');

-- Create safe view excluding sensitive phone numbers
CREATE VIEW student_public AS
SELECT sid, sname, subject, marks, city
FROM student;


-- ---------------------------------------------------------------------
-- 2. Creating User Accounts
-- ---------------------------------------------------------------------

-- Drop users if they already exist
DROP USER IF EXISTS 'admin'@'localhost';
DROP USER IF EXISTS 'faculty'@'localhost';

-- Create Admin and Faculty user accounts
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin123';
CREATE USER 'faculty'@'localhost' IDENTIFIED BY 'faculty123';

-- Inspect users in system table
SELECT User, Host FROM mysql.user WHERE User IN ('admin', 'faculty');


-- ---------------------------------------------------------------------
-- 3. Granting Privileges
-- ---------------------------------------------------------------------

-- Grant Admin full power over college database with delegation capability
GRANT ALL PRIVILEGES ON college.* TO 'admin'@'localhost' WITH GRANT OPTION;

-- Grant Faculty read-only access to safe student view only
GRANT SELECT ON college.student_public TO 'faculty'@'localhost';

-- Inspect assigned grants
SHOW GRANTS FOR 'admin'@'localhost';
SHOW GRANTS FOR 'faculty'@'localhost';

-- Apply privilege changes immediately
FLUSH PRIVILEGES;


-- ---------------------------------------------------------------------
-- 4. Revoking Privileges
-- ---------------------------------------------------------------------

-- Revoke SELECT privilege from Faculty
REVOKE SELECT ON college.student_public FROM 'faculty'@'localhost';

-- Verify updated privileges
SHOW GRANTS FOR 'faculty'@'localhost';
FLUSH PRIVILEGES;


-- ---------------------------------------------------------------------
-- 5. User Cleanup
-- ---------------------------------------------------------------------

-- Drop multiple custom users at once
DROP USER 'admin'@'localhost', 'faculty'@'localhost';

-- Verify deletion
SELECT User, Host FROM mysql.user WHERE User IN ('admin', 'faculty');
