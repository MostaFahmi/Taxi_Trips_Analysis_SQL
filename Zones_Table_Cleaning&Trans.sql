----------------------------------------------------------
/***************** Cleaning & Transformation***************/
-----------------------Trips_Table------------------------

/** Table Overview**/
SELECT * FROM Zones



/** CHECK DUPLICATES**/

WITH ZonesCTE AS (
SELECT *,
	ROW_NUMBER()over(partition by _id,zone_name,borough order by _id) as RN
FROM Zones
)
DELETE
FROM ZonesCTE
WHERE RN > 1
--**22 rows deleted**


/** CHECK PK NULLS **/
BEGIN TRANSACTION
DELETE
FROM Zones
WHERE _id IS NULL
-- ONE ROW AFFECTED
COMMIT


/** CHECK zone_names AND borough  NULLS **/

SELECT * 
FROM Zones
WHERE zone_name IS NULL 
AND borough IS NULL



-- Investigating the geometry values found in the field before any action

SELECT *
FROM Zones
WHERE zone_name like '%7%'

-- Delete the 13 records
BEGIN TRANSACTION
DELETE
FROM Zones
WHERE zone_name like '%7%'


/****** CALCULATED FIELD ******/

/** ADDING LATITUDE & LONGITUDE COLUMNS **/

ALTER TABLE Zones ADD latitude FLOAT
ALTER TABLE Zones ADD longitude FLOAT

ALTER TABLE Zones ALTER COLUMN latitude nvarchar(100)
go
ALTER TABLE Zones ALTER COLUMN longitude nvarchar(100)

-- SPLITTING zones_geom first Vertex to lat & long fields

--/**FILLING LATITUDE
BEGIN TRANSACTION;
UPDATE Zones
SET latitude = 
SUBSTRING(zone_geom,CHARINDEX('((',zone_geom)+2,CHARINDEX('.',zone_geom))
COMMIT


BEGIN TRANSACTION;
UPDATE Zones
SET latitude = replace(latitude,'(','') 
COMMIT

BEGIN TRANSACTION;
UPDATE Zones
SET latitude = replace(latitude,' ','') 
COMMIT



--/**FILLING LONGITUDE
BEGIN TRANSACTION;
UPDATE Zones
SET longitude = 
SUBSTRING(zone_geom,CHARINDEX(' ',zone_geom)+1,CHARINDEX('.',zone_geom))
COMMIT


BEGIN TRANSACTION;
UPDATE Zones
SET longitude = 
replace(longitude,',','')
COMMIT


ALTER TABLE ZONES ALTER COLUMN LATITUDE FLOAT
go 
ALTER TABLE ZONES ALTER COLUMN LONGITUDE FLOAT
go
ALTER TABLE ZONES ADD Constraint PK_Zones  Primary Key(_id)


/***** Complying with Foreign Key Constraint ****/

BEGIN TRANSACTION
INSERT INTO ZONES(_id)
SELECT DISTINCT(dropoff_location_id)
FROM Trips
WHERE dropoff_location_id NOT IN (SELECT _id FROM Zones)
COMMIT

sp_rename 'Zones._id', 'Zone_ID', 'COLUMN'
