-- ==========================================
-- DAY 01: MySQL Hands-On Practice Script
-- Database: library_db
-- ==========================================

-- ------------------------------------------
-- 1. DATABASE SETUP
-- ------------------------------------------
DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db;
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

DESCRIBE books;


-- ------------------------------------------
-- 3. INSERTING DATA (CREATE)
-- ------------------------------------------
INSERT INTO books (title, author, isbn, price, stock_count, published_date)
VALUES ('The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', 15.99, 12, '1925-04-10');

INSERT INTO books (title, author, isbn, price, stock_count, published_date)
VALUES 
('To Kill a Mockingbird', 'Harper Lee', '9780446310789', 12.50, 8, '1960-07-11'),
('1984', 'George Orwell', '9780451524935', 9.99, 15, '1949-06-08'),
('The Hobbit', 'J.R.R. Tolkien', '9780547928227', 22.00, 5, '1937-09-21');

INSERT INTO books (title, author, isbn, price, published_date)
VALUES ('New Release Book', 'Unknown Author', '9781111111111', 29.99, '2026-01-01');


-- ------------------------------------------
-- 4. QUERYING DATA (READ)
-- ------------------------------------------
SELECT * FROM books;
SELECT title, price FROM books;
SELECT title, author, price FROM books WHERE price < 15.00;
SELECT title, stock_count FROM books WHERE stock_count >= 10;


-- ------------------------------------------
-- 5. UPDATING DATA (UPDATE)
-- ------------------------------------------
UPDATE books SET stock_count = 14 WHERE book_id = 3;
UPDATE books SET price = 19.99 WHERE book_id = 4;
SELECT * FROM books;


-- ------------------------------------------
-- 6. DELETING DATA (DELETE)
-- ------------------------------------------
DELETE FROM books WHERE book_id = 5;
SELECT * FROM books;


-- ------------------------------------------
-- 7. ADVANCED TABLE CREATION & GENERATED COLUMNS
-- ------------------------------------------
-- CTAS: Copy structure & data
CREATE TABLE books_backup AS SELECT * FROM books;
SELECT * FROM books_backup;

-- CTAS: Copy structure only (WHERE 1=0)
CREATE TABLE books_empty AS SELECT * FROM books WHERE 1=0;
DESCRIBE books_empty;

-- GENERATED (COMPUTED) COLUMN
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    total_price DECIMAL(10,2) GENERATED ALWAYS AS (unit_price * quantity) STORED
);

INSERT INTO products (product_name, unit_price, quantity) VALUES ('Apple', 20.00, 2);
SELECT * FROM products;

UPDATE products SET quantity = 5 WHERE product_id = 1;
SELECT * FROM products;


-- ------------------------------------------
-- 8. COPYING DATA VIA INSERT INTO ... SELECT
-- ------------------------------------------
INSERT INTO books_empty (book_id, title, author, isbn, price, stock_count, published_date)
SELECT book_id, title, author, isbn, price, stock_count, published_date FROM books;

SELECT * FROM books_empty;
