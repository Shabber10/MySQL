-- ==========================================
-- DAY 01: MySQL Hands-On Practice Script
-- Database: library_db
-- ==========================================

-- ------------------------------------------
-- 1. DATABASE SETUP
-- ------------------------------------------
-- Drop database if it already exists to start fresh
DROP DATABASE IF EXISTS library_db;

-- Create database
CREATE DATABASE library_db;

-- Select database to use
USE library_db;


-- ------------------------------------------
-- 2. CREATE TABLE WITH CONSTRAINTS
-- ------------------------------------------
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    price DECIMAL(6, 2) NOT NULL,
    stock_count INT DEFAULT 0,
    published_date DATE
);

-- Inspect table structure
DESCRIBE books;


-- ------------------------------------------
-- 3. INSERTING DATA (CREATE)
-- ------------------------------------------

-- Scenario A: Single row insertion (providing all columns)
INSERT INTO books (title, author, isbn, price, stock_count, published_date)
VALUES ('The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', 15.99, 12, '1925-04-10');

-- Scenario B: Multi-row insertion (bulk insert)
INSERT INTO books (title, author, isbn, price, stock_count, published_date)
VALUES 
('To Kill a Mockingbird', 'Harper Lee', '9780446310789', 12.50, 8, '1960-07-11'),
('1984', 'George Orwell', '9780451524935', 9.99, 15, '1949-06-08'),
('The Hobbit', 'J.R.R. Tolkien', '9780547928227', 22.00, 5, '1937-09-21');

-- Scenario C: Inserting with default value for stock_count (omitting stock_count)
INSERT INTO books (title, author, isbn, price, published_date)
VALUES ('New Release Book', 'Unknown Author', '9781111111111', 29.99, '2026-01-01');


-- ------------------------------------------
-- 4. QUERYING DATA (READ)
-- ------------------------------------------

-- Query A: View all columns and rows
SELECT * FROM books;

-- Query B: View specific columns
SELECT title, price FROM books;

-- Query C: Filtering rows (find books costing less than $15.00)
SELECT title, author, price FROM books
WHERE price < 15.00;

-- Query D: Filtering rows (find books with stock of 10 or more)
SELECT title, stock_count FROM books
WHERE stock_count >= 10;


-- ------------------------------------------
-- 5. UPDATING DATA (UPDATE)
-- ------------------------------------------

-- Scenario A: Adjust stock count for '1984' (book_id = 3)
UPDATE books
SET stock_count = 14
WHERE book_id = 3;

-- Scenario B: Adjust price for 'The Hobbit' (book_id = 4)
UPDATE books
SET price = 19.99
WHERE book_id = 4;

-- Verify updates
SELECT * FROM books;


-- ------------------------------------------
-- 6. DELETING DATA (DELETE)
-- ------------------------------------------

-- Delete 'New Release Book' (book_id = 5)
DELETE FROM books
WHERE book_id = 5;

-- Verify deletion
SELECT * FROM books;
