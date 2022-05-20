--Write queries for following scenarios
--Joins:
--(AdventureWorks)
USE AdventureWorks2019
GO

--1. Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables. 
--Join them and produce a result set similar to the following.
--    Country                        Province
SELECT DISTINCT c.Name Country, s.Name Province
FROM Person.CountryRegion c JOIN Person.StateProvince s ON c.CountryRegionCode = s.CountryRegionCode

--2. Write a query that lists the country and province names from person. CountryRegion and person. 
--StateProvince tables and list the countries filter them by Germany and Canada.
--Join them and produce a result set similar to the following.
--    Country                        Province
SELECT DISTINCT c.Name Country, s.Name Province
FROM Person.CountryRegion c LEFT JOIN Person.StateProvince s ON c.CountryRegionCode = s.CountryRegionCode
WHERE c.Name IN ('Germany', 'Canada')

-- Using Northwind Database: (Use aliases for all the Joins)
USE NORTHWND
GO

--3. List all Products that has been sold at least once in last 25 years.
SELECT DISTINCT p.ProductName
FROM Products p JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE o.OrderDate BETWEEN '1997-5-18' AND '2022-5-18'

--4. List top 5 locations (Zip Code) where the products sold most in last 25 years.
SELECT TOP 5 ShipPostalCode
FROM Orders
WHERE OrderDate BETWEEN '1997-5-18' AND '2022-5-18'
GROUP BY ShipPostalCode
ORDER BY COUNT(ShipPostalCode) DESC

--5. List all city names and number of customers in that city.     
SELECT City, COUNT(ContactName) as 'Number Customers'
FROM Customers
GROUP BY City

--6. List city names which have more than 2 customers, and number of customers in that city
SELECT City, COUNT(ContactName) as 'Number Customers'
FROM Customers
GROUP BY City
HAVING COUNT(ContactName) > 2

--7. Display the names of all customers  along with the  count of products they bought
SELECT c.ContactName, COUNT(c.ContactName) as 'Count Of Products'
FROM Customers c JOIN Orders O ON c.CustomerID = O.CustomerID
GROUP BY c.ContactName
ORDER BY COUNT(c.ContactName)

--8. Display the customer ids who bought more than 100 Products with count of products.
SELECT C.ContactName, SUM(d.Quantity) 'Count of Products'
FROM Orders o JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN [Order Details] d ON o.OrderID = d.OrderID
GROUP BY C.ContactName
HAVING SUM(d.Quantity) > 100
ORDER BY SUM(d.Quantity)

--9. List all of the possible ways that suppliers can ship their products. Display the results as below
--    Supplier Company Name                Shipping Company Name
    ---------------------------------            ----------------------------------
SELECT u.CompanyName, s.CompanyName 
FROM Shippers s
CROSS JOIN Suppliers u	

--10. Display the products order each day. Show Order date and Product Name.
SELECT p.ProductName, r.OrderDate
FROM Products p JOIN [Order Details] o ON p.ProductID = o.ProductID 
JOIN Orders r ON r.OrderID = O.OrderID

--11. Displays pairs of employees who have the same job title.
SELECT a.FirstName + ' ' + a.LastName AS 'First Employee',
b.FirstName + ' ' + b.LastName AS 'Second Employee', a.Title
FROM Employees a JOIN Employees b ON a.Title = b.Title
WHERE a.EmployeeID != b.EmployeeID

--12. Display all the Managers who have more than 2 employees reporting to them.
SELECT a.EmployeeID, a.FirstName + ' ' + a.LastName AS Name, a.Title
FROM Employees a JOIN Employees b ON a.EmployeeID = b.ReportsTo
WHERE a.Title LIKE '%manager%'
GROUP BY a.EmployeeID, a.FirstName, a.LastName, a.Title
HAVING COUNT(b.ReportsTo) > 2

--13. Display the customers and suppliers by city. The results should have the following columns
--City
--Name
--Contact Name,
--Type (Customer or Supplier)
SELECT city, ContactName, 'Customer' AS 'Tpye' 
FROM Customers
UNION
SELECT city, ContactName, 'Supplier' AS 'Tpye' 
FROM Suppliers

--All scenarios are based on Database NORTHWIND.


--14. List all cities that have both Employees and Customers.
SELECT DISTINCT e.City
FROM Employees e JOIN Customers c ON e.City = c.City

--15. List all cities that have Customers but no Employee.
--a.    
-- Use
--sub-query
SELECT DISTINCT City
FROM Customers
WHERE City NOT IN
(SELECT City
FROM Employees) 

--b.     
-- Do
--not use sub-query
SELECT DISTINCT c.City
FROM Customers c LEFT JOIN Employees e ON c.City = e.City
WHERE e.EmployeeID IS NULL

--16. List all products and their total order quantities throughout all orders.
SELECT p.ProductName, SUM(o.Quantity) AS Quantities
FROM Products p JOIN [Order Details] o ON p.ProductID = o.ProductID
GROUP BY p.ProductName
ORDER BY Quantities DESC

--17. List all Customer Cities that have at least two customers. ****
--a.    
-- Use
--union
SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(City) > 2
UNION
SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(City) = 2

--b.     
-- Use
--sub-query and no union
SELECT Distinct City
FROM Customers 
WHERE City IN 
(SELECT City
FROM Customers
GROUP BY City
HAVING COUNT(City) >= 2)

--18. List all Customer Cities that have ordered at least two different kinds of products.
SELECT DISTINCT c.City
FROM Customers c JOIN Orders o ON C.CustomerID = o.CustomerID 
JOIN [Order Details] d ON d.OrderID = o.OrderID
GROUP BY c.City, d.ProductID
HAVING COUNT(d.ProductID) >= 2

--19. List 5 most popular products, their average price, and the customer city that ordered most quantity of it.
SELECT c.City, dt.ProductName, DT.UnitPrice, DT.RNK
FROM 
(SELECT od.CustomerID, p.ProductName, o.UnitPrice, o.Quantity, ROW_NUMBER() OVER (ORDER BY o.Quantity DESC) AS RNK
FROM [Order Details] o JOIN Products p ON o.ProductID = p.ProductID JOIN Orders od ON od.OrderID = o.OrderID) dt 
JOIN Customers c ON dt.CustomerID = c.CustomerID
WHERE dt.RNK <= 5

--20. List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, 
--and also the city of most total quantity of products ordered
--from. (tip: join  sub-query)
SELECT * 
FROM 
(SELECT TOP 1 e.City, COUNT(o.OrderID) countOrder FROM Employees e JOIN Orders o ON e.EmployeeID = o.EmployeeID GROUP BY e.City) l
JOIN 
(SELECT TOP 1 c.City, COUNT(r.Quantity) countQuantity FROM [Order Details] r JOIN Orders d ON r.OrderID = d.OrderID
JOIN Customers c ON c.CustomerID = d.CustomerID GROUP BY c.City) m
ON l.City = m.City;

--21. How do you remove the duplicates record of a table?
WITH cte AS (
    SELECT 
        first_name,  
        ROW_NUMBER() OVER (
            PARTITION BY 
                first_name, 
            ORDER BY 
                first_name, 
        ) row_num
     FROM 
        table_****
)
DELETE FROM cte
WHERE row_num > 1;