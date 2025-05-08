/*Write a query to display the following table:

Select each table name as a string.
Select the number of attributes as an integer (count the number of attributes per table).
Select the number of rows using the COUNT(*) function.
Use the compound-operator UNION ALL to bind these rows together.*/


SELECT 'Customers' AS table_name,count(*) AS number_of_attributes, (SELECT count(*)  FROM Customers) AS number_of_rows
  FROM pragma_table_info('Customers')
UNION ALL 
SELECT 'Products' AS table_name,count(*) AS number_of_attributes, 
(SELECT count(*)  FROM Products) AS number_of_rows
  FROM pragma_table_info('Products')
UNION ALL 
SELECT 'ProductLines' AS table_name,count(*) AS number_of_attributes, 
(SELECT count(*)  FROM ProductLines) AS number_of_rows
  FROM pragma_table_info('ProductLines')
UNION ALL 
SELECT 'Orders' AS table_name,count(*) AS number_of_attributes, 
(SELECT count(*)  FROM Orders) AS number_of_rows
  FROM pragma_table_info('Orders')
UNION ALL 
SELECT 'OrderDetails' AS table_name,count(*) AS number_of_attributes, 
(SELECT count(*)  FROM OrderDetails) AS number_of_rows
  FROM pragma_table_info('OrderDetails')
UNION ALL 
SELECT 'Payments' AS table_name,count(*) AS number_of_attributes, 
(SELECT count(*)  FROM Payments) AS number_of_rows
  FROM pragma_table_info('Payments')
UNION ALL 
SELECT 'Employees' AS table_name,count(*) AS number_of_attributes, 
(SELECT count(*)  FROM Employees) AS number_of_rows
  FROM pragma_table_info('Employees')
UNION ALL 
SELECT 'Offices' AS table_name,count(*) AS number_of_attributes, 
(SELECT count(*)  FROM Offices) AS number_of_rows
  FROM pragma_table_info('Offices');

  /*Question 1: Which Products Should We Order More of or Less of?*/
 
/*Write a query to compute the low stock for each product using a correlated subquery.

Round down the result to the nearest hundredth (i.e., two digits after the decimal point).
Select productCode, and group the rows.
Keep only the top ten of products by low stock.
*/ 


select * from products;
SELECT p.productCode,p.productName,p.productLine,round((SUM(o.quantityOrdered)/p.quantityInStock),2) AS low_stock
FROM   products p,orderdetails o
WHERE  EXISTS            (SELECT 1
                            FROM orderdetails o
                           WHERE p.productCode=o.productCode)
Group By p.productCode
ORDER BY low_stock DESC
LIMIT 10;
---S700_2466	10.0	9604190.61

--S24_2000	7034.0

---S24_2000	67193.49



/*Write a query to compute the product performance for each product.*/

SELECT productCode,SUM(quantityOrdered*priceEach) AS product_performance
  FROM orderdetails o
 GROUP BY productCode
 ORDER BY productCode DESC
 LIMIT 10;
 
SELECT p.productCode,SUM(o.quantityOrdered*o.priceEach) AS product_performance
 FROM   products p,orderdetails o
WHERE  EXISTS            (SELECT 1
                            FROM orderdetails o
                           WHERE p.productCode=o.productCode)
Group By p.productCode
ORDER BY p.productCode DESC
;

 
 WITH CTE_priority_products AS
 (
 SELECT p.productCode,round((SUM(o.quantityOrdered)/p.quantityInStock),2) AS low_stock
FROM   products p,orderdetails o
WHERE  EXISTS            (SELECT 1
                            FROM orderdetails o
                           WHERE p.productCode=o.productCode)
Group By p.productCode
ORDER BY low_stock DESC
LIMIT 10),

CTE_product_performance AS
(SELECT o.productCode,SUM(o.quantityOrdered*o.priceEach) AS product_performance
  FROM orderdetails o
 GROUP BY o.productCode
 ORDER BY product_performance DESC
)

SELECT pp.productCode,pp.low_stock,cpp.product_performance
  FROM CTE_priority_products pp ,CTE_product_performance cpp
  WHERE pp.productCode=cpp.productCode;
 
 
/*Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior?*/

/*

Write a query to join the products, orders, and orderdetails tables to have customers and products information in the same place.

Select customerNumber.
Compute, for each customer, the profit, which is the sum of quantityOrdered multiplied by priceEach minus buyPrice: SUM(quantityOrdered * (priceEach - buyPrice)).
*/

/*
This query helps you understand the profit contribution of each customer,
which can be useful for tailoring marketing and communication strategies.*/

SELECT o.customerNumber,ROUND(SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)),2)AS PROFIT
FROM orders o,orderdetails od,products p
WHERE o.orderNumber=od.orderNumber
AND   od.productCode=p.productCode
GROUP BY o.customerNumber
ORDER BY o.customerNumber ;



/* Finding the VIP and Less Engaged Customers*/

---The main query selects customer details along with their total profit from the CTE

---VIP customers
WITH CTE_Profit AS
(
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber)
 
SELECT c.contactLastName,c.contactFirstName,c.city,c.country,cp.profit
from customers c, CTE_profit cp
where c.customerNumber=cp.customerNumber
ORDER BY profit DESC
LIMIT 10;

--Least enagaged customers

WITH CTE_Profit AS
(
SELECT o.customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber)
 
SELECT c.contactLastName,c.contactFirstName,c.city,c.country,cp.profit
from customers c, CTE_profit cp
where c.customerNumber=cp.customerNumber
ORDER BY profit 
LIMIT 10;



/*Write a query to compute the average of customer profits using the CTE on the previous screen.*/

/*The result provides a list of customers with their contact information, city, country, and average profit per order.*/

----Question 3: How much can we spend on acquiring new customers?

WITH CTE_Profit AS
(
SELECT o.customerNumber,count(o.customerNumber) AS total_customers,
 SUM(quantityOrdered * (priceEach - buyPrice))  AS  profit
  FROM products p
  JOIN orderdetails od
    ON p.productCode = od.productCode
  JOIN orders o
    ON o.orderNumber = od.orderNumber
 GROUP BY o.customerNumber)
 
SELECT round(AVG(cp.profit),2) AS avg_profit
from customers c, CTE_profit cp
where c.customerNumber=cp.customerNumber;

