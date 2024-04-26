-------------------------------------------------------
					--Use This Database--
-------------------------------------------------------
use MedicineDB;
go
----------------------------------------------------------------------
				--Inserting Values In CompanyInfo Table--
----------------------------------------------------------------------
insert into companyInfo (companyName)
values ('Square Pharmaceuticals'),
	   ('Beximco Pharmaceuticals'),
	   ('Incepta Pharmaceuticals'),
	   ('ACI Limited'),
	   ('Renata Limited')
go
select * from companyInfo;
----------------------------------------------------------------------
				--Inserting Values In MedicineForm Table--
----------------------------------------------------------------------
insert into medicineForm (formName)
values ('Tablet'),
	   ('Capsule'),
	   ('Pot'),
	   ('Syrup'),
	   ('Drop')
go
select * from medicineForm;
----------------------------------------------------------------------
				--Inserting Values In Medicine Table--
----------------------------------------------------------------------
insert into medicine (medicineName,companyId,formId,MRP,salePrice)
values ('Napa 500',1002,2001,150,120),
	   ('Ace Plus 500',1001,2002,200,160),
	   ('Maxpro 20',1005,2002,600,520),
	   ('Linatab 500',1003,2002,350,300),
	   ('Abecab 20',1004,2001,720,630),
	   ('Calbo-D',1001,2003,340,280),
	   ('Gavisol 200ml',1002,2004,210,170),
	   ('Aristovit-B',1004,2003,270,230),
	   ('Furocef 200ml',1005,2004,250,210),
	   ('Dexpoten 100ml',1005,2004,180,150),
	   ('Biocal-D',1004,2003,210,180),
	   ('Remmo 20',1002,2001,350,310),
	   ('Disopan 1',1003,2001,450,400),
	   ('Kilbac 250',1003,2002,550,480),
	   ('Asyntamax 200ml',1001,2004,250,200)
go
select * from medicine;
select * from stock;
----------------------------------------------------------------------
		--Inserting Values In Purchase Table with procedure--
----------------------------------------------------------------------
execute sp_purchase_insert 3001,18,100,'07-01-23';
execute sp_purchase_insert 3002,15,150,'07-03-23';
execute sp_purchase_insert 3003,12,480,'07-05-23';
execute sp_purchase_insert 3004,20,270,'07-07-23';
execute sp_purchase_insert 3005,16,600,'07-08-23';
execute sp_purchase_insert 3006,14,260,'07-10-23';
execute sp_purchase_insert 3007,25,160,'07-10-23';
execute sp_purchase_insert 3008,12,220,'07-12-23';
execute sp_purchase_insert 3009,10,200,'07-12-23';
execute sp_purchase_insert 3010,10,140,'07-15-23';
execute sp_purchase_insert 3011,12,160,'07-15-23';
execute sp_purchase_insert 3012,20,295,'07-18-23';
execute sp_purchase_insert 3013,14,385,'07-18-23';
execute sp_purchase_insert 3014,11,465,'07-20-23';
execute sp_purchase_insert 3015,15,185,'07-20-23';
go
select * from purchase;
select * from stock;
----------------------------------------------------------------------
		--Inserting Values In Sales Table With Procedure--
----------------------------------------------------------------------
execute sp_sales_insert 3001,6,'08-01-23';
execute sp_sales_insert 3002,5,'08-03-23';
execute sp_sales_insert 3003,7,'08-03-23';
execute sp_sales_insert 3004,8,'08-06-23';
execute sp_sales_insert 3005,4,'08-06-23';
execute sp_sales_insert 3006,5,'08-08-23';
execute sp_sales_insert 3007,7,'08-08-23';
execute sp_sales_insert 3008,9,'08-12-23';
execute sp_sales_insert 3009,3,'08-12-23';
execute sp_sales_insert 3010,5,'08-15-23';
execute sp_sales_insert 3011,8,'08-15-23';
execute sp_sales_insert 3012,9,'08-18-23';
execute sp_sales_insert 3013,6,'08-20-23';
execute sp_sales_insert 3014,9,'08-20-23';
execute sp_sales_insert 3015,5,'08-22-23';
go
select * from sales;
select * from stock;
------------------View All Table---------------------
select * from companyInfo;
select * from medicineForm;
select * from medicine;
select * from stock;
select * from purchase;
select * from sales;
select * from companyAuditLog;
select * from medicineFormMerge;

--------Delete a single Row-----
delete from medicineForm where formId=5;

------------------Count All---------------------------
select count(*) as NumberOfcompany from companyInfo;

------------------Count on column---------------------------
select count(formName) as NumberOfForm from medicineForm;

---------Average------------
select avg(quantity) as averageofquantity from stock;

---------Summetion----------
select sum(quantity) as sumofquantity from stock;

---------Maximum------------
select max(quantity) as maximumofquantity from stock;

---------Minimum------------
select min(quantity) as minimumofquantity from stock;

--------------------Order BY---------------------
select * from medicine order by medicineName asc;
select * from medicine order by medicineName desc;

select m.medicineName,m.salePrice,s.quantity 
from medicine m join stock s on m.medicineId=s.medicineId
order by m.medicineName asc;

select m.medicineName,m.salePrice,s.quantity 
from medicine m join stock s on m.medicineId=s.medicineId
order by m.medicineName desc;

-------------------------Where---------------------------------------------
select ci.companyName,m.medicineName
from medicine m join companyInfo ci on m.companyId=ci.companyId
where ci.companyName='Square Pharmaceuticals'
order by m.medicineName desc;

-------------------------Group By-----------------------------------------
select c.companyName,count(companyName) as Total
from medicine m join companyInfo c on m.companyId=c.companyId
group by c.companyName;

------------------------Having--------------------------------------------
select c.companyName,count(companyName) as Total
from medicine m join companyInfo c on m.companyId=c.companyId
group by c.companyName
having c.companyName='Renata Limited';

-----------------------Roll Up--------------------------------------------
select c.companyName,count(companyName) as Total
from medicine m join companyInfo c on m.companyId=c.companyId
group by c.companyName with rollup;

-----------------------Cube--------------------------------------------
select c.companyName,f.formName,count(companyName) as Total
from medicine m join companyInfo c on m.companyId=c.companyId
join medicineForm f on m.formId=f.formId
group by c.companyName,f.formName with cube;

-------------------Grouping---------------------------------------------
Select medicineId,medicineName, Grouping (medicineId) AS GroupSell From medicine
Group By medicineId,medicineName;

-------------------Grouping sets----------------------------------------
select m.medicineName,c.companyName,f.formName,count(companyName) as Total
from medicine m join companyInfo c on m.companyId=c.companyId
join medicineForm f on m.formId=f.formId
group by grouping sets(m.medicineName,c.companyName,f.formName);

--------------------OVER-----------------------------------------------
select medicineName,salePrice,max(salePrice) over() as maxsaleprice
from medicine;

---------------------------Join Query-------------------------------------
select m.medicineName,c.companyName,f.formName,
	   sum(s.totalPurchasePrice) as totalPurchase,sum(s.totalSalePrice) as totalSales,
       (sum(s.totalSalePrice)-sum(s.totalPurchasePrice)) as [Profit/Loss]
from sales s 
	join medicine m on s.medicineId=m.medicineId
	join companyInfo c on m.companyId=c.companyId
	join medicineForm f on m.formId=f.formId
group by s.medicineId,m.medicineName,c.companyName,f.formName
having s.medicineId=3002;

--------------------------Join Query-------------------------------------
select m.medicineName,c.companyName,f.formName,
	   sum(quantity) as sumofquantity
from purchase p 
	 join medicine m on p.medicineId=m.medicineId
	 join medicineForm f on m.formId=f.formId
	 join companyInfo c on m.companyId=c.companyId
group by m.medicineName,c.companyName,f.formName
having sum(quantity) > 15
order by m.medicineName desc;

----------------------sub query-----------------------------------
select m.medicineName,c.companyName,f.formName,
	sum(s.totalPurchasePrice) as totalPurchase,sum(s.totalSalePrice) as totalSales,
	(sum(s.totalSalePrice)-sum(s.totalPurchasePrice)) as [Profit/Loss]
from sales s join medicine m on s.medicineId=m.medicineId
	join companyInfo c on m.companyId=c.companyId
	join medicineForm f on m.formId=f.formId
group by s.medicineId,m.medicineName,c.companyName,f.formName
having (sum(s.totalSalePrice)-sum(s.totalPurchasePrice))=
	(select min(p.profit)
	from 
		(
		select (sum(s.totalSalePrice)-sum(s.totalPurchasePrice)) as profit,s.medicineId 
		from sales s 
		group by s.medicineId)
		as p
		)
----------------------------Sub Query--------------------------------
select p.medicineId,m.medicineName,max(quantity) as maxofquantity
from medicine m 
	 join purchase p on m.medicineId=p.medicineId
group by m.medicineName,p.medicineId
having max(quantity)=
		(
		select max(quantity) from purchase
		group by medicineId
		having max(quantity)=(select max(quantity) from purchase)
		)

-------------------------Exists-----------------------
select medicineId,medicineName,concat(medicineName,'-',salePrice)
from medicine
where exists
	(select medicineId 
	from sales s 
	where s.medicineId=medicine.medicineId)

---------------------Any------------------------------
select medicineId,medicineName,concat(medicineName,'-',salePrice)
from medicine
where medicineId = any
	(select medicineId 
	from sales s 
	where s.medicineId=medicine.medicineId)

---------------------All------------------------------
select medicineId,medicineName,concat(medicineName,'-',salePrice)
from medicine
where medicineName = all
	(select medicineName 
	from sales s 
	where s.medicineId=medicine.medicineId)

----------------------Union------------------------
select medicineId from medicine
union
select medicineId from purchase

--------------------- CAST CONVERT-------------------
select cast(salesDate as datetime) as castdate,
	   convert(datetime,salesDate) as convertdate
from sales;
----------------------Merge--------------------------
merge into dbo.medicineFormMerge as m
using dbo.medicineForm as f
on m.formId=f.formId
when matched then
update set m.formId=f.formId
when not matched then
insert (formId,formName) values (f.formId,f.formName);

--------------------CASE-------------------------------
select companyId,companyName,
case
when companyName='Square Pharmaceuticals' then 'Better'
when companyName='Beximco Pharmaceuticals' then 'Best'
else 'Good'
end as [Status]
from companyInfo;

--------------------CTE--------------------------------
with cte_summary as
	(
	select m.medicineName,sum(s.totalSalePrice) as sumoftotalsale
	from  sales s join medicine m on s.medicineId=m.medicineId
	group by m.medicineName
	)
select * from cte_summary;

-----------Top 5-----------------
select top 5 * from medicine;

-------------Offset - Fetch First------------
select * from medicine
order by medicineId desc
offset 3 rows 
fetch first 5 rows only

-----------distinct---------------
select distinct companyId from medicine;

---------------And------------
select m.medicineName,c.companyName,m.salePrice 
From medicine m join companyInfo c on m.companyId=c.companyId
Where c.companyName= 'Renata Limited' And salePrice > 150;

---------------OR------------
select m.medicineName,c.companyName,m.salePrice 
From medicine m join companyInfo c on m.companyId=c.companyId
Where c.companyName= 'ACI Limited' or salePrice > 450;

---------------Not ------------
select * from medicine Where not salePrice=120;

------------Between-----------
select * from medicine Where salePrice Between 300 And 500;
select * from purchase where purchaseDate between '07-05-23' and '07-12-23';

--------------Like------------
select * from medicine Where medicineName Like 'A%';
select * from medicine Where medicineName Like '%l';
select * from medicine Where medicineName Like '%-%';

--------------In------------
select c.companyName,m.medicineName,m.salePrice 
from medicine m join companyInfo c on m.companyId=c.companyId
Where c.companyName in ('ACI limited');

--------------Not In------------
select c.companyName,m.medicineName,m.salePrice 
from medicine m join companyInfo c on m.companyId=c.companyId
Where c.companyName not in ('ACI limited');

-----------IIF----------
select medicineId,sum(totalPrice) as sumofpurchase,
iif (sum(totalPrice)>4000,'High','Low') as [range]
from purchase
group by medicineId;

----------Choose---------
select formId,formName,
choose(4,2001,2002,2003,2004,2005) as [newid]
from medicineForm

----------issnul--------
select medicineId,purchaseDate,isnull(purchaseDate,'07-06-2023') as [newdate] from purchase

---------Coalesce-------
select medicineId,purchaseDate,coalesce(purchaseDate,'07-06-2023') as [newdate] from purchase

------------LEN--------------
select medicineId,medicineName,len(medicineName) as Lenthofname From medicine;

------------LTRIM------------
select LTRIM('   Napa 500') as Lefttrimstring;

------------RTRIM------------
select RTRIM('Napa 500     ') as Righttrimstring;

----------SUBSTRING----------
select SUBSTRING(medicineName, 1, 8) as extractString from medicine;

-----------REPLACE-----------
select REPLACE('Napo 500', 'o','a') AS [Replace];

----------REVERSE------------
select REVERSE('REVRES') as [Reverse];

----------CHARINDEX----------
select CHARINDEX('-', 'Aristovit-B') as [Founded];

----------PATINDEX-----------
select PATINDEX('%Ware', 'Software') as Patindexfound;

------------LOWER------------
select LOWER('SQUARE PHARMACEUTICALS') as lowercase;

------------UPPER------------
select UPPER('renata limited') as uppercase;

------------Round-------------
select round(15.6,0);
select round(21.254,0);

-----------Is Numeric----------
select isnumeric(-5.65);
select isnumeric(1.65);
select isnumeric('computer');

-----------Square---------------
select square(5);
select square(7.58);

-----------Getdate-------------
select getdate();

------------Month--------------
select month('2020-06-25');
select datepart(month,'2020-06-25');
select datename(month,'2020-06-25');

---------Row_Number----------
select medicineName, 
Row_Number() over (partition by medicineName order by medicineId ) as medione 
from medicine

------------Rank-------------
select medicineName, 
Rank() over (partition by medicineName order by medicineId ) as medione 
from medicine

---------Dense Rank----------
select medicineName, 
Dense_Rank() over (partition by medicineName order by medicineId ) as medione 
from medicine

------------NTile------------
select medicineName, 
NTile(4) over (partition by medicineName order by medicineId ) as medione 
from medicine
