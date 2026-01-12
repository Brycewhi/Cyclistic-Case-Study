/*
===============================================================================
CYCLISTIC BIKE SHARE - DATA ANALYSIS QUERIES
===============================================================================

Project: Cyclistic Bike Share 2024 - Casual to Member Conversion Analysis
Database: `cyclistic-bike-share-468221.cyclistic_bike_share_2024`
Source Table: `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`

Purpose: Analyze usage patterns between casual riders and annual members to 
identify conversion opportunities and inform targeted marketing strategies.

Business Question: How do casual riders and annual members use Cyclistic 
bikes differently, and what insights can drive conversion strategies?

Cleaned Dataset: 4,167,915 records (71% retention from original 5.86M)
===============================================================================
*/

-- =============================================================================
-- 1. Overall Ridership Summary - FOUNDATIONAL METRICS
-- =============================================================================

-- Overall ridership summary - provides baseline context for all analysis
-- Shows total usage split and key behavioral differences at high level
SELECT 
  member_casual,
  COUNT(*) as total_trips,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage_of_total,
  AVG(trip_duration_minutes) as avg_duration_minutes,
  MIN(trip_duration_minutes) as min_duration,
  MAX(trip_duration_minutes) as max_duration
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
GROUP BY member_casual
ORDER BY total_trips DESC;

-- =============================================================================
-- 2. BIKE TYPE PREFERENCES - RIDEABLE TYPE ANALYSIS
-- =============================================================================

-- Bike types used by rider categories
-- Identifies equipment preferences and potential bike availability strategies
SELECT 
  member_casual, 
  rideable_type, 
  COUNT(*) AS total_trips,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY member_casual), 2) as percentage_within_group
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
GROUP BY member_casual, rideable_type
ORDER BY member_casual, total_trips DESC;

-- =============================================================================
-- 3. TEMPORAL USAGE PATTERNS - WHEN DO USERS RIDE?
-- =============================================================================

-- Monthly usage patterns - seasonal trends for marketing timing
SELECT 
  month, 
  member_casual, 
  COUNT(*) AS total_trips,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY member_casual), 2) as percentage_within_group
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
GROUP BY month, member_casual
ORDER BY member_casual, month;

-- Daily usage patterns - weekday vs weekend behavior identification  
SELECT 
  day_of_week, 
  member_casual, 
  COUNT(*) AS total_trips,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY member_casual), 2) as percentage_within_group
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
GROUP BY day_of_week, member_casual
ORDER BY member_casual, day_of_week;

-- Hourly usage patterns - commuting vs leisure usage identification
SELECT 
  EXTRACT(HOUR FROM started_at) AS hour_of_day, 
  member_casual, 
  COUNT(*) AS total_trips,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY member_casual), 2) as percentage_within_group
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
GROUP BY hour_of_day, member_casual
ORDER BY member_casual, hour_of_day;

-- =============================================================================
-- 4. TRIP DURATION ANALYSIS - HOW LONG DO USERS RIDE?
-- =============================================================================

-- Average ride duration per month - seasonal engagement patterns
SELECT 
  month, 
  member_casual, 
  AVG(trip_duration_minutes) AS avg_ride_duration,
  COUNT(*) as trip_count
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
GROUP BY month, member_casual
ORDER BY member_casual, month;

-- Average ride duration per day of week - weekend vs weekday differences
SELECT 
  day_of_week, 
  member_casual, 
  AVG(trip_duration_minutes) AS avg_ride_duration,
  COUNT(*) as trip_count
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
GROUP BY day_of_week, member_casual
ORDER BY member_casual, day_of_week;

-- Average ride duration per hour - time-based usage intensity
SELECT 
  EXTRACT(HOUR FROM started_at) AS hour_of_day, 
  member_casual, 
  AVG(trip_duration_minutes) AS avg_ride_duration,
  COUNT(*) as trip_count
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
GROUP BY hour_of_day, member_casual
ORDER BY member_casual, hour_of_day;

-- =============================================================================
-- 5. GEOGRAPHIC USAGE PATTERNS - WHERE DO USERS RIDE?
-- =============================================================================

-- Starting station analysis - trip origin patterns and geographic clustering
SELECT 
  start_station_name, 
  member_casual,
  AVG(start_lat) AS start_lat, 
  AVG(start_lng) AS start_lng,
  COUNT(*) AS total_trips,
  AVG(trip_duration_minutes) as avg_duration
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
GROUP BY start_station_name, member_casual
HAVING COUNT(ride_id) >= 500  -- Filter for statistically significant usage
ORDER BY member_casual, total_trips DESC;

-- Ending station analysis - trip destination patterns  
SELECT 
  end_station_name, 
  member_casual,
  AVG(end_lat) AS end_lat, 
  AVG(end_lng) AS end_lng,
  COUNT(*) AS total_trips,
  AVG(trip_duration_minutes) as avg_duration
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
GROUP BY end_station_name, member_casual
HAVING COUNT(ride_id) >= 500  -- Filter for statistically significant usage
ORDER BY member_casual, total_trips DESC;

-- =============================================================================
-- 6. BEHAVIORAL PATTERN ANALYSIS - KEY CONVERSION INSIGHTS
-- =============================================================================

-- 6 Weekend vs Weekday patterns - critical behavioral difference for targeting
SELECT 
  member_casual,
  CASE WHEN day_of_week IN ('Saturday', 'Sunday') 
       THEN 'Weekend' ELSE 'Weekday' END as day_type,
  COUNT(*) as trip_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY member_casual), 2) as percentage_within_group,
  ROUND(AVG(trip_duration_minutes), 2) as avg_duration
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
GROUP BY member_casual, day_type
ORDER BY member_casual, day_type;

-- =============================================================================
-- 7. CONVERSION OPPORTUNITY ANALYSIS - STRATEGIC RECOMMENDATIONS
-- =============================================================================

-- High-opportunity stations for targeted marketing campaigns
-- Identifies stations with highest casual ridership for conversion focus
SELECT 
  start_station_name,
  COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) as casual_trips,
  COUNT(CASE WHEN member_casual = 'member' THEN 1 END) as member_trips,
  COUNT(*) as total_trips,
  AVG(start_lat) as station_lat,
  AVG(start_lng) as station_lng,
  ROUND(COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) * 100.0 / COUNT(*), 2) as casual_percentage,
  AVG(CASE WHEN member_casual = 'casual' THEN trip_duration_minutes END) as casual_avg_duration,
FROM `cyclistic-bike-share-468221.cyclistic_bike_share_2024.cyclistic_2024_cleaned_combined_data`
GROUP BY start_station_name
HAVING COUNT(*) >= 500  -- Focus on high-traffic stations only
  AND COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) >= 100  -- Significant casual usage
ORDER BY casual_percentage DESC, casual_trips DESC
LIMIT 25;

/*
===============================================================================
ANALYSIS EXECUTION NOTES
===============================================================================

QUERY EXECUTION ORDER:
1. Run Executive Overview first for baseline context
2. Execute temporal patterns for usage timing insights  
3. Analyze duration patterns for engagement depth
4. Review geographic patterns for location targeting
5. Examine behavioral differences for key conversion insights
6. Identify conversion opportunities for strategic recommendations

TABLEAU VISUALIZATION STRATEGY:
□ Single Executive Dashboard: "Cyclistic Marketing Strategy"
   - View 1: Seasonality (Monthly trends showing summer surge)
   - View 2: Weekly Trends (Weekend vs. Weekday split)
   - View 3: Peak Hours (Commuter vs. Leisure patterns)
   - View 4: Ride Duration (Member vs. Casual engagement)
   - View 5: Geospatial Map (Coastal hotspots)

KEY INSIGHTS CONFIRMED:
□ Casual riders take longer trips (2x duration vs members)
□ Members show sharp weekday peaks (8am/5pm), casuals curve gently (afternoon)
□ Summer is the critical window (marketing focus for May-Aug)
□ Casuals are "Weekend Warriors" (Sat/Sun dominance)
□ Geographic clustering identifies coastal recreation zones

BUSINESS RECOMMENDATIONS DERIVED:
□ Launch "Summer Weekend Pass" to target the specific casual usage window
□ Schedule digital ads for 1 PM - 4 PM on weekends (Casual peak hours)
□ "Gamify" the commute to incentivize casuals to ride M-F
===============================================================================
*/
