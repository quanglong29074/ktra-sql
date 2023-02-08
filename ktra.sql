CREATE DATABASE AZBank
GO

USE AZBank
GO

CREATE TABLE Customer(
	CustomerId int PRIMARY KEY NOT NULL,
	Name nvarchar(50),
	City nvarchar(50),
	Country nvarchar(50),
	Phone nvarchar(15),
	Email nvarchar(50)
)
GO

CREATE TABLE CustomerAccount(
	AccountNumber char(9) PRIMARY KEY NOT NULL,
	CustomerId int FOREIGN KEY REFERENCES Customer(CustomerId) NOT NULL,
	Balance money NOT NULL,
	MinAccount money
)
GO

CREATE TABLE CustomerTransaction(
	TransactionId int PRIMARY KEY NOT NULL,
	AccountNumber char(9),
	TransactionDate smalldatetime,
	Amount money,
	DepositorWithdraw bit
)
GO
ALTER TABLE CustomerTransaction
ADD CONSTRAINT add_FK_CT
FOREIGN KEY (AccountNumber) REFERENCES CustomerAccount(AccountNumber)
GO
--3
INSERT INTO Customer (CustomerId, Name, City, Country, Phone, Email)
VALUES (4, 'dung', 'Hanoi', 'VN', '127-890-3456', 'dung@email.com'),
       (5, 'hieu', 'Hanoi', 'VN', '760-985-4321', 'hieu@email.com'),
       (3, 'Jim Smith', 'Paris', 'France', '111-222-3333', 'jimsmith@email.com'),
	   (1, 'John Doe', 'New York', 'USA', '123-456-7890', 'johndoe@email.com'),
       (2, 'Jane Doe', 'London', 'UK', '098-765-4321', 'janedoe@email.com')
GO

INSERT INTO CustomerAccount(AccountNumber, CustomerId, Balance, MinAccount)
VALUES (100, 1, 100, 1000),
       (200, 2, 200, 1500),
       (300, 3, 300, 2000)
GO

INSERT INTO CustomerTransaction (TransactionId, AccountNumber, TransactionDate, Amount, DepositorWithdraw)
VALUES (1, 100, '2022-12-01 12:30', 400, 1),
       (2, 200, '2022-12-02 14:00', 3000, 0),
       (3, 300, '2022-12-03 15:45', 1500, 1)
GO

--4 

SELECT * FROM Customer
WHERE City ='Hanoi'
GO

--5

SELECT Name, Phone, Email, AccountNumber, Balance
FROM Customer c
join CustomerAccount ca on c.CustomerId = ca.CustomerId
GO

--6
ALTER TABLE CustomerTransaction
ADD CONSTRAINT check_amount 
CHECK (Amount > 0 AND Amount <= 1000000 )
GO

--7
CREATE NONCLUSTERED INDEX index_name
ON Customer (Name)
GO

--8
CREATE VIEW vCustomerTransactions
as
	SELECT name, ct.AccountNumber, TransactionDate, Amount, DepositorWithdraw
	FROM Customer c 
	Join CustomerAccount ca on c.CustomerId = ca.CustomerId
	join CustomerTransaction ct on ca.AccountNumber = ca.AccountNumber
GO

SELECT * FROM vCustomerTransactions
GO
--9
CREATE PROCEDURE spAddCustomer (@CustomerId int, @Name nvarchar(50), @Country nvarchar(50), @Phone nvarchar(15), @Email nvarchar(50))
AS
BEGIN
		INSERT INTO Customer (CustomerId, Name, Country, Phone, Email)
		VALUES (@CustomerId, @Name, @Country, @Phone, @Email)
END
GO

EXEC spAddCustomer 6, 'tien dung', 'VN', '555-555-1212', 'dung@email.com';
EXEC spAddCustomer 7, 'Mango', 'Canada', '555-555-1213', 'Mango@email.com';
EXEC spAddCustomer 8, 'Cat', 'USA', '555-555-1214', 'cat@email.com';
GO

CREATE PROCEDURE spGetTransactions (@AccountNumber int, @FromDate smalldatetime, @ToDate smalldatetime)
AS
BEGIN
    SELECT TransactionDate, Amount,
           CASE WHEN DepositorWithdraw = 1 
			   THEN 'Deposit' ELSE 'Withdraw' END AS TransactionType
    FROM CustomerTransaction
    WHERE AccountNumber = @AccountNumber
      AND TransactionDate BETWEEN @FromDate AND @ToDate
END
GO

EXEC spGetTransactions 1000, '2022-11-01', '2023-02-06'
GO