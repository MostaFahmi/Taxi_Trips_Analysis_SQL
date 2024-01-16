/****** CREATE Rate Code Table ******/


/**Drop Rate_codes and Trips relationship**/

if exists (select * from sys.foreign_keys
			where name = 'FK_PK_Trips_Rate_Codes'
			and parent_object_id = object_id('Trips'))
alter table Trips drop constraint FK_PK_Trips_Rate_Codes
;



IF EXISTS (SELECT * FROM sys.objects WHERE name = 'Rate_Codes' AND Type='U')
DROP TABLE Rate_Codes
go
CREATE Table Rate_Codes
(
Rate_Code int identity(0,1) Primary Key,
Rate_Name nvarchar(50)
)

go 
INSERT INTO Rate_Codes(Rate_Name)
Values('Unknown'),
	  ('Standard rate'),
	  ('JFK'),
	  ('Newark'),
	  ('Nassau or Westchester'),
	  ('Negotiated fare'),
	  ('Group ride')

SET IDENTITY_INSERT Rate_Codes ON;
INSERT INTO Rate_Codes(Rate_Code,Rate_Name)
values(99,'Unknown')
SET IDENTITY_INSERT Rate_Codes OFF;


/*** re-define Rate_Codes and Trips relationship ***/


if exists (select * from sys.tables
			where name = 'Trips')
ALTER TABLE Trips ADD CONSTRAINT FK_PK_Trips_Rate_Codes foreign key (rate_code) references Rate_Codes(Rate_Code)


/*** INDEX CREATION ***/

--- Rate_Name index


if exists (select * from sys.indexes
			where name = 'Rate_Codes_Rate_Name'
			and object_id = object_id('Rate_Codes'))
drop index Rate_Codes.Rate_Codes_Rate_Name;

create index Rate_Codes_Rate_Name 
	on Rate_Codes(Rate_Name);