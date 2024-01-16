/****** CREATE Payment Types Table ******/


/**Drop Payment_Types and Trips relationship**/

if exists (select * from sys.foreign_keys
			where name = 'FK_PK_Trips_Payment_Types'
			and parent_object_id = object_id('Trips'))
alter table Trips drop constraint FK_PK_Trips_Payment_Types
;



IF EXISTS (SELECT * FROM sys.objects WHERE name = 'Payment_Types' AND Type='U')
DROP TABLE Payment_Types
go
CREATE Table Payment_Types
(
Payment_Type int identity(0,1) Primary Key,
Payment_Name nvarchar(50)
)

go 

INSERT INTO Payment_Types (Payment_Name)
Values('Unknown'),
	  ('Credit Card'),
	  ('Cash'),
	  ('No Charge'),
	  ('Dispute'),
	  ('Unknown'),
	  ('Voided Trip')

/*** re-define Payment_Types and Trips relationship ***/


if exists (select * from sys.tables
			where name = 'Trips')
ALTER TABLE Trips ADD CONSTRAINT FK_PK_Trips_Payment_Types foreign key (Payment_type) references Payment_Types(Payment_Type)


/*** INDEX CREATION ***/

--- Rate_Name index


if exists (select * from sys.indexes
			where name = 'Payment_Types_Payment_Name'
			and object_id = object_id('Payment_Types'))
drop index Payment_Types.Payment_Types_Payment_Name;

create index Rate_Codes_Rate_Name 
	on Payment_Types(Payment_Name);