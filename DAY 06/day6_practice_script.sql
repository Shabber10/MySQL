-- =====================================================================
-- Day 06 Practice Script: Database Normalization & Keys
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Database Setup & Unnormalized Structure
-- ---------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS day6_practice;
USE day6_practice;

-- Drop tables in order
DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Instructors;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS CourseRegistration;

-- Create Unnormalized Table
CREATE TABLE CourseRegistration (
    student_id INT,
    student_name VARCHAR(50),
    course_id VARCHAR(10),
    course_name VARCHAR(50),
    instructor_name VARCHAR(50),
    instructor_office VARCHAR(20),
    grade VARCHAR(5)
);

-- Insert Data demonstrating anomalies
INSERT INTO CourseRegistration VALUES
(1, 'Rahul', 'CS101', 'Databases', 'Dr. Sharma', 'Room 302', 'A'),
(1, 'Rahul', 'CS102', 'Algorithms', 'Dr. Verma', 'Room 305', 'B'),
(2, 'Priya', 'CS101', 'Databases', 'Dr. Sharma', 'Room 302', 'A+'),
(3, 'Amit', 'CS103', 'Networks', 'Dr. Patel', 'Room 401', 'B-');


-- ---------------------------------------------------------------------
-- 2. Demonstrating Database Anomalies
-- ---------------------------------------------------------------------

-- A. Update Anomaly: If Dr. Sharma moves, we must update all matching rows
-- To change Room 302 to Room 309, we run an UPDATE:
UPDATE CourseRegistration
SET instructor_office = 'Room 309'
WHERE instructor_name = 'Dr. Sharma';

-- Verification:
SELECT * FROM CourseRegistration;

-- B. Deletion Anomaly: If we delete Amit (student_id = 3), we lose networks info
DELETE FROM CourseRegistration
WHERE student_id = 3;

-- Networks course CS103 and Dr. Patel have vanished:
SELECT * FROM CourseRegistration;


-- ---------------------------------------------------------------------
-- 3. Decomposing to 3rd Normal Form (3NF)
-- ---------------------------------------------------------------------

-- 1. Students Table
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50)
);

-- 2. Instructors Table (Stores transitive relationships)
CREATE TABLE Instructors (
    instructor_name VARCHAR(50) PRIMARY KEY,
    instructor_office VARCHAR(20)
);

-- 3. Courses Table (References Instructors)
CREATE TABLE Courses (
    course_id VARCHAR(10) PRIMARY KEY,
    course_name VARCHAR(50),
    instructor_name VARCHAR(50),
    FOREIGN KEY (instructor_name) REFERENCES Instructors(instructor_name)
);

-- 4. Enrollments Table (Composite Primary Key)
CREATE TABLE Enrollments (
    student_id INT,
    course_id VARCHAR(10),
    grade VARCHAR(5),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);


-- ---------------------------------------------------------------------
-- 4. Ingesting Normalized Data
-- ---------------------------------------------------------------------

INSERT INTO Students VALUES
(1, 'Rahul'),
(2, 'Priya'),
(3, 'Amit');

INSERT INTO Instructors VALUES
('Dr. Sharma', 'Room 302'),
('Dr. Verma', 'Room 305'),
('Dr. Patel', 'Room 401');

INSERT INTO Courses VALUES
('CS101', 'Databases', 'Dr. Sharma'),
('CS102', 'Algorithms', 'Dr. Verma'),
('CS103', 'Networks', 'Dr. Patel');

INSERT INTO Enrollments VALUES
(1, 'CS101', 'A'),
(1, 'CS102', 'B'),
(2, 'CS101', 'A+'),
(3, 'CS103', 'B-');


-- ---------------------------------------------------------------------
-- 5. Verification: Anomalies Prevented
-- ---------------------------------------------------------------------

-- A. Update is now done in 1 place (Instructors table)
UPDATE Instructors
SET instructor_office = 'Room 309'
WHERE instructor_name = 'Dr. Sharma';

-- B. Deletion of student 3 does not affect Course/Instructor details
DELETE FROM Enrollments WHERE student_id = 3;

-- CS103 Networks and Dr. Patel are still saved:
SELECT * FROM Courses;
SELECT * FROM Instructors;
