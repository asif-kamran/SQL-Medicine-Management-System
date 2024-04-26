---------------------------------------------------------------
			----create database----
---------------------------------------------------------------
use master
go
drop database if exists MedicineDB;
go
Create database MedicineDB
on primary
(
	name= 'MedicineDB_data_1',
	FileName='C:\Program Files\Microsoft SQL Server\MSSQL14.KAMRAN\MSSQL\DATA\MedicineDB_data_1.mdf',
	Size=25mb,
	Maxsize=100mb,
	FileGrowth=5%
)
log on
(
	name='MedicineDB_Log_1',
	FileName='C:\Program Files\Microsoft SQL Server\MSSQL14.KAMRAN\MSSQL\DATA\MedicineDB_Log_1.Ldf',
	Size=2mb,
	Maxsize=25mb,
	FileGrowth=1%
)
go
--------------------------------------------------------------------
			---use this database---
--------------------------------------------------------------------
use MedicineDB;
go
-----------------------------Table Create----------------------------

-------------------------------------------------------
				--companyInfo--
-------------------------------------------------------
drop table if exists companyInfo;
go
create table companyInfo
(
	companyId int primary key identity(1001,1),
	companyName varchar(50) not null unique,
	createDate datetime default current_timestamp,
);
print ('Succesfully created');
go
--------------------------------------------------------
				--medicineForm--
--------------------------------------------------------
drop table if exists medicineForm;
go
create table medicineForm
(
	formId int primary key identity(2001,1),
	formName varchar(50) not null unique,
	createDate datetime default current_timestamp
);
print ('Succesfully created');
go
--------------------------------------------------------
				--medicine--
--------------------------------------------------------
drop table if exists medicine;
go
create table medicine
(
	medicineId int primary key identity(3001,1),
	medicineName varchar(50) not null unique,
	companyId int references companyInfo(companyId),
	formId int references medicineForm(formId),
	MRP money not null,
	salePrice money not null,
	createDate datetime default current_timestamp
);
print ('Succesfully created');
go
--------------------------------------------------------
				--stock--
--------------------------------------------------------
drop table if exists stock;
go
create table stock
(
	stockId int primary key identity(4001,1),
	medicineId int references medicine(medicineId),
	quantity int not null default 0,
	unitPrice money not null default 0,
	createDate datetime not null default current_timestamp
);
print ('Succesfully created');
go
--------------------------------------------------------
					--purchase--
--------------------------------------------------------
drop table if exists purchase;
create table purchase
(
	purchaseId int primary key identity(5001,1),
	medicineId int references medicine(medicineId),
	quantity int not null default 0,
	unitPrice money not null default 0,
	totalPrice money not null,
	purchaseDate date not null,
	createdate datetime not null default current_timestamp
);
print ('Succesfully created');
go
--------------------------------------------------------
					--sales--
--------------------------------------------------------
drop table if exists sales;
create table sales
(
	salesId int primary key identity(6001,1),
	medicineId int references medicine(medicineId),
	quantity int not null default 0,
	unitSalePrice money not null,
	totalSalePrice money not null,
	unitPurchasePrice money not null,
	totalPurchasePrice money not null,
	salesDate date not null,
	createdate datetime not null default current_timestamp
);
print ('Succesfully created');
go
-------------------------------------------------------
				--Creating Table for Merge--
-------------------------------------------------------
drop table if exists medicineFormMerge;
go
create table medicineFormMerge
(
	formId int,
	formName varchar(50),
)
go
print ('Succesfully created');
go
-----------------------------Index-------------------------------

-----create Non-Clustered Index----
create nonclustered index in_companyName
on companyInfo(companyName);

-----create Clustered Index--------
create clustered index in_form
on medicineFormMerge(formId);

-----------------------------Alter table---------------------------

---------Add a Column----------
alter table companyInfo 
add descriptions varchar (50);

---------Drop Column------------
alter table companyInfo 
drop column descriptions;

---------Drop Table-------------
drop table companyInfo;
drop table medicineForm;
drop table medicine;
drop table stock;
drop table purchase;
drop table sales;
drop table medicineFormMerge;
--------------------------------------------------------------------
					--Creating View--
--------------------------------------------------------------------
drop view if exists vi_companyinfo;
go
create view vi_companyinfo
as
	select m.medicineName,c.companyName,f.formName
	from medicine m 
	join companyInfo c on m.companyId=c.companyId
	join medicineForm f on m.formId=f.formId;
go
------show view------
select * from dbo.vi_companyinfo;
---------------------------------------------------------------------
					--Creating Encryption View--
---------------------------------------------------------------------
drop view if exists vi_companyinfo_E;
go
create view vi_companyinfo_E
with encryption
as
	select m.medicineName,c.companyName,f.formName
	from medicine m 
	join companyInfo c on m.companyId=c.companyId
	join medicineForm f on m.formId=f.formId
	where c.companyName='square';
go
------show Encryption view------
select * from dbo.vi_companyinfo_E;
---------------------------------------------------------------------
					--Creating Schemabinding View--
---------------------------------------------------------------------
drop view if exists vi_companyinfo_S;
go
create view vi_companyinfo_S
with schemabinding
as
	select m.medicineName,c.companyName,f.formName
	from dbo.medicine m 
	join dbo.companyInfo c on m.companyId=c.companyId
	join dbo.medicineForm f on m.formId=f.formId
	where f.formName='Tablet';
go
------show Schemabinding view------
select * from dbo.vi_companyinfo_S;

--------------------------------------------------------------------------
				--stored procedure sales insert--
--------------------------------------------------------------------------
drop procedure if exists sp_sales_insert;
go
create procedure sp_sales_insert
(
	@medicineId int,
	@quantity int,
	@salesDate date
)
as
	begin
		declare @unitSalePrice money,@unitPurchasePrice money,@totalUnitSalePrice money,
				@totalUnitPurchasePrice money
		select @unitSalePrice=medicine.salePrice from medicine
		where medicine.medicineId=@medicineId
		select @unitPurchasePrice=stock.unitPrice from stock
		where stock.medicineId=@medicineId
		select @totalUnitSalePrice=@quantity*@unitSalePrice,
			   @totalUnitPurchasePrice=@quantity*@unitPurchasePrice
		insert into sales (medicineId,quantity,unitSalePrice,totalSalePrice,unitPurchasePrice,
						totalPurchasePrice,salesDate)
		values (@medicineId,@quantity,@unitSalePrice,@totalUnitSalePrice,
				@unitPurchasePrice,@totalUnitPurchasePrice,@salesDate)
	end
go
--------------------------------------------------------------------------
					--stored pocedure purchase insert--
--------------------------------------------------------------------------
drop procedure if exists sp_purchase_insert;
go
create procedure sp_purchase_insert
(
	@medicineId int,
	@quantity int,
	@unitPurchasePrice money,
	@purchaseDate date
)
as
	BEGIN
		declare @totalPurchasePrice money
		select @totalPurchasePrice=@quantity*@unitPurchasePrice
		insert into purchase (medicineId,quantity,unitPrice,totalPrice,purchaseDate)
		values (@medicineId,@quantity,@unitPurchasePrice,@totalPurchasePrice,@purchaseDate)
	END
go
-----------------------------------------------------------------------------
				--stored procedure select insert update delete--
-----------------------------------------------------------------------------
drop procedure if exists sp_SIUD;
go
create procedure sp_SIUD
(
	@companyId int,
	@companyName varchar(50),
	@statementType varchar(50)=''
)
as
	if @statementType='select'
	begin
		select * from companyInfo
	end
	if @statementType='insert'
	begin
		insert into companyInfo(companyName)
		values (@companyName)
	end
	if @statementType='update'
	begin
		update companyInfo
		set companyName=@companyName
		where companyId=@companyId
	end
	if @statementType='delete'
	begin
		delete from companyInfo
		where companyId=@companyId
	end
go
--------------------------------------------------------------------------
					--procedure output parameter--
--------------------------------------------------------------------------
drop procedure if exists sp_output;
go
create procedure sp_output
(@formId int output)
as
	begin
		select count(formId)
		from medicineForm
	end
go
------------------------------------------------------------------------------
					--procedure return--
------------------------------------------------------------------------------
drop procedure if exists sp_return;
go
create procedure sp_return
(@formId int )
as
	begin
		select formId,formName 
		from medicineForm
		where formId=@formId
	end
go
---------------------------------------------------------------------------
					--procedure without parameter--
---------------------------------------------------------------------------
drop procedure if exists sp_show_product;
go
create procedure sp_show_product
as
	begin
		select m.medicineName,s.quantity,m.salePrice
		from medicine m join stock s on m.medicineId=s.medicineId
		where s.quantity>0
	end
go
-------------------------------------------------------------------------
				--Creating Table Value Function--
-------------------------------------------------------------------------
drop function if exists fn_companyInfo;
go
create function fn_companyInfo
()
returns table
as
return
(
	select m.medicineName,c.companyName,f.formName
	from medicine m 
	join companyInfo c on m.companyId=c.companyId
	join medicineForm f on m.formId=f.formId
	where c.companyName='square'
)
go
-----Show Function------
select * from dbo.fn_companyInfo();
go
---------------------------------------------------------------------------
				--Creating Scaler Value Function---
---------------------------------------------------------------------------
drop function if exists fn_form_info;
go
create function fn_form_info
()
returns int
as
	begin
		declare @c int
		select @c = count(*) from companyInfo
		return @c
	end;
go
-----Show Function------
select dbo.fn_form_info();
go
--------------------------------------------------------------------------
				--Creating Multistatement Function---
--------------------------------------------------------------------------
drop function if exists fn_new_stock;
go
create function fn_new_stock()
returns @newstock table
	(
	medicineId int,
	quantity int,
	quantity_extent int
	)
as
	begin
		insert into @newstock (medicineId,quantity,quantity_extent)
		select medicineId,quantity,quantity=quantity+10
		from stock
		return
	end;
go
-----Show Function------
select * from dbo.fn_new_stock();
go
-------------------------------------------------------------------------
			--After Trigger insert medicine Then stock--
-------------------------------------------------------------------------
drop trigger if exists tr_insert_medicine_stock;
go
create trigger tr_insert_medicine_stock
on medicine
after insert
as
	insert into stock(medicineId)
	select medicineId
	from inserted
go
-------------------------------------------------------------------------
			--After Trigger insert Purchase Update stock--
-------------------------------------------------------------------------
drop trigger if exists tr_insert_purchase_stock;
go
create trigger tr_insert_purchase_stock
on purchase
after insert
as
begin
declare @stockUnit int,@purchaseUnit int,@medicineId int,@unitPrice money,@currentPrice money
	select @unitPrice=inserted.unitPrice,@medicineId=inserted.medicineId,@purchaseUnit=inserted.quantity from inserted
	select @currentPrice=stock.unitPrice,@stockUnit=stock.quantity from stock,inserted where stock.medicineId=inserted.medicineId
	if @currentPrice>0
	begin
		select @currentPrice=(@currentPrice+@unitPrice)/2
	end
	else
	begin
		select @currentPrice=@unitPrice
	end
	update stock set quantity=@stockUnit+@purchaseUnit,unitPrice=@currentPrice
	where medicineId=@medicineId
end
go
-------------------------------------------------------------------------
			--After Trigger insert Sales Update stock--
-------------------------------------------------------------------------
drop trigger if exists tr_insert_Sales_stock;
go
create trigger tr_insert_Sales_stock
on sales
after insert
as
begin
declare @stockUnit int,@salesQuantity int,@medicineId int
	select @medicineId=inserted.medicineId,@salesQuantity=inserted.quantity 
	from inserted
	select @stockUnit=stock.quantity 
	from stock,inserted 
	where stock.medicineId=inserted.medicineId
	update stock set quantity=@stockUnit-@salesQuantity
	where medicineId=@medicineId
end
go
-------------------------------------------------------------------------
			--Instead of Delete Trigger--
-------------------------------------------------------------------------
drop table if exists companyAuditLog;
go
create table companyAuditLog
(
	logId int primary key identity (1,1),
	companyId int,
	actionLog varchar (50),
	actionBy varchar(50),
	actionTime datetime 
)
drop trigger if exists tr_company_audit;
go
create trigger tr_company_audit
on companyInfo
instead of delete
as
	begin
		declare @companyId int
		select @companyId=deleted.companyId
		from deleted
	if @companyId=1001
		begin
			raiserror ('Id 1001 cannot be delete',16,1)
			rollback
			insert into companyAuditLog
			values (@companyId,'Record cannot be delete',suser_name(),getdate())
		end
	else
		begin
			delete from companyInfo
			where companyId=@companyId
			insert into companyAuditLog
			values (@companyId,'Instead of delete',suser_name(),getdate())
		end
	end
go
---instead of delete trigger test----
delete from companyInfo where companyId=1001;
select * from companyInfo;
select * from companyAuditLog;
