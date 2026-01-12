/*
===============================================================================
CYCLISTIC BIKE SHARE - INITIAL DATA EXPLORATION
===============================================================================

Project: Cyclistic Bike Share 2024 Trip Data Analysis
Dataset: `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`

Purpose: Comprehensive data quality assessment and exploration before cleaning
- Validate data structure and types
- Identify missing values and completeness issues
- Check for duplicates and data consistency
- Validate business logic (trip durations, categories)
- Document findings to inform cleaning strategy

===============================================================================
*/

-- =============================================================================
-- 1. DATA STRUCTURE VALIDATION
-- =============================================================================

-- Check table schema and data types
-- Expected: ride_id (STRING), timestamps (TIMESTAMP), coordinates (FLOAT), etc.
SELECT column_name, data_type
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'cyclistic_2024_all_trips';

-- =============================================================================
-- 2. DATA COMPLETENESS ANALYSIS
-- =============================================================================

-- Count null values across all columns using COUNTIF for efficiency
-- Results: start_station_name/start_station_id nulls: 1,073,951 (18.325%), end_station_name/end_station_id nulls: 1,104,653 (18.85%),
-- end_lat/end_lng nulls: 7232 (0.124%)
SELECT 
  COUNTIF(ride_id IS NULL) AS null_ride_id,
  COUNTIF(rideable_type IS NULL) AS null_rideable_type,
  COUNTIF(started_at IS NULL) AS null_started_at,
  COUNTIF(ended_at IS NULL) AS null_ended_at,
  COUNTIF(start_station_name IS NULL) AS null_start_station_name,
  COUNTIF(start_station_id IS NULL) AS null_start_station_id,
  COUNTIF(end_station_name IS NULL) AS null_end_station_name,
  COUNTIF(end_station_id IS NULL) AS null_end_station_id,
  COUNTIF(start_lat IS NULL) AS null_start_lat,
  COUNTIF(start_lng IS NULL) AS null_start_lng,
  COUNTIF(end_lat IS NULL) AS null_end_lat,
  COUNTIF(end_lng IS NULL) AS null_end_lng,
  COUNTIF(member_casual IS NULL) AS null_member_casual
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`;

-- =============================================================================
-- 3. DATA INTEGRITY CHECKS
-- =============================================================================

-- Check for duplicate ride_ids (should be unique primary key)
-- Results: Total: 5,860,568, Distinct:5,860,357, Duplicates: 211
SELECT 
  COUNT(ride_id) AS total_records, 
  COUNT(DISTINCT ride_id) AS distinct_ids,
  COUNT(ride_id) - COUNT(DISTINCT ride_id) AS duplicate_ids
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`;

-- =============================================================================
-- 4. FIELD-SPECIFIC VALIDATION
-- =============================================================================

-- RIDE_ID: Verify consistent length (expected: 16 characters)
-- Results: All 5,860,568 records have 16 characters
SELECT LENGTH(ride_id) AS length_ride_id, COUNT(ride_id) AS number_of_rows
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
GROUP BY length_ride_id;

-- RIDEABLE_TYPE: Check valid bike types and distribution
-- Expected: classic_bike, electric_bike, electric_scooter
-- Results: classic_bike: 2,735,636 (46.68%), electric_bike: 2,980,595 (50.86%), electric_scooter: 144,337 (2.46%)
SELECT DISTINCT rideable_type, COUNT(rideable_type) AS number_of_trips
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
GROUP BY rideable_type;

-- MEMBER_CASUAL: Verify user types and distribution
-- Expected: member, casual
-- Results: member: 3,708,910 (63.29%), casual: 2,151,658 (36.71%)
SELECT DISTINCT member_casual, COUNT(member_casual) AS number_of_trips_by_membership
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
GROUP BY member_casual;

-- =============================================================================
-- 5. TIMESTAMP VALIDATION
-- =============================================================================

-- Sample timestamp format validation
-- Expected format: YYYY-MM-DD HH:MM:SS UTC
SELECT started_at, ended_at
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
LIMIT 10;

-- BUSINESS LOGIC: Find trips longer than 24 hours (potential errors)
-- Long trips may indicate system errors, forgotten returns, or theft
-- Results: 7596 entries longer than a day (0.13%)
SELECT COUNT(*) AS entries_longer_than_day
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
WHERE (
  EXTRACT(HOUR FROM (ended_at - started_at)) * 60 +
  EXTRACT(MINUTE FROM (ended_at - started_at)) +
  EXTRACT(SECOND FROM (ended_at - started_at)) / 60) >= 1440;

-- BUSINESS LOGIC: Find very short trips (under 1 minute)
-- May indicate false starts, docking issues, or system testing
-- Results: 132,644 entries shorter than a minute (2.26%)
SELECT COUNT(*) AS entries_shorter_than_a_minute
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
WHERE (
  EXTRACT(HOUR FROM (ended_at - started_at)) * 60 +
  EXTRACT(MINUTE FROM (ended_at - started_at)) +
  EXTRACT(SECOND FROM (ended_at - started_at)) / 60) <= 1;

-- =============================================================================
-- 6. STATION DATA ANALYSIS
-- =============================================================================

-- Explore unique start stations (for data dictionary reference)
SELECT DISTINCT start_station_name
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
ORDER BY start_station_name;

-- Count records missing start station information
-- High numbers may indicate dockless bikes or system expansion areas
-- Results: 1,073,951 entries missing start station name or id (18.325%)
SELECT COUNT(ride_id) AS null_start_name_and_ids
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
WHERE start_station_id IS NULL OR start_station_name IS NULL;

-- Explore unique end stations (for data dictionary reference)
SELECT DISTINCT end_station_name
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
ORDER BY end_station_name;

-- Count records missing end station information
-- Results: 1,104,653 records missing end station name or id (18.85%)
SELECT COUNT(ride_id) AS null_end_name_and_ids
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
WHERE end_station_id IS NULL OR end_station_name IS NULL;

-- =============================================================================
-- 7. GEOLOCATION DATA VALIDATION
-- =============================================================================

-- Count records missing start coordinates
-- Should be much lower than missing station names (GPS vs station data)
-- Results: 0 records missing start coordinates
SELECT COUNT(ride_id) AS start_location_missing
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
WHERE start_lat IS NULL OR start_lng IS NULL;

-- Count records missing end coordinates
-- Results: 7232 records missing end coordinates (0.124%)
SELECT COUNT(ride_id) AS end_location_missing
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
WHERE end_lat IS NULL OR end_lng IS NULL;

/*
===============================================================================
EXPLORATION SUMMARY
===============================================================================

DATASET OVERVIEW:
- Total Records: 5,860,568
- Date Range: [January 2024 - December 2024]
- Primary Key: ride_id (unique identifier)

KEY FINDINGS:
□ Data Types: All columns have expected data types
□ Duplicates: 211 duplicate ride_ids found
□ Missing Station Data: 18.325% start stations, 18.85% end stations missing
□ Missing Coordinates: 0% start coords, 0.124% end coords missing  
□ Trip Duration Issues: 7596 trips >24hrs, 132,644 trips <1min
□ Bike Types: classic_bike: 2,735,636 (46.68%), electric_bike: 2,980,595 (50.86%), electric_scooter: 144,337 (2.46%)
□ User Distribution: 63.29% members vs 36.71% casual riders

IMPLICATIONS FOR ANALYSIS:
- Station data gaps may limit station-based analysis
- Duration outliers need filtering for meaningful insights
- Coordinate data sufficient for geographic analysis
- User type distribution adequate for comparative analysis

CLEANING GOALS:
1. Filter unrealistic trip durations (< 1 minute or > 24 hours) 
2. Remove records missing critical station information (names/coordinates) 
3. Add calculated columns for analysis: trip_duration, day_of_week, month 
4. Handle missing end coordinates and station IDs
5. Set primary key constraints for data integrity 

NEXT STEPS:
□ Implement comprehensive data cleaning script
□ Document filtering criteria and business rules  
□ Validate cleaned dataset completeness and quality
□ Calculate data loss percentage and assess impact
□ Create analysis-ready dataset with enhanced columns
□ Begin exploratory data analysis on clean dataset

===============================================================================
*/
