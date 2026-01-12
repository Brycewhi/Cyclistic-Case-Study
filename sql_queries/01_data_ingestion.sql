/*
===============================================================================
CYCLISTIC BIKE SHARE - DATA CONSOLIDATION
===============================================================================

Project: Cyclistic Bike Share 2024 Trip Data Analysis
Purpose: Combine 12 monthly tables into single dataset for analysis
Expected Records: 5,860,568 total trips

===============================================================================
*/

-- Combine all 12 months of 2024 Cyclistic trip data
-- Using UNION ALL to preserve all records (duplicates handled in exploration)

CREATE TABLE IF NOT EXISTS `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips` AS( 
  SELECT * FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024-01`
  UNION ALL
  SELECT * FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024-02`
  UNION ALL
  SELECT * FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024-03`
  UNION ALL
  SELECT * FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024-04`
  UNION ALL
  SELECT * FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024-05`
  UNION ALL
  SELECT * FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024-06`
  UNION ALL
  SELECT * FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024-07`
  UNION ALL
  SELECT * FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024-08`
  UNION ALL
  SELECT * FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024-09`
  UNION ALL
  SELECT * FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024-10`
  UNION ALL
  SELECT * FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024-11`
  UNION ALL
  SELECT * FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024-12`
);

-- Verify consolidation was successful - expecting 5,860,568 records
-- Result: 5,860,568 records
SELECT COUNT(*) AS combined_record_count
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_all_trips`;
