--Use Northwind database. All questions are based on assumptions described by the Database Diagram sent to you yesterday. When inserting, make up info if necessary. Write query for each step. Do not use IDE. BE CAREFUL WHEN DELETING DATA OR DROPPING TABLE.
USE NORTHWND
GO
--1.      Create a view named “view_product_order_[your_last_name]”, list all products and total ordered quantity for that product.
CREATE VIEW view_product_order_Qiu AS
SELECT p.ProductID, ProductName, COUNT(o.Quantity) 'Ordered Quantity' 
FROM Products p JOIN [Order Details] o ON p.ProductID = O.ProductID
GROUP BY p.ProductName, p.ProductID

--SELECT *
--FROM view_product_order_Qiu

--2.      Create a stored procedure “sp_product_order_quantity_[your_last_name]” 
--that accept product id as an input and total quantities of order as output parameter.
CREATE PROC sp_product_order_quantity_Qiu
@id int,
@total int OUT
AS
BEGIN
	SELECT @id = view_product_order_Qiu.ProductID, 
	@total = view_product_order_Qiu.[Ordered Quantity]
	FROM view_product_order_Qiu
	WHERE view_product_order_Qiu.ProductID = @id
END

--declare @id int, @total int
--exec sp_product_order_quantity_Qiu 3, @total out
--print @total

--3.      Create a stored procedure “sp_product_order_city_[your_last_name]” that accept product 
--name as an input and top 5 cities that ordered most that product combined with the total quantity 
--of that product ordered from that city as output.***


SELECT TOP 5 c.City, p.ProductName, COUNT(r.Quantity) countQuantity 
FROM [Order Details] r JOIN Orders d ON r.OrderID = d.OrderID
JOIN Customers c ON c.CustomerID = d.CustomerID JOIN Products p ON p.ProductID = r.ProductID
GROUP BY c.City, p.ProductName


CREATE PROC sp_product_order_city_Qiu
@pname varchar(20)
AS
BEGIN 
	SELECT TOP 5 c.City, @pname = p.ProductName, COUNT(r.Quantity) countQuantity 
	FROM [Order Details] r JOIN Orders d ON r.OrderID = d.OrderID
	JOIN Customers c ON c.CustomerID = d.CustomerID JOIN Products p ON p.ProductID = r.ProductID
	GROUP BY c.City, p.ProductName
	HAVING @pname = p.ProductName
END

--4.      Create 2 new tables “people_your_last_name” “city_your_last_name”. 
--City table has two records: {Id:1, City: Seattle}, {Id:2, City: Green Bay}. 
--People has three records: {id:1, Name: Aaron Rodgers, City: 2}, {id:2, Name: Russell Wilson, City:1}, 
--{Id: 3, Name: Jody Nelson, City:2}. Remove city of Seattle. If there was anyone from Seattle, 
--put them into a new city “Madison”. Create a view “Packers_your_name” lists all people from Green Bay. 
--If any error occurred, no changes should be made to DB. (after test) Drop both tables and view.
CREATE TABLE people_Qiu(id int, name char(20), cityid int)
CREATE TABLE city_Qiu(cityid int, city char(20))
INSERT INTO people_Qiu(id, name, cityid)VALUES(1,'Aaron Rodgers',2)
INSERT INTO people_Qiu(id, name, cityid)VALUES(2,'Russell Wilson',1)
INSERT INTO people_Qiu(id, name, cityid)VALUES(2,'Jody Nelson',2)
INSERT INTO city_Qiu(cityid,city)Values(1,'Seattle')
INSERT INTO city_Qiu(cityid,city)Values(2,'Green Bay')

CREATE VIEW Packers_Qiu AS
SELECT p.id, p.name
FROM people_Qiu p JOIN city_Qiu c ON p.cityid = c.cityid
WHERE c.cityid = 'Green Bay'
BEGIN TRAN
ROLLBACK

DROP TABLE people_Qiu
DROP TABLE city_Qiu
DROP VIEW Packers_Qiu


--5.       Create a stored procedure “sp_birthday_employees_[you_last_name]” that 
--creates a new table “birthday_employees_your_last_name” and fill it with all employees 
--that have a birthday on Feb. (Make a screen shot) drop the table. Employee table should not be affected.
CREATE TABLE birthday_employees_Qiu(name char(20), birthdate datetime)

CREATE PROCEDURE sp_birthday_employees_Qiu
(@bd datetime)
AS
BEGIN
SET NOCOUNT ON
SELECT FirstName + ' ' + LastName AS Name, BirthDate  
FROM Employees
WHERE MONTH(BirthDate) = @bd
END

INSERT INTO birthday_employees_Qiu
exec sp_birthday_employees_Qiu 2

--SELECT *
--FROM birthday_employees_Qiu

--6.      How do you make sure two tables have the same data?

--We can do union between the two tables, find if they have the same total data number.
