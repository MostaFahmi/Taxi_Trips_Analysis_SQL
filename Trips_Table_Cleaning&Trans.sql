----------------------------------------------------------
/***************** Cleaning & Transformation***************/
-----------------------Trips_Table------------------------

--- Table Overview---
SELECT TOP(1000) * FROM Trips


/****** DROP UNNECESSARY COLUMNS******/
-- DROP data_file_year, data_file_month

ALTER TABLE trips DROP COLUMN data_file_year, data_file_month



/*** DATA TYPES CHECK ***/


--SELECT *
--FROM Trips
--WHERE ISDATE(pickup_datetime) = 0;

--UPDATE Trips
--SET pickup_datetime = REPLACE(pickup_datetime,'UTC','')

--UPDATE Trips
--SET dropoff_datetime = REPLACE(dropoff_datetime,'UTC','')

ALTER TABLE Trips ALTER COLUMN pickup_datetime datetime
go
ALTER TABLE Trips ALTER COLUMN dropoff_datetime datetime




/*** CHECK DUPLICATES ***/
WITH TripsCTE AS 
( 
SELECT * ,
	ROW_NUMBER() over(partition by _id order by _id) as RN
FROM Trips
)
DELETE
FROM TripsCTE
WHERE RN>1
--32 rows deleted---




/*** CHECK PK NULLS ***/

SELECT * 
FROM Trips
WHERE _id IS NULL OR _id = 0




/**** CHECK DISTINCT VALUES ****/

/** CHECK DISTINCT VALUES OF store_and_fwd_flag **/


SELECT DISTINCT(store_and_fwd_flag)
FROM Trips


/** CHECK DISTINCT VALUES OF rate_code **/


SELECT DISTINCT(rate_code)
FROM Trips


/** CHECK DISTINCT VALUES OF payment_type **/


SELECT DISTINCT(payment_type)
FROM Trips






/** FOR THE AVERAGE CALCULATIONS **/
-- REPLACING NULLS WITH ZEROS FOR (passenger_count, trip_distance, tip_amount, total_amount)
BEGIN TRANSACTION;
UPDATE Trips
SET passenger_count = 0
WHERE passenger_count IS NULL
GO

BEGIN TRANSACTION;
UPDATE Trips
SET trip_distance = 0
WHERE trip_distance IS NULL
GO

BEGIN TRANSACTION;
UPDATE Trips
SET tip_amount = 0
WHERE tip_amount IS NULL
GO

BEGIN TRANSACTION;
UPDATE Trips
SET total_amount = 0
WHERE total_amount IS NULL

-- DELETE TOTAL AMOUNT 0 WHICH TRIPS DID NOT TOOK OFF -- 

DELETE
FROM Trips
WHERE total_amount IS NULL
OR total_amount = 0
/***11 rows deleted**/


/**** CHECK TOTAL AMOUNT OUTLIERS ****/

SELECT MAX(total_amount), MIN(total_amount)
FROM Trips



/****-- CHECK DISTANCE OUTLIERS --***/ 

SELECT MAX(trip_distance), MIN(trip_distance)
FROM Trips
/*** OUTLIERS FOUND(-600)***/

-- Investigating the values before action
SELECT trip_distance, total_amount
FROM Trips
WHERE total_amount < 0
ORDER BY trip_distance ASC


SELECT *
FROM Trips
WHERE trip_distance < 0
ORDER BY trip_distance ASC

-- UPDATING -ve DISTANCE --
BEGIN TRANSACTION;
UPDATE Trips
SET 
trip_distance = ABS(trip_distance), 
fare_amount = ABS(fare_amount),
passenger_count = ABS(passenger_count),
extra = ABS(extra),
mta_tax = ABS(mta_tax),
tip_amount = ABS(tip_amount),
tolls_amount = ABS(tolls_amount),
imp_surcharge = ABS(imp_surcharge),
airport_fee = ABS(airport_fee),
total_amount = ABS(total_amount)

COMMIT;
--ROLLBACK;




/** CHECK passenger_count OUTLIERS **/

SELECT MAX(passenger_count),MIN(passenger_count)
FROM Trips


/****** CALCULATED FIELD ******/

/** ADD REVENUES COLUMN **/

ALTER TABLE Trips ADD Revenues FLOAT

BEGIN TRANSACTION;
UPDATE Trips
SET Revenues = 
total_amount - (airport_fee + tolls_amount + mta_tax )
COMMIT



/****** Defining The Relaionships ******/

ALTER TABLE Trips ADD CONSTRAINT FK_PK_Trips_Zones_pickup foreign key (pickup_location_id) references Zones(_id)
go
ALTER TABLE Trips ADD CONSTRAINT FK_PK_Trips_Zones_dropoff foreign key (dropoff_location_id) references Zones(_id)
go
ALTER TABLE Trips ADD CONSTRAINT FK_PK_Trips_Rate_Codes foreign key (rate_code) references Rate_Codes(Rate_Code)
go
ALTER TABLE Trips ADD CONSTRAINT FK_PK_Trips_Payment_Types foreign key (Payment_type) references Payment_Types(Payment_Type)








