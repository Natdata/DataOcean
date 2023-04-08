use [NORTHWIND-SQL]
go

select c.[CustomerID], (select [CompanyName] from [dbo].[Customers] as b where c.[CustomerID] = b.[CustomerID]) as company_name,
count(*) as order_counts
from [dbo].[Orders] o
join [dbo].[Customers] c
on c.[CustomerID] = o.[CustomerID]
where (datepart(year, OrderDate) *100 + datepart(MM, OrderDate)) between 199705 and 199806
group by c.[CustomerID]
having count(*) > 10
order by order_counts desc

/*Korzystaj¹c z tabeli Products oraz Categories wyœwietl nazwê produktu (Products.ProductName) oraz
nazwê kategorii (Categories.CategoryName), do której nale¿y produkt.
Wynik posortuj po nazwie produktu (rosn¹co).*/

select p.[ProductName], c.[CategoryName]
from [dbo].[Products] p
join [dbo].[Categories] c
on c.[CategoryID]=p.[CategoryID]
order by p.[ProductName] 

/*Zadanie 2. (*)
Korzystaj¹c z tabeli Suppliers, rozbuduj poprzednie tak, aby równie¿ zaprezentowaæ nazwê dostawcy
danego produktu (CompanyName) – kolumnê nazwij SupplierName.
Wynik posortuj malej¹co po cenie jednostkowej produktu.*/

select p.[ProductName], c.[CategoryName], s.[CompanyName] as SupplierName
from [dbo].[Products] p
join [dbo].[Categories] c
on c.[CategoryID]=p.[CategoryID]
join [dbo].[Suppliers] s
on p.[SupplierID]=s.[SupplierID]
order by p.[UnitPrice] desc

/*Zadanie 3.
Korzystaj¹c z tabeli Products wyœwietl nazwy produktów (ProductName) z najwy¿sz¹ cen¹
jednostkow¹ w danej kategorii (UnitPrice).
Wynik posortuj po nazwie produktu (rosn¹co).*/

with t1 as (select c.[CategoryName],p.[ProductName],
max([UnitPrice]) as max_unitprice
from [dbo].[Products] p
join [dbo].[Categories] c
on c.[CategoryID]=p.[CategoryID]
group by  c.[CategoryName], [ProductName])
select ProductName, max(max_unitprice)
from t1
group by [CategoryName]

