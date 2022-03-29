--INTRODUCTORY PROBLEMS

--1: which shippers do we have?
select * from Shippers

--2: certain fields from category
select categoryname, Description from Categories

--3: sales representative
select firstname, lastname, hiredate from employees where title = 'sales representative'

--4: sales Representative in the United States
select firstname, lastname, hiredate from employees where title = 'sales representative' and Country='usa'

--5: orders placed by specific employeeID
select orderid, orderdate from orders where EmployeeID= 5

--6 suppliers and contact titles
select supplierid, contactname, contacttitle from suppliers where ContactTitle not in ('marketing manager')

--7: products with "queso" in product name 
select productid, productname from Products where productname like '%queso%'

--8: orders shipping to France and Belgium
select orderid, customerid, shipcountry from orders where shipcountry in ('france', 'belgium')

--9: orders shipping to any country in Latin America
select orderid, customerid, shipcountry from orders where shipcountry in ('brazil','mexico','argentina','venezuela')

--10/11: emplyees,in order of age
select firstname, lastname, title, convert(date,birthdate) as birthdate from employees order by birthdate 

--12: employees full name
select firstname+' '+lastname as fullname from Employees

--13: order details amount per line item
select orderid, productid, unitprice, quantity, (unitprice * quantity) as Totalprice from [Order Details] order by orderid, ProductID

--14: how many customers?
select COUNT(distinct(customerid)) as 'Total customers' from Customers

--15: when was the first order?
select min(cast(orderdate as date)) as firstorder from Orders

--16: countries where there are customers
select distinct(country) from Customers

--17: contact titles for customers
select ContactTitle, count(contacttitle) as 'No of Customers' from customers group by ContactTitle 
order by [No of Customers] desc

--18: products with associated supplier names
select p.productid, p.productname, s.companyname from products p 
left join suppliers s on s.supplierid = p.supplierid order by ProductID

--19: orders and shippers that was used
select o.orderid, convert(date, o.orderdate) as 'order date', s.companyname from orders o
left join Suppliers s on s.SupplierID = o.ShipVia where o.orderid < 10300

--INTERMEDIATE PROBLES
--20: categories, and total product in each categories
select c.CategoryName, count (p.productID) as 'Total products' from Categories c
join products p on p.CategoryID = c.CategoryID
 group by CategoryName order by [Total products] desc

--21: total customers per country/city
 select country, city, count(customerID) as 'Total No. of Customers' from Customers group by Country, City
 order by [Total No. of Customers] desc

 --22: products that needs reordering
select productID, productname, ReorderLevel, UnitsInStock, (ReorderLevel-UnitsInStock) as 'Quantity Required'
from Products where UnitsInStock < ReorderLevel order by ProductID

--23 products that needs reordring (including units in order and discontinued flag = 0)
select productID, productname, (ReorderLevel-(UnitsInStock+UnitsOnOrder)) as 'Quantity Required'
from Products where (UnitsInStock+UnitsOnOrder) <= ReorderLevel and Discontinued = 0 order by ProductID

--24: customer list by region
select customerid, companyname, Region, case when region is null then 1 else 0 end as 'Region order' 
from Customers order by 'Region order', Region, CustomerID

--25: high freight charges
select top 3 ShipCountry, AVG(freight) as 'AVG Freight' from orders group by ShipCountry order by 'avg freight' desc 

--26: high freight charges for 1998
select top 3 ShipCountry, AVG(freight) as 'AVG Freight' from orders where DATEPART(year,OrderDate) = 1998
group by ShipCountry order by 'avg freight' desc

--28: high freight charges- last year 
select top 3 shipcountry, AVG(freight) as 'AVG Freight' from Orders
where OrderDate>= (select dateadd(year,-1,(select max(orderdate) from Orders))) 
group by ShipCountry order by 'avg freight' desc

--29: inventory list
select o.employeeid, e.lastname, o.orderid, p.productname, od.quantity from Orders o
left join Employees e on e.employeeid = o.EmployeeID
left join [Order Details] od on od.OrderID = o.OrderID
inner join products p on p.ProductID = od.ProductID
order by o.orderid, p.ProductID

--30: customers with no orders
select c.customerid, o.orderid from customers c
left join orders o on o.CustomerID = c.CustomerID 
where orderid is null

--31: customer with no orders for employeeID 4
select c.customerid, o.orderid, o.EmployeeID from Customers c
left join orders o on o.customerid = c.customerid and o.EmployeeID=4
where o.CustomerID is null

--ADVANCE PROBLEMS
--32: high-valued customers
select c.customerid,c.CompanyName,o.orderid, sum(o.Quantity*o.unitprice) as 'Total order amount' from customers c 
left join Orders od on od.customerid = c.CustomerID
join [order details] o on o.orderid = od.orderid
where DATEPART(year,OrderDate) = 1998 
group by c.CustomerID,c.CompanyName, o.OrderID
having sum(o.Quantity*o.unitprice) >= 10000 
order by [Total order amount]

--33: high-valued customers - total orders
select c.customerid,c.CompanyName, sum(o.Quantity*o.unitprice) as 'Total order amount' from customers c 
left join Orders od on od.customerid = c.CustomerID
join [order details] o on o.orderid = od.orderid
where DATEPART(year,OrderDate) = 1998
group by c.CustomerID,c.CompanyName
having sum(o.Quantity*o.unitprice) >= 15000 
order by [Total order amount]

--34: high-valued customers - with discount
select c.customerid,c.CompanyName, sum(o.Quantity*o.unitprice) as 'Total order amount',
sum(o.Quantity*o.unitprice*(1-o.discount)) as 'Total order amount with Discount' from customers c 
left join Orders od on od.customerid = c.CustomerID join [order details] o on o.orderid = od.orderid
where DATEPART(year,OrderDate) = 1998 group by c.CustomerID,c.CompanyName
having sum(o.Quantity*o.unitprice) >= 15000 order by [Total order amount]

--35: month-end orders
select e.EmployeeID, o.OrderID, o.Orderdate from Employees e left join orders o on o.EmployeeID = e.EmployeeID
where o.OrderDate = (select EOMONTH(OrderDate)) order by EmployeeID, OrderID

--36: orders with many line items
select top 10 orderid, count(orderid) as 'Total order Details' from [Order Details] 
group by orderid order by [Total order Details] desc, orderid

--37: orders - random assortment
select top 17 orderid from Orders order by RAND()

--38: orders - accidental double-entry
select orderid, quantity from [Order Details] where Quantity >= 60 group by orderid, Quantity
having COUNT(Quantity) > 1 order by OrderID

--39: orders - accidental double-entry details
select * from [Order Details] where OrderID in (10263,10658,10990,11030) and Quantity >=60 order by orderid,Quantity

--40: orders - accidental double-entry details, derived table
select orderid, quantity from [Order Details] where Quantity >= 60
group by orderid,Quantity having COUNT(Quantity) > 1 order by OrderID

 --41: late orders
select * from orders where DATEDIFF(day,ShippedDate,RequiredDate) <0 

--42: late orders - which employees?
select e.employeeid, e.lastname, e.title, e.hiredate, count(DATEDIFF(day,o.ShippedDate,o.RequiredDate)) as 'total late orders'
from employees e full join orders o on o.EmployeeID=e.EmployeeID where DATEDIFF(day,ShippedDate,RequiredDate) <=0 
group by e.EmployeeID,e.LastName, e.Title, e.HireDate order by [total late orders] desc


--43 - 45: late orders vs total orders, missing employees, fix null
with lateorders(employeeid,lastname,total_late_orders) as 
(select e.employeeid, e.lastname, count(DATEDIFF(day,o.ShippedDate,o.RequiredDate)) as total_late_orders
from employees e full join orders o on o.EmployeeID=e.EmployeeID where DATEDIFF(day,ShippedDate,RequiredDate) <=0 
group by e.EmployeeID,e.LastName)

select o.employeeid, l.lastname, count(o.orderid) as total_orders, l.total_late_orders from orders o
inner join lateorders l on l.employeeid = o.EmployeeID 
group by o.EmployeeID, l.lastname, l.total_late_orders

--46 - 47: late orders vs total orders - percentage
with lateorders(employeeid,lastname,total_late_orders) as 
(select e.employeeid, e.lastname, count(DATEDIFF(day,o.ShippedDate,o.RequiredDate)) as total_late_orders
from employees e full join orders o on o.EmployeeID=e.EmployeeID where DATEDIFF(day,ShippedDate,RequiredDate) <=0 
group by e.EmployeeID,e.LastName)

select o.employeeid, l.lastname, count(o.orderid) as total_orders, l.total_late_orders,
round(cast(l.total_late_orders as float)/COUNT(o.OrderID),2) as percentgae_late_orders  from orders o
inner join lateorders l on l.employeeid = o.EmployeeID group by o.EmployeeID,l.lastname,l.total_late_orders

--48 - 49: customer grouping
select c.customerid, c.companyname, sum(od.unitprice * od.quantity) as 'Total order amount',
case when sum(od.unitprice * od.quantity) < 1000 then 'low'
     when sum(od.unitprice * od.quantity) < 5000 then 'medium'
	 when sum(od.unitprice * od.quantity) < 10000 then 'high'
	 else 'very high' end as 'customer group' from customers c
inner join orders o on o.CustomerID = c.CustomerID inner join [Order Details] od on od.OrderID = o.OrderID
where datepart(year,o.orderdate) =1998 group by c.CustomerID, c.CompanyName order by c.CustomerID

--50: customer grouping in percentage
with customergroup (customerid,companyname,[total order amount], [customer group])
as(
select c.customerid, c.companyname, sum(od.unitprice * od.quantity) as 'Total order amount',
case when sum(od.unitprice * od.quantity) < 1000 then 'low'
     when sum(od.unitprice * od.quantity) < 5000 then 'medium'
	 when sum(od.unitprice * od.quantity) < 10000 then 'high'
	 else 'very high' end as 'customer group' from customers c
inner join orders o on o.CustomerID = c.CustomerID inner join [Order Details] od on od.OrderID = o.OrderID
where datepart(year,o.orderdate) =1998 group by c.CustomerID, c.CompanyName)

select [customer group], count([customer group] ) as 'count of group',
convert(numeric,count([customer group]))/(select COUNT(customerid) from customergroup) as 'percentage in group'
from customergroup group by [customer group]

--51
--missing Table(Customergroup threshold)

--52: countries with suppliers or customers
select distinct(country) from Customers
union
select distinct(country) from Suppliers

--53: countries with suppliers or customers, version 2
select c.country as 'customer country', s.country as 'supplier country' from customers c
full join Suppliers s on s.country= c.Country group by c.Country, s.Country

--54: countries with suppliers or customers with total number of customers and suppliers
select count(c.customerid) as 'total customers', count(s.supplierid) as 'total suppliers', 
case when c.country is null then s.Country 
else c.Country end as country from customers c
full join suppliers s on s.country = c.country group by c.country,s.country order by country

--55: first order in each country
with minorderdate (shipcountry, orderid,customerid,orderdate,[row number by country]) as (
select shipcountry,orderid,CustomerID,convert(date,orderdate) as 'orderdate', 
row_number() over(partition by shipcountry order by shipcountry, orderid) as 'row number by country'  from orders)

select shipcountry, orderid, customerid, orderdate from minorderdate where [row number by country] = 1 order by shipcountry

--56: customers with multiple orders in 5 day period
select i.customerid, i.orderid as 'initial order', i.orderdate as 'initial date', n.orderid as 'next order', n.orderdate as 'next date'
from orders i join Orders n on n.CustomerID = i.CustomerID  where i.OrderID < n.OrderID and datediff(DAY,i.orderdate, n.orderdate) <= 5
order by i.CustomerID, i.OrderID

--57: customers with multiple orders in 5 day period with days between orders
with orderdiff (customerid, [initial order], [initial date], [next order], [next date] ) as (
select i.customerid, i.orderid as 'initial order',CONVERT(date, i.orderdate) as 'initial date', n.orderid as 'next order', 
convert(date,n.orderdate) as 'next date' from orders i join Orders n on n.CustomerID = i.CustomerID 
where i.OrderID < n.OrderID and datediff(DAY,i.orderdate, n.orderdate) <= 5)

select customerid, [initial date], [next date], DATEDIFF(day, [initial date], [next date]) as 'days between orders'
 from orderdiff order by customerid
