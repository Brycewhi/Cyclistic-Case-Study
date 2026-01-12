/*
===============================================================================
CYCLISTIC BIKE SHARE - DATA CLEANING
===============================================================================

Project: Cyclistic Bike Share 2024 Trip Data Analysis
Source Table: `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
Target Table: `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`


Purpose: Clean and enhance dataset for casual-to-member conversion analysis
- Remove records with incomplete station/coordinate data
- Filter out unrealistic trip durations (< 1 min or > 24 hrs)
- Remove duplicate ride_id entries (keep earliest occurrence)
- Add calculated columns for analysis
- Create analysis-ready dataset with high data quality

Business Context: Focus on conversion analysis requires complete trip records
with reliable duration and location data for accurate behavioral insights.

===============================================================================
*/

-- =============================================================================
-- 1. DATA CLEANING AND ENHANCEMENT
-- =============================================================================

-- Remove existing cleaned table for safe re-execution
DROP TABLE IF EXISTS `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`;

-- Create cleaned dataset with enhanced analytical columns
-- Expected result: 4,167,794 records (71.12% retention from original 5,860,568)
CREATE TABLE `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data` AS (
  SELECT 
    -- Original core columns
    ride_id, rideable_type, started_at, ended_at, start_station_name,
    start_station_id, end_station_name, end_station_id, start_lat, 
    start_lng, end_lat, end_lng, member_casual,
    
    -- Enhanced columns for analysis
    CASE EXTRACT(DAYOFWEEK FROM started_at)
      WHEN 1 THEN 'Sunday'
      WHEN 2 THEN 'Monday'
      WHEN 3 THEN 'Tuesday'
      WHEN 4 THEN 'Wednesday'
      WHEN 5 THEN 'Thursday'
      WHEN 6 THEN 'Friday'
      WHEN 7 THEN 'Saturday'
    END AS day_of_week,
    
    CASE EXTRACT(MONTH FROM started_at)
      WHEN 1 THEN 'January'
      WHEN 2 THEN 'February'
      WHEN 3 THEN 'March'
      WHEN 4 THEN 'April'
      WHEN 5 THEN 'May'
      WHEN 6 THEN 'June'
      WHEN 7 THEN 'July'
      WHEN 8 THEN 'August'
      WHEN 9 THEN 'September'
      WHEN 10 THEN 'October'
      WHEN 11 THEN 'November'
      WHEN 12 THEN 'December'
    END AS month,
    
    -- Trip duration in minutes for analysis
    (EXTRACT(HOUR FROM(ended_at-started_at))*60 +
     EXTRACT(MINUTE FROM(ended_at-started_at)) +
     EXTRACT(SECOND FROM(ended_at-started_at))/60) AS trip_duration_minutes
     
  FROM (
    -- DUPLICATE REMOVAL SUBQUERY: Keep first occurrence of each ride_id
    SELECT *,
      ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY started_at) as row_num
    FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`
    WHERE 
      -- Remove records missing critical station information
      start_station_name IS NOT NULL 
      AND start_station_id IS NOT NULL
      AND end_station_name IS NOT NULL
      AND end_station_id IS NOT NULL

      -- Remove records missing end coordinates (start coords have 0 nulls)
      AND end_lat IS NOT NULL
      AND end_lng IS NOT NULL
      
      -- Filter unrealistic trip durations
      AND (EXTRACT(HOUR FROM(ended_at-started_at))*60 +
           EXTRACT(MINUTE FROM(ended_at-started_at)) +
           EXTRACT(SECOND FROM(ended_at-started_at))/60) > 1 
      AND (EXTRACT(HOUR FROM(ended_at-started_at))*60 +
           EXTRACT(MINUTE FROM(ended_at-started_at)) +
           EXTRACT(SECOND FROM(ended_at-started_at))/60) < 1440
  )
  WHERE row_num = 1  -- Keep only the first occurrence of each ride_id
);

-- =============================================================================
-- 2. DATA INTEGRITY SETUP
-- =============================================================================

-- Set ride_id as primary key for data integrity and query optimization
ALTER TABLE `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
ADD PRIMARY KEY(ride_id) NOT ENFORCED;

-- =============================================================================
-- 3. CLEANING VERIFICATION
-- =============================================================================

-- Verify cleaning results and calculate data retention
-- Result: Should now have unique ride_ids
SELECT 
  COUNT(*) AS cleaned_record_count,
  COUNT(DISTINCT ride_id) AS distinct_ride_ids,
  COUNT(*) - COUNT(DISTINCT ride_id) AS remaining_duplicates
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`;

/*
===============================================================================
CLEANING SUMMARY
===============================================================================

FILTERS APPLIED:
□ Removed records missing start station data (~18.3% of original)
□ Removed records missing end station data (~18.9% of original)
□ Removed records missing end coordinates (~0.12% of original)
□ Filtered trips under 1 minute (~2.3% of original)
□ Filtered trips over 24 hours (~0.13% of original)
□ Removed duplicate ride_ids (211 duplicates found in original)

ENHANCEMENTS ADDED:
□ day_of_week column (Sunday-Saturday)
□ month column (January-December)
□ trip_duration_minutes column (calculated duration)
□ Primary key constraint on ride_id

DATA QUALITY IMPACT:
- Original Records: 5,860,568
- Cleaned Records: 4,167,794
- Retention Rate: 71.12%
- Records Removed: 1,692,774
- Duplicates Removed: 211 (kept earliest occurrence by started_at)

BUSINESS VALUE:
- High-quality dataset for conversion analysis
- Complete station and coordinate data for geographic insights
- Realistic trip durations for behavioral analysis
- Enhanced columns for usage pattern identification
- Guaranteed unique ride_ids for data integrity

NEXT STEPS:
□ Begin exploratory data analysis on cleaned dataset
□ Analyze casual vs member usage patterns
□ Identify conversion opportunities and strategies
□ Create visualizations and insights for stakeholders

===============================================================================
*/
