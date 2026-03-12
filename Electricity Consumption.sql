use airline;

select * from historic_demand_2009_2024_nonan;

##Peak Electricity Demand Analysis -Identify when demand is highest

SELECT settlement_date, period_hour, england_wales_demand
FROM historic_demand_2009_2024_nonan
ORDER BY england_wales_demand DESC
LIMIT 5;

##Daily Total Demand-Calculate total electricity consumed each day

SELECT day(settlement_date) AS day, SUM(england_wales_demand) AS total_demand
FROM historic_demand_2009_2024_nonan
GROUP BY day 
ORDER BY day;

##Renewable Contribution Analysis- how much of the demand is met by wind + solar

SELECT settlement_date,
       (embedded_wind_generation + embedded_solar_generation) / england_wales_demand * 100 AS pct_renewable
FROM historic_demand_2009_2024_nonan
ORDER BY settlement_date
LIMIT 20;

##Capacity Factor for Wind & Solar-Measure efficiency of renewable installations

SELECT DATE(settlement_date) AS day,
       AVG(embedded_wind_generation / embedded_wind_capacity * 100) AS wind_capacity_factor,
       AVG(embedded_solar_generation / embedded_solar_capacity * 100) AS solar_capacity_factor
FROM historic_demand_2009_2024_nonan
WHERE embedded_wind_capacity > 0 AND embedded_solar_capacity > 0
GROUP BY day
ORDER BY day;

##Interconnector Net Flow-how electricity is imported/exported via interconnectors.

SELECT settlement_date,
       (ifa_flow + ifa2_flow + britned_flow + moyle_flow + east_west_flow + nemo_flow) AS net_flow
FROM historic_demand_2009_2024_nonan
ORDER BY settlement_date
LIMIT 20;

##Holiday vs Non-Holiday Demand Comparison

SELECT is_holiday,
       AVG(england_wales_demand) AS avg_demand,
       MAX(england_wales_demand) AS peak_demand,
       MIN(england_wales_demand) AS min_demand
FROM historic_demand_2009_2024_nonan
GROUP BY is_holiday;

##Top 5 Highest Renewable Contribution Periods

SELECT settlement_date, period_hour,
       (embedded_wind_generation + embedded_solar_generation) / england_wales_demand * 100 AS renewable_pct
FROM historic_demand_2009_2024_nonan
ORDER BY renewable_pct DESC
LIMIT 5;

##Correlation Between Wind and Solar

SELECT embedded_wind_generation, embedded_solar_generation
FROM historic_demand_2009_2024_nonan
WHERE embedded_wind_generation > 0 AND embedded_solar_generation > 0
LIMIT 1000;

##Peak Demand by Hour of Day

SELECT HOUR(period_hour) AS hour,
       MAX(england_wales_demand) AS max_demand,
       AVG(england_wales_demand) AS avg_demand
FROM historic_demand_2009_2024_nonan
GROUP BY hour
ORDER BY hour;

##Net Interconnector Import/Export Extremes-Find periods with maximum import/export.

SELECT settlement_date, period_hour,
       (ifa_flow + ifa2_flow + britned_flow + moyle_flow + east_west_flow + nemo_flow) AS net_flow
FROM historic_demand_2009_2024_nonan
ORDER BY net_flow DESC
LIMIT 5;

SELECT settlement_date, period_hour,
       (ifa_flow + ifa2_flow + britned_flow + moyle_flow + east_west_flow + nemo_flow) AS net_flow
FROM historic_demand_2009_2024_nonan
ORDER BY net_flow ASC
LIMIT 5;

##Rolling 3-Hour Average Demand

SELECT settlement_date, period_hour, england_wales_demand,
       AVG(england_wales_demand) OVER (
           ORDER BY settlement_date, period_hour
           ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
       ) AS rolling_3hr_avg
FROM historic_demand_2009_2024_nonan
ORDER BY settlement_date, period_hour
LIMIT 50;

##Storage Charge/Discharge Efficiency

SELECT DATE(settlement_date) AS day,
       SUM(pump_storage_pumping) AS total_pumping,
       SUM(non_bm_stor) AS total_discharge,
       SUM(non_bm_stor) - SUM(pump_storage_pumping) AS net_storage
FROM historic_demand_2009_2024_nonan
GROUP BY day
ORDER BY net_storage DESC
LIMIT 20;

##Identify Top 5 Days by Renewable Contribution

SELECT day, total_renewable, total_demand, total_renewable / total_demand AS renewable_ratio
FROM (
    SELECT DATE(settlement_date) AS day,
           SUM(embedded_wind_generation + embedded_solar_generation) AS total_renewable,
           SUM(england_wales_demand) AS total_demand,
           RANK() OVER (ORDER BY SUM(embedded_wind_generation + embedded_solar_generation) / SUM(england_wales_demand) DESC) AS rnk
    FROM historic_demand_2009_2024_nonan
    GROUP BY day
) AS daily_renewable
WHERE rnk <= 5;

##Detect Demand Spikes (Anomaly Detection)

SELECT 
    settlement_date,
    period_hour,
    england_wales_demand,
    england_wales_demand -
    (LAG(england_wales_demand) OVER (
        ORDER BY settlement_date
    )) AS demand_change
FROM historic_demand_2009_2024_nonan
ORDER BY settlement_date DESC
LIMIT 10;

##Peak Demand Day Detection-Find the highest electricity demand each day.

SELECT *
FROM (
    SELECT 
        DATE(settlement_date) AS day,
        settlement_date,
        england_wales_demand,
        RANK() OVER (
            PARTITION BY DATE(settlement_date)
            ORDER BY england_wales_demand DESC
        ) AS demand_rank
    FROM historic_demand_2009_2024_nonan
) t
WHERE demand_rank = 1
ORDER BY day;

##Renewable Energy "Drought" Analysis-Identify "Dunkelflaute" periods—consecutive days where combined wind 
#and solar generation fell below 10% of national demand.

WITH DailyGeneration AS (
    SELECT 
        settlement_date,
        SUM(embedded_wind_generation + embedded_solar_generation) AS total_green,
        SUM(nd) AS total_demand,
        CASE 
            WHEN SUM(embedded_wind_generation + embedded_solar_generation) < (SUM(nd) * 0.10) 
            THEN 1 
            ELSE 0 
        END AS is_low_gen
    FROM historic_demand_2009_2024_nonan
    GROUP BY settlement_date
),
LowGenGroups AS (
    SELECT 
        settlement_date,
        is_low_gen,
        ROW_NUMBER() OVER (ORDER BY settlement_date) -
        ROW_NUMBER() OVER (PARTITION BY is_low_gen ORDER BY settlement_date) AS grp
    FROM DailyGeneration
)

SELECT 
    MIN(settlement_date) AS start_date,
    MAX(settlement_date) AS end_date,
    COUNT(*) AS duration_days
FROM LowGenGroups
WHERE is_low_gen = 1
GROUP BY grp
HAVING COUNT(*) >= 3
ORDER BY duration_days DESC;

##Interconnector Reliance during Peak "TV Pickup" Hours--Analyze how much the UK relies on imported energy (via ifa_flow, nemo_flow, etc.) specifically during 
#the highest demand hours (4 PM – 7 PM).

SELECT 
    settlement_date,
    
    SUM(CASE 
        WHEN settlement_period BETWEEN 33 AND 38 
        THEN nd ELSE 0 
    END) AS peak_hour_demand,

    SUM(CASE 
        WHEN settlement_period BETWEEN 33 AND 38 
        THEN (ifa_flow + ifa2_flow + britned_flow + nemo_flow) 
        ELSE 0 
    END) AS peak_imports,

    ROUND(
        SUM(CASE 
            WHEN settlement_period BETWEEN 33 AND 38 
            THEN (ifa_flow + ifa2_flow + britned_flow + nemo_flow) 
            ELSE 0 
        END) 
        /
        NULLIF(
            SUM(CASE 
                WHEN settlement_period BETWEEN 33 AND 38 
                THEN nd ELSE 0 
            END),0
        ) * 100, 
    2) AS import_dependency_pct

FROM historic_demand_2009_2024_nonan

GROUP BY settlement_date

HAVING peak_hour_demand > 0

ORDER BY import_dependency_pct DESC

LIMIT 20;

##Seasonal Demand Analysis (Yearly & Monthly Trend)

SELECT 
    YEAR(settlement_date) AS year,
    MONTH(settlement_date) AS month,
    AVG(england_wales_demand) AS avg_demand,
    max(england_wales_demand) AS peak_demand
FROM historic_demand_2009_2024_nonan
GROUP BY YEAR(settlement_date), MONTH(settlement_date)
ORDER BY year, month;

##Renewable vs Demand Trend (Rolling 7-Day Average)

SELECT 
    DATE(settlement_date) AS day,
    SUM(embedded_wind_generation + embedded_solar_generation) AS renewable_generation,
    SUM(england_wales_demand) AS total_demand,

    AVG(SUM(embedded_wind_generation + embedded_solar_generation)) 
        OVER (ORDER BY DATE(settlement_date) 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS renewable_7day_avg,

    AVG(SUM(england_wales_demand)) 
        OVER (ORDER BY DATE(settlement_date) 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS demand_7day_avg

FROM historic_demand_2009_2024_nonan
GROUP BY DATE(settlement_date)
ORDER BY day;

## Total Demand Per Year

SELECT year(settlement_date) AS year, SUM(england_wales_demand) AS total_demand
FROM historic_demand_2009_2024_nonan
GROUP BY year 
ORDER BY year;

### Renewable contribution Per Year

SELECT year(settlement_date) AS year, (SUM(embedded_solar_generation) + sum(embedded_wind_generation)) AS total_demand
FROM historic_demand_2009_2024_nonan
GROUP BY year 
ORDER BY year;

SELECT 
      (sum(embedded_wind_generation) +sum(embedded_solar_generation) / sum(england_wales_demand)) * 100 AS pct_renewable
FROM historic_demand_2009_2024_nonan
ORDER BY settlement_date
LIMIT 20;

