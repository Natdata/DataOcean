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

/*Korzystaj�c z tabeli Products oraz Categories wy�wietl nazw� produktu (Products.ProductName) oraz
nazw� kategorii (Categories.CategoryName), do kt�rej nale�y produkt.
Wynik posortuj po nazwie produktu (rosn�co).*/

explain analyze
select p.[ProductName], c.[CategoryName]
from [dbo].[Products] p
join [dbo].[Categories] c
on c.[CategoryID]=p.[CategoryID]
order by p.[ProductName] 

/*Zadanie 2. (*)
Korzystaj�c z tabeli Suppliers, rozbuduj poprzednie tak, aby r�wnie� zaprezentowa� nazw� dostawcy
danego produktu (CompanyName) � kolumn� nazwij SupplierName.
Wynik posortuj malej�co po cenie jednostkowej produktu.*/

select p.[ProductName], c.[CategoryName], s.[CompanyName] as SupplierName
from [dbo].[Products] p
join [dbo].[Categories] c
on c.[CategoryID]=p.[CategoryID]
join [dbo].[Suppliers] s
on p.[SupplierID]=s.[SupplierID]
order by p.[UnitPrice] desc

/*Zadanie 3.
Korzystaj�c z tabeli Products wy�wietl nazwy produkt�w (ProductName) z najwy�sz� cen�
jednostkow� w danej kategorii (UnitPrice).
Wynik posortuj po nazwie produktu (rosn�co).*/


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





/*Korzystaj�c z tabeli Products wy�wietl nazwy produkt�w, kt�rych cena jednostkowa jest wi�ksza ni�
wszystkie �rednie ceny produkt�w wyliczone dla pozosta�ych kategorii (innych ni� ta, do kt�rej nale�y
dany produkt).
Wynik posortuj po cenie jednostkowej (malej�co).*/
select ProductName
from Products p1
where p1.UnitPrice > all (select avg(p2.UnitPrice)
					from Products p2
					where p1.CategoryID != p2.CategoryID
					group by p2.CategoryID )
order by UnitPrice desc

/*
Zadanie 5. (*)
Korzystaj�c z tabeli Order Details, rozbuduj poprzednie zapytanie, tak, aby wy�wietli� r�wnie�
maksymaln� liczb� zam�wionych sztuk (Quantity) danego produktu w jednym zam�wieniu (w danym
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

/*Korzystaj�c z tabel Products oraz Order Details wy�wietl identyfikatory kategorii (CategoryID) oraz
sum� wszystkie warto�ci zam�wie� produkt�w w danego kategorii ([Order Details].UnitPrice * [Order
Details].Quantity) bez uwzgl�dnienia zni�ki. Wynik powinien zawiera� jedynie te kategorie, dla kt�rych
ww. suma jest wi�ksza ni� 200 000.
Wynik posortuj po sumie warto�ci zam�wie� (malej�co).*/

select p.[CategoryID], 
sum(od.UnitPrice * od.Quantity) as suma_warto��_zam�wie�
from Products p
join [dbo].[Order Details] od
on od.[ProductID]=p.[ProductID]
group by p.[CategoryID]
having sum(od.UnitPrice * od.Quantity) > 200000
order by suma_warto��_zam�wie� desc

--Korzystaj�c z tabeli Categories, zaktualizuj poprzednie zapytanie tak, aby zwr�ci�o opr�cz
--identyfikatora kategorii r�wnie� jej nazw�

select c.[CategoryName], p.[CategoryID], 
sum(od.UnitPrice * od.Quantity) as suma_warto��_zam�wie�
from Products p
join [dbo].[Order Details] od
on od.[ProductID]=p.[ProductID]
join [dbo].[Categories] c
on c.CategoryID=p.CategoryID
group by c.[CategoryName], p.[CategoryID]
having sum(od.UnitPrice * od.Quantity) > 200000
order by suma_warto��_zam�wie� desc

/*
Korzystaj�c z tabel Orders oraz Employees wy�wietl liczb� zam�wie�, kt�re zosta�y wys�ane
(ShipRegion) do innych region�w ni� te, w zam�wieniach obs�u�onych przez pracownika Robert King
(FirstName -> Robert; LastName -> King)*/


select count(*)
from Orders o
where not exists (select 1
								from [dbo].[Orders] o1
								join [dbo].[Employees] e2
								on o1.[EmployeeID]=e2.[EmployeeID]
								where e2.[LastName] = 'King' and e2.[FirstName] = 'Robert'
								and o.[ShipRegion]=o1.[ShipRegion])

/*Korzystaj�c z tabeli Orders wy�wietl wszystkie kraje wysy�ki (ShipCountry), dla kt�rych wyst�puj�
rekordy (zam�wienia), kt�re maj� wype�nion� warto�� w polu ShipRegion jak i rekordy z warto�ci�
NULL.*/

select ShipCountry from Orders where [ShipRegion] is null
INTERSECT
select ShipCountry from Orders where [ShipRegion] is not null


/*Korzystaj�c z odpowiednich tabel wy�wietl identyfikator produktu (Products.ProductID), nazw�
produktu (Products.ProductName), kraj i miasto dostawcy (Suppliers.Country, Suppliers.City � nazwij
je odpowiednio: SupplierCountry oraz SupplierCity) oraz kraj i miasto dostawy danego produktu
(Orders.ShipCountry, Orders.ShipCity). Wynik ogranicz do takich produkt�w, kt�re zosta�y wys�ane
cho� raz do tego samego kraju, z kt�rego pochodzi ich dostawca. Dodatkowo wynik rozszerz
o informacj�, czy opr�cz kraju zgadza si� r�wnie� miasto, w kt�rym dostawca produktu ma siedzib�,
z miastem, do kt�rego produkt zosta� wys�any � kolumn� nazwij FullMatch, kt�ra przyjmie warto�ci
Y/N.
Wynik posortuj tak, aby jako pierwsze zosta�y wy�wietlone posortowane alfabetycznie produkty, dla
kt�rych zachodzi pe�na zgodno��*/

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


--Korzystaj�c z tabeli Products zweryfikuj, czy istniej� dwa (lub wi�cej) produkty o tej samej nazwie.
--Zapytanie powinno zwr�ci� w kolumnie DuplicatedProductsFlag warto�� Yes lub No

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
Korzystaj�c z tabel Products oraz Order Details wy�wietl nazwy produkt�w wraz z informacj� na ilu
zam�wieniach pojawi�y si� dane produkty.
Wynik posortuj tak, aby w pierwszej kolejno�ci pojawi�y si� produkty, kt�re najcz�ciej pojawiaj� si�
na zam�wieniach*/

select p.ProductName, count(od.ProductID) as Number
from Products p join [dbo].[Order Details] od
on p.[ProductID]=od.[ProductID]
group by p.ProductName
order by Number desc

/*Korzystaj�c z tabeli Orders rozbuduj poprzednie zapytanie tak, aby powy�sz� analiz� zaprezentowa�
w kontek�cie poszczeg�lnych lat (Orders.OrderDate) � kolumn� nazwij OrderYear.
Tym razem wynik posortuj, tak, aby w pierwszej kolejno�ci wy�wietli� produkty najcz�ciej pojawiaj�ce
si� na zam�wieniach w kontek�cie danego roku, czyli w pierwszej kolejno�ci interesuje nas rok: 1996,
p�niej 1997 itd.*/

select year(o.OrderDate) as OrderYear, p.ProductName, count(*) as Number
from Products p join [dbo].[Order Details] od
on p.[ProductID]=od.[ProductID]
join Orders o
on od.OrderID = o.OrderID
group by year(o.OrderDate), p.ProductName
order by OrderYear, Number desc

/*7
Zadanie 15. (*)
Korzystaj�c z tabeli Suppliers, rozbuduj zapytanie tak, aby dla ka�dego produktu wy�wietli� dodatkowo
nazw� dostawcy danego produktu (Suppliers.CompanyName) � kolumn� nazwij SupplierName.*/

select year(o.OrderDate) as OrderYear, p.ProductName, s.CompanyName as SupplierName, count(*) as Number
from Products p 
join [dbo].[Order Details] od on p.[ProductID]=od.[ProductID]
join Orders o on od.OrderID = o.OrderID
join Suppliers s on p.SupplierID = s.SupplierID
group by year(o.OrderDate), p.ProductName, s.CompanyName
order by OrderYear, Number desc

/*Korzystaj�c z tabeli Products wy�wietl maksymaln� cen� jednostkow� dost�pnych produkt�w
(UnitPrice).*/

select max(UnitPrice)
from Products

/*Korzystaj�c z tabeli Products oraz Categories wy�wietl sum� warto�ci produkt�w w magazynie
(UnitPrice * UnitsInStock) z podzia�em na kategorie (w wyniku uwzgl�dnij nazw� kategorii oraz
produkty przypisane do jakiej� kategorii). Wynik posortuj wg kategorii (rosn�co)*/

select p.CategoryID, c.CategoryName, sum(p.UnitPrice * p.UnitsInStock) as SumWarehouse
from Products p 
join Categories c on p.CategoryID=c.CategoryID
group by p.CategoryID, c.CategoryName
order by p.CategoryID 

/*Rozbuduj zapytanie z zadania 2. tak, aby zaprezentowane zosta�y jedynie kategorie, dla kt�rych
warto�� produkt�w przekracza 10000. Wynik posortuj malej�co wg warto�ci produkt�w.*/

select p.CategoryID, c.CategoryName, sum(p.UnitPrice * p.UnitsInStock) as SumWarehouse
from Products p 
join Categories c on p.CategoryID=c.CategoryID
group by p.CategoryID, c.CategoryName
having sum(p.UnitPrice * p.UnitsInStock) > 10000
order by SumWarehouse desc

/*
Korzystaj�c z tabeli Suppliers, Products oraz Order Details wy�wietl informacje na ilu unikalnych
zam�wieniach pojawi�y si� produkty danego dostawcy. Wyniki posortuj alfabetycznie po nazwie
dostawcy*/

Select s.CompanyName, count(distinct od.OrderID)
from Suppliers s
join Products p on p.SupplierID=s.SupplierID
join [Order Details] od on p.ProductID=od.ProductID
group by s.CompanyName
Order by s.CompanyName

/*2
Korzystaj�c z tabel Orders, Customers oraz Order Details przedstaw �redni�, minimaln� oraz
maksymaln� warto�� zam�wienia (zaokr�glonego do dw�ch miejsc po przecinku, bez uwzgl�dnienia
zni�ki) dla ka�dego z klient�w (Customers.CustomerID). Wyniki posortuj zgodnie ze �redni� warto�ci�
zam�wienia � malej�co. Pami�taj, aby �redni�, minimaln� oraz maksymaln� warto�� zam�wienia
wyliczy� bazuj�c na jego warto�ci, czyli sumie iloczyn�w cen jednostkowych oraz wielko�ci zam�wienia.*/


with cte_suma_zam�wie�
as
(select c.CustomerID, round(sum(od.UnitPrice*od.Quantity), 2) as suma
from [Order Details] od
join Orders o on o.OrderID=od.OrderID
join Customers c on c.CustomerID=o.CustomerID
group by c.CustomerID, o.OrderID)
select CustomerID, avg(suma) as average,
min(suma) as minimum,
max(suma) as maximum
from cte_suma_zam�wie�
group by CustomerID

