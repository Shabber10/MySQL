-- =====================================================================
-- Day 08 Practice Script: Transactions & Concurrency
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Database Setup
-- ---------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS day8_practice;
USE day8_practice;

DROP TABLE IF EXISTS Accounts;

CREATE TABLE Accounts (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    balance DECIMAL(10,2)
);

INSERT INTO Accounts VALUES
(1, 'Alice', 1000.00),
(2, 'Bob', 500.00);


-- ---------------------------------------------------------------------
-- 2. Exercise 1: Rollback Verification
-- ---------------------------------------------------------------------

START TRANSACTION;
UPDATE Accounts SET balance = balance - 200.00 WHERE id = 1;
UPDATE Accounts SET balance = balance + 200.00 WHERE id = 2;
SELECT * FROM Accounts; -- In-memory modifications visible to Session A
ROLLBACK; -- Discard changes

-- Check balances (restored to original values)
SELECT * FROM Accounts;


-- ---------------------------------------------------------------------
-- 3. Exercise 2: Savepoint Execution
-- ---------------------------------------------------------------------

START TRANSACTION;
UPDATE Accounts SET balance = balance + 100.00 WHERE id = 1;
SAVEPOINT sp_alice_deposit;

UPDATE Accounts SET balance = balance + 300.00 WHERE id = 2;
SELECT * FROM Accounts; -- Both modifications visible

ROLLBACK TO SAVEPOINT sp_alice_deposit; -- Discard Bob's update
SELECT * FROM Accounts; -- Only Alice's update remains

COMMIT; -- Permanent save

-- Check balances (Alice = 1100.00, Bob = 500.00)
SELECT * FROM Accounts;


-- ---------------------------------------------------------------------
-- 4. Session Isolation Level Queries
-- ---------------------------------------------------------------------

-- View current isolation levels
-- (For MySQL 8.0+):
SELECT @@transaction_isolation;

-- Set current session isolation levels
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Restore to default
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;


-- ---------------------------------------------------------------------
-- 5. Row-level Lock Demonstrations
-- ---------------------------------------------------------------------

-- A. Shared Lock (Locks row 1 for reading, preventing modifications)
START TRANSACTION;
SELECT * FROM Accounts WHERE id = 1 FOR SHARE;
-- (Other sessions can read, but updates to row 1 will wait)
COMMIT;

-- B. Exclusive Lock (Locks row 1 for writing, blocking other lock reads/updates)
START TRANSACTION;
SELECT * FROM Accounts WHERE id = 1 FOR UPDATE;
-- (Other sessions updates/locks block)
COMMIT;
