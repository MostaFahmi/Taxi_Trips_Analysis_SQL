/************************************/
/*******ANSWERING BUSINESS TASKS*****/

/** VIEW TO JOIN THE TABLES**/
ALTER VIEW VTripsJoinZones AS
(
SELECT 
pickup_datetime, 
dropoff_datetime, 
passenger_count,
trip_distance, 
rc.Rate_Name,
store_and_fwd_flag, 
pt.Payment_Name, 
fare_amount, 
tip_amount, 
tolls_amount, 
airport_fee, 
total_amount,
pickup.borough Pickup_Borough, 
pickup.zone_name Pickup_ZoneName,
dropoff.borough Dropoff_Borough, 
dropoff.zone_name Dropoff_ZoneName,
Revenues
FROM Trips tr
INNER JOIN Zones pickup
ON pickup.Zone_ID = pickup_location_id
INNER JOIN Zones dropoff
ON dropoff.Zone_ID = dropoff_location_id
INNER JOIN Rate_Codes rc
ON rc.Rate_Code = tr.rate_code
INNER JOIN Payment_Types pt
ON pt.Payment_Type = tr.payment_type
)

--Write a query to get the avergae trip distance, average trip fare and total revenue overall provided data and per zone pair

SELECT
Pickup_Borough , Pickup_ZoneName,
ROUND(AVG(trip_distance),2) as Average_Trip_Distance,
ROUND(AVG(fare_amount),2) as Average_Trip_fare,
ROUND(SUM(REVENUES),2) as Total_Revenues
FROM VTripsJoinZones
WHERE Pickup_ZoneName IS NOT NULL
Group By ROLLUP(Pickup_Borough,  Pickup_ZoneName)

--Write a Query to get what hour of the day that has the highest number of trips and 
SELECT *, COUNT(*) as NumberOfTrips
FROM
(
SELECT DATEPART(HOUR, pickup_datetime) AS PickupHour
FROM VTripsJoinZones
) as temp
GROUP BY PickupHour
ORDER BY NumberOfTrips DESC




--average trip price per hour--


SELECT *, 
total_amount/MinutesDuration [PricePerMinute], 
(total_amount*60)/MinutesDuration [PricePerHour],
AVG((total_amount*60)/MinutesDuration) over() as AveragePricePerHour
FROM
(
SELECT dropoff_datetime,pickup_datetime,DATEDIFF(MINUTE,pickup_datetime,dropoff_datetime) as MinutesDuration, total_amount
FROM VTripsJoinZones
) as temp
WHERE MinutesDuration > 0



--What is the most Pickup and Dropoff pair with the highst number of trips?

With Rank AS (
SELECT
Pickup_ZoneName,
Pickup_Borough,
Dropoff_ZoneName,
Dropoff_Borough,
COUNT(*) NoTrips
FROM VTripsJoinZones
GROUP BY 
Pickup_ZoneName,
Pickup_Borough,
Dropoff_ZoneName,
Dropoff_Borough
)
SELECT *,
ROW_NUMBER()over(order by NoTrips desc) Rank
FROM Rank
Order By Rank ASC






--



