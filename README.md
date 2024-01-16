# Taxi Trips Analysis Overview

## Trips Table
- Dropped unnecessary columns.
- Ensured correct data types for date columns.
- Removed duplicates based on the unique identifier.
- Handled NULLs, replaced with zeros where applicable.
- Addressed outliers in trip distance and total amount.
- Calculated revenues based on relevant columns.
- Defined foreign key relationships.

## Zones Table
- Removed duplicate records.
- Ensured the uniqueness of primary keys.
- Handled NULL values in critical columns.
- Extracted latitude and longitude from geometry data.

# Business Analysis
- Created a view joining Trips, Zones, Rate_Codes, and Payment_Types.
- Derived insights on average metrics per zone pair.
- Identified the most common pickup hour.
- Analyzed the average trip price per hour.
- Determined popular pickup and dropoff pairs.

