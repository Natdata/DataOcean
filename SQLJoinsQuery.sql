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


select ProductName, UnitPrice
from [dbo].[Products] p1
where UnitPrice = (select max(UnitPrice) 
					from [dbo].[Products] p2
					where  p1.CategoryID=p2.CategoryID);

select [ProductName], UnitPrice
from [dbo].[Products] p
join 
(select [CategoryID], max(UnitPrice) max_price
from Products 
group by [CategoryID]) s
on p.CategoryID=s.CategoryID and s.max_price = p.UnitPrice




SELECT p1.ProductName, p1.UnitPrice
FROM [dbo].[Products] p1
JOIN (
    SELECT CategoryID, MAX(UnitPrice) AS max_price
    FROM [dbo].[Products]
    GROUP BY CategoryID
) subquery ON p1.CategoryID = subquery.CategoryID AND p1.UnitPrice = subquery.max_price





/*Korzystaj¹c z tabeli Products wyœwietl nazwy produktów, których cena jednostkowa jest wiêksza ni¿
wszystkie œrednie ceny produktów wyliczone dla pozosta³ych kategorii (innych ni¿ ta, do której nale¿y
dany produkt).
Wynik posortuj po cenie jednostkowej (malej¹co).*/
select ProductName
from Products p1
where p1.UnitPrice > all (select avg(p2.UnitPrice)
					from Products p2
					where p1.CategoryID != p2.CategoryID
					group by p2.CategoryID )
order by UnitPrice desc

/*
Zadanie 5. (*)
Korzystaj¹c z tabeli Order Details, rozbuduj poprzednie zapytanie, tak, aby wyœwietliæ równie¿
maksymaln¹ liczbê zamówionych sztuk (Quantity) danego produktu w jednym zamówieniu (w danym
OrderID*/

select ProductName,
(select max([Quantity])
from [dbo].[Order Details] od
where od.[ProductID]=p1.[ProductID]) as max_quantity
from Products p1
where p1.UnitPrice > all (select avg(p2.UnitPrice)
					from Products p2
					where p1.CategoryID != p2.CategoryID
					group by p2.CategoryID )
order by UnitPrice desc

/*Korzystaj¹c z tabel Products oraz Order Details wyœwietl identyfikatory kategorii (CategoryID) oraz
sumê wszystkie wartoœci zamówieñ produktów w danego kategorii ([Order Details].UnitPrice * [Order
Details].Quantity) bez uwzglêdnienia zni¿ki. Wynik powinien zawieraæ jedynie te kategorie, dla których
ww. suma jest wiêksza ni¿ 200 000.
Wynik posortuj po sumie wartoœci zamówieñ (malej¹co).*/

select p.[CategoryID], 
sum(od.UnitPrice * od.Quantity) as suma_wartoœæ_zamówieñ
from Products p
join [dbo].[Order Details] od
on od.[ProductID]=p.[ProductID]
group by p.[CategoryID]
having sum(od.UnitPrice * od.Quantity) > 200000
order by suma_wartoœæ_zamówieñ desc

--Korzystaj¹c z tabeli Categories, zaktualizuj poprzednie zapytanie tak, aby zwróci³o oprócz
--identyfikatora kategorii równie¿ jej nazwê

select c.[CategoryName], p.[CategoryID], 
sum(od.UnitPrice * od.Quantity) as suma_wartoœæ_zamówieñ
from Products p
join [dbo].[Order Details] od
on od.[ProductID]=p.[ProductID]
join [dbo].[Categories] c
on c.CategoryID=p.CategoryID
group by c.[CategoryName], p.[CategoryID]
having sum(od.UnitPrice * od.Quantity) > 200000
order by suma_wartoœæ_zamówieñ desc

/*
Korzystaj¹c z tabel Orders oraz Employees wyœwietl liczbê zamówieñ, które zosta³y wys³ane
(ShipRegion) do innych regionów ni¿ te, w zamówieniach obs³u¿onych przez pracownika Robert King
(FirstName -> Robert; LastName -> King)*/


select count(*)
from Orders o
where not exists (select 1
								from [dbo].[Orders] o1
								join [dbo].[Employees] e2
								on o1.[EmployeeID]=e2.[EmployeeID]
								where e2.[LastName] = 'King' and e2.[FirstName] = 'Robert'
								and o.[ShipRegion]=o1.[ShipRegion])

/*Korzystaj¹c z tabeli Orders wyœwietl wszystkie kraje wysy³ki (ShipCountry), dla których wystêpuj¹
rekordy (zamówienia), które maj¹ wype³nion¹ wartoœæ w polu ShipRegion jak i rekordy z wartoœci¹
NULL.*/

select ShipCountry from Orders where [ShipRegion] is null
INTERSECT
select ShipCountry from Orders where [ShipRegion] is not null

/*Korzystaj¹c z odpowiednich tabel wyœwietl identyfikator produktu (Products.ProductID), nazwê
produktu (Products.ProductName), kraj i miasto dostawcy (Suppliers.Country, Suppliers.City – nazwij
je odpowiednio: SupplierCountry oraz SupplierCity) oraz kraj i miasto dostawy danego produktu
(Orders.ShipCountry, Orders.ShipCity). Wynik ogranicz do takich produktów, które zosta³y wys³ane
choæ raz do tego samego kraju, z którego pochodzi ich dostawca. Dodatkowo wynik rozszerz
o informacjê, czy oprócz kraju zgadza siê równie¿ miasto, w którym dostawca produktu ma siedzibê,
z miastem, do którego produkt zosta³ wys³any – kolumnê nazwij FullMatch, która przyjmie wartoœci
Y/N.
Wynik posortuj tak, aby jako pierwsze zosta³y wyœwietlone posortowane alfabetycznie produkty, dla
których zachodzi pe³na zgodnoœæ*/

select distinct 
p.[ProductID], 
p.[ProductName], 
s.[Country] as SupplierCountry, 
o.ShipCountry,
s.[City] as SupplierCity,
o.ShipCity,
s.Region,
o.ShipRegion,
CASE WHEN o.[ShipCity]=s.City and isnull(s.[Region], 'null')=isnull(o.ShipRegion,'null') then 'Y'
when o.[ShipCity]=s.City then 'N (the region doesn''t match)'
ELSE 'N'
END FullMatch
FROM Products p join [dbo].[Order Details] od on p.[ProductID]=od.[ProductID]
join [dbo].[Orders] o on o.[OrderID]=od.[OrderID]
join [dbo].[Suppliers] s on p.[SupplierID]= s.[SupplierID]
where s.[Country] = o.[ShipCountry]
Order by FullMatch desc, p.ProductName 





