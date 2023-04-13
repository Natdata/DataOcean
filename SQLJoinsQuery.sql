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

explain analyze
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


--Korzystaj¹c z tabeli Products zweryfikuj, czy istniej¹ dwa (lub wiêcej) produkty o tej samej nazwie.
--Zapytanie powinno zwróciæ w kolumnie DuplicatedProductsFlag wartoœæ Yes lub No

select ProductName, count(ProductName) as DuplicatedCount,
case when count(ProductName)>1 then 'Yes'
else 'No'
end DuplicatedProductsFlag
from Products
group by ProductName
--having count(ProductName)

with duplicates
as
(select ProductName,
row_number() over (partition by ProductName order by ProductName asc) as rn
from Products)
select ProductName
from duplicates
--where rn > 1 

/*
Zadanie 13.
Korzystaj¹c z tabel Products oraz Order Details wyœwietl nazwy produktów wraz z informacj¹ na ilu
zamówieniach pojawi³y siê dane produkty.
Wynik posortuj tak, aby w pierwszej kolejnoœci pojawi³y siê produkty, które najczêœciej pojawiaj¹ siê
na zamówieniach*/

select p.ProductName, count(od.ProductID) as Number
from Products p join [dbo].[Order Details] od
on p.[ProductID]=od.[ProductID]
group by p.ProductName
order by Number desc

/*Korzystaj¹c z tabeli Orders rozbuduj poprzednie zapytanie tak, aby powy¿sz¹ analizê zaprezentowaæ
w kontekœcie poszczególnych lat (Orders.OrderDate) – kolumnê nazwij OrderYear.
Tym razem wynik posortuj, tak, aby w pierwszej kolejnoœci wyœwietliæ produkty najczêœciej pojawiaj¹ce
siê na zamówieniach w kontekœcie danego roku, czyli w pierwszej kolejnoœci interesuje nas rok: 1996,
póŸniej 1997 itd.*/

select year(o.OrderDate) as OrderYear, p.ProductName, count(*) as Number
from Products p join [dbo].[Order Details] od
on p.[ProductID]=od.[ProductID]
join Orders o
on od.OrderID = o.OrderID
group by year(o.OrderDate), p.ProductName
order by OrderYear, Number desc

/*7
Zadanie 15. (*)
Korzystaj¹c z tabeli Suppliers, rozbuduj zapytanie tak, aby dla ka¿dego produktu wyœwietliæ dodatkowo
nazwê dostawcy danego produktu (Suppliers.CompanyName) – kolumnê nazwij SupplierName.*/

select year(o.OrderDate) as OrderYear, p.ProductName, s.CompanyName as SupplierName, count(*) as Number
from Products p 
join [dbo].[Order Details] od on p.[ProductID]=od.[ProductID]
join Orders o on od.OrderID = o.OrderID
join Suppliers s on p.SupplierID = s.SupplierID
group by year(o.OrderDate), p.ProductName, s.CompanyName
order by OrderYear, Number desc

/*Korzystaj¹c z tabeli Products wyœwietl maksymaln¹ cenê jednostkow¹ dostêpnych produktów
(UnitPrice).*/

select max(UnitPrice)
from Products

/*Korzystaj¹c z tabeli Products oraz Categories wyœwietl sumê wartoœci produktów w magazynie
(UnitPrice * UnitsInStock) z podzia³em na kategorie (w wyniku uwzglêdnij nazwê kategorii oraz
produkty przypisane do jakiejœ kategorii). Wynik posortuj wg kategorii (rosn¹co)*/

select p.CategoryID, c.CategoryName, sum(p.UnitPrice * p.UnitsInStock) as SumWarehouse
from Products p 
join Categories c on p.CategoryID=c.CategoryID
group by p.CategoryID, c.CategoryName
order by p.CategoryID 

/*Rozbuduj zapytanie z zadania 2. tak, aby zaprezentowane zosta³y jedynie kategorie, dla których
wartoœæ produktów przekracza 10000. Wynik posortuj malej¹co wg wartoœci produktów.*/

select p.CategoryID, c.CategoryName, sum(p.UnitPrice * p.UnitsInStock) as SumWarehouse
from Products p 
join Categories c on p.CategoryID=c.CategoryID
group by p.CategoryID, c.CategoryName
having sum(p.UnitPrice * p.UnitsInStock) > 10000
order by SumWarehouse desc

/*
Korzystaj¹c z tabeli Suppliers, Products oraz Order Details wyœwietl informacje na ilu unikalnych
zamówieniach pojawi³y siê produkty danego dostawcy. Wyniki posortuj alfabetycznie po nazwie
dostawcy*/

Select s.CompanyName, count(distinct od.OrderID)
from Suppliers s
join Products p on p.SupplierID=s.SupplierID
join [Order Details] od on p.ProductID=od.ProductID
group by s.CompanyName
Order by s.CompanyName

/*2
Korzystaj¹c z tabel Orders, Customers oraz Order Details przedstaw œredni¹, minimaln¹ oraz
maksymaln¹ wartoœæ zamówienia (zaokr¹glonego do dwóch miejsc po przecinku, bez uwzglêdnienia
zni¿ki) dla ka¿dego z klientów (Customers.CustomerID). Wyniki posortuj zgodnie ze œredni¹ wartoœci¹
zamówienia – malej¹co. Pamiêtaj, aby œredni¹, minimaln¹ oraz maksymaln¹ wartoœæ zamówienia
wyliczyæ bazuj¹c na jego wartoœci, czyli sumie iloczynów cen jednostkowych oraz wielkoœci zamówienia.*/


with cte_suma_zamówieñ
as
(select c.CustomerID, round(sum(od.UnitPrice*od.Quantity), 2) as suma
from [Order Details] od
join Orders o on o.OrderID=od.OrderID
join Customers c on c.CustomerID=o.CustomerID
group by c.CustomerID, o.OrderID)
select CustomerID, avg(suma) as average,
min(suma) as minimum,
max(suma) as maximum
from cte_suma_zamówieñ
group by CustomerID

