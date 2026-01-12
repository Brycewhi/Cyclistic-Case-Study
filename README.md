# 🚴 Cyclistic Bike-Share: Marketing Strategy Case Study
**Google Data Analytics Capstone Project**

## 📌 Project Overview
**Goal:** Design marketing strategies to convert casual riders into annual members.
**The Problem:** Financial analysis shows annual members are more profitable than casual riders. To drive growth, Cyclistic needs to understand how these two groups use bikes differently and target casuals with a membership offer they can't refuse.

---

## 📊 The Dashboard
![Cyclistic Dashboard](final_dashboard.png)
*(Interactive Dashboard visualizing 4.1 million cleaned ride records)*

---

## 🛠️ Technical Approach (SQL & Data Engineering)
Unlike standard analyses that rely on spreadsheets, this project utilized **Google BigQuery** to process 5.8 million records. The SQL pipeline involved:

### 1. Data Ingestion & Consolidation
* **Technique:** Used `UNION ALL` to combine 12 monthly datasets into a single staging table (5.8M rows).
* **Why:** `UNION ALL` is more performant than `UNION` for large datasets as it skips the deduplication step during ingestion.

### 2. Data Cleaning & deduplication
* **Logic:** Filtered for trips between 1 minute and 24 hours to remove system logs and potential theft/loss outliers.
* **Advanced SQL:** Utilized **Window Functions** (`ROW_NUMBER()`) to identify and remove duplicate `ride_id`s, ensuring we kept only the earliest timestamp for any duplicate entry.
* **Result:** Retained 71% of the original data (4.1M records) for high-integrity analysis.

### 3. Feature Engineering
* Created calculated columns for `trip_duration_minutes`, `day_of_week`, and `month` to facilitate temporal aggregation.
* Used `CASE` statements to standardize day/month names for readability.

---

## 🔍 Key Insights & Analysis

### 1. The "Weekend Warrior" vs. "Commuter" Split
* **Finding:** Casual riders peak on **Saturdays and Sundays**, while Members peak on **Mon-Fri** at 8 AM and 5 PM.
* **Implication:** Casuals use the service for leisure; Members use it for commuting.

### 2. Duration Discrepancy
* **Finding:** Casual rides are significantly longer (2x-3x) than Member rides.
* **Implication:** Casuals are not maximizing efficiency; they are enjoying the ride.

### 3. Seasonal "Golden Window"
* **Finding:** Casual ridership is negligible in winter but explodes in **June, July, and August**.
* **Implication:** Marketing spend must be front-loaded in May to capture the pre-summer surge.

---

## 💡 Recommendations

Based on the behavioral analysis, I recommend three data-driven strategies:

1.  **Launch a "Summer Weekend Pass":**
    * *Why:* Casuals strictly ride on weekends in the summer. A specific Fri-Sun pass lowers the barrier to entry for this specific demographic.

2.  **Target "Afternoon Leisure" Ads:**
    * *Why:* Analysis shows casual ridership peaks between 2 PM - 4 PM. Digital ads should run during these hours highlighting scenic routes.

3.  **Gamify the Commute:**
    * *Why:* To convert high-duration casual riders into commuters, offer a "Commuter Challenge" (e.g., "Ride to work 3 times this week for 50% off your first month").

---

## 📂 Repository Structure
* `sql_queries/01_data_ingestion.sql`: Combining 12 months of raw data.
* `sql_queries/02_data_exploration.sql`: QC checks for nulls and outliers.
* `sql_queries/03_data_cleaning.sql`: Filtering, feature engineering, and deduplication.
* `sql_queries/04_data_analysis.sql`: Aggregations and behavioral segmentation.
