--Average Delay by Month
SELECT
    month,
    month_name,
    ROUND(AVG(arr_delay_clean)::numeric, 2) AS avg_arrival_delay
FROM flight_weather_dashboard_top10_2016_2018
WHERE is_cancelled = 0
GROUP BY month, month_name
ORDER BY month;

--Flight Volue by Month
SELECT
    season,
    COUNT(*) AS total_flights
FROM flight_weather_dashboard_top10_2016_2018
GROUP BY season
ORDER BY
    CASE
        WHEN season = 'Winter' THEN 1
        WHEN season = 'Spring' THEN 2
        WHEN season = 'Summer' THEN 3
        WHEN season = 'Fall' THEN 4
    END;

--Delay Cause by Year
SELECT
    flight_year,
    ROUND(SUM(COALESCE(carrier_delay, 0))::numeric, 2) AS carrier_delay_minutes,
    ROUND(SUM(COALESCE(weather_delay, 0))::numeric, 2) AS weather_delay_minutes,
    ROUND(SUM(COALESCE(nas_delay, 0))::numeric, 2) AS nas_delay_minutes,
    ROUND(SUM(COALESCE(security_delay, 0))::numeric, 2) AS security_delay_minutes,
    ROUND(SUM(COALESCE(late_aircraft_delay, 0))::numeric, 2) AS late_aircraft_delay_minutes
FROM flight_weather_dashboard_top10_2016_2018
WHERE is_cancelled = 0
GROUP BY flight_year
ORDER BY flight_year;

--Percent of FLights Delayed by 15 Minutes or More by Airport
SELECT
    origin,
    COUNT(*) AS total_flights,
    SUM(is_arr_delayed_15) AS delayed_flights,
    ROUND(
        100.0 * SUM(is_arr_delayed_15)::numeric / NULLIF(COUNT(*), 0),
        2
    ) AS arrival_delay_rate_percent
FROM flight_weather_dashboard_top10_2016_2018
WHERE is_cancelled = 0
GROUP BY origin
ORDER BY arrival_delay_rate_percent DESC;

--Busiest Origin Airport
SELECT
    origin,
    COUNT(*) AS total_flights
FROM flight_weather_dashboard_top10_2016_2018
GROUP BY origin
ORDER BY total_flights DESC;

--Average Arrival Delay by Airport
SELECT
    origin,
    COUNT(*) AS total_flights,
    ROUND(AVG(arr_delay_clean)::numeric, 2) AS avg_arrival_delay
FROM flight_weather_dashboard_top10_2016_2018
WHERE is_cancelled = 0
GROUP BY origin
ORDER BY avg_arrival_delay DESC;

--Bad Weather vs. Normal Weather
    CASE
        WHEN bad_weather_flag = 1 THEN 'Bad Weather'
        ELSE 'Normal Weather'
    END AS weather_condition,
    COUNT(*) AS total_flights,
    ROUND(AVG(arr_delay_clean)::numeric, 2) AS avg_arrival_delay,
    ROUND(AVG(dep_delay_clean)::numeric, 2) AS avg_departure_delay
FROM flight_weather_dashboard_top10_2016_2018
WHERE is_cancelled = 0
  AND weather_matched = 1
GROUP BY weather_condition
ORDER BY avg_arrival_delay DESC;

--Average Delay by Weather Group
SELECT
    weather_group,
    COUNT(*) AS total_flights,
    ROUND(AVG(arr_delay_clean)::numeric, 2) AS avg_arrival_delay
FROM flight_weather_dashboard_top10_2016_2018
WHERE is_cancelled = 0
  AND weather_matched = 1
GROUP BY weather_group
ORDER BY avg_arrival_delay DESC;

--Flight Volume by Distance
WITH distance_groups AS (
    SELECT
        CASE
            WHEN distance < 250 THEN 'Under 250'
            WHEN distance >= 250 AND distance < 500 THEN '250-500'
            WHEN distance >= 500 AND distance < 1000 THEN '500-1000'
            WHEN distance >= 1000 AND distance < 1500 THEN '1000-1500'
            WHEN distance >= 1500 AND distance < 2000 THEN '1500-2000'
            ELSE '2000+'
        END AS distance_group
    FROM flight_weather_dashboard_top10_2016_2018
)
SELECT
    distance_group,
    COUNT(*) AS total_flights
FROM distance_groups
GROUP BY distance_group
ORDER BY
    CASE
        WHEN distance_group = 'Under 250' THEN 1
        WHEN distance_group = '250-500' THEN 2
        WHEN distance_group = '500-1000' THEN 3
        WHEN distance_group = '1000-1500' THEN 4
        WHEN distance_group = '1500-2000' THEN 5
        WHEN distance_group = '2000+' THEN 6
    END;

--Average Delay by Distance
WITH distance_groups AS (
    SELECT
        CASE
            WHEN distance < 250 THEN 'Under 250'
            WHEN distance >= 250 AND distance < 500 THEN '250-500'
            WHEN distance >= 500 AND distance < 1000 THEN '500-1000'
            WHEN distance >= 1000 AND distance < 1500 THEN '1000-1500'
            WHEN distance >= 1500 AND distance < 2000 THEN '1500-2000'
            ELSE '2000+'
        END AS distance_group,
        arr_delay_clean,
		dep_delay_clean,
        is_cancelled
    FROM flight_weather_dashboard_top10_2016_2018
)
SELECT
    distance_group,
    COUNT(*) AS total_flights,
    ROUND(AVG(arr_delay_clean)::numeric, 2) AS avg_arrival_delay,
	ROUND(AVG(dep_delay_clean)::numeric, 2) AS avg_departure_delay
FROM distance_groups
WHERE is_cancelled = 0
GROUP BY distance_group
ORDER BY
    CASE
        WHEN distance_group = 'Under 250' THEN 1
        WHEN distance_group = '250-500' THEN 2
        WHEN distance_group = '500-1000' THEN 3
        WHEN distance_group = '1000-1500' THEN 4
        WHEN distance_group = '1500-2000' THEN 5
        WHEN distance_group = '2000+' THEN 6
    END;

--Cancellation Rate by Distance
WITH distance_groups AS (
    SELECT
        CASE
            WHEN distance < 250 THEN 'Under 250'
            WHEN distance >= 250 AND distance < 500 THEN '250-500'
            WHEN distance >= 500 AND distance < 1000 THEN '500-1000'
            WHEN distance >= 1000 AND distance < 1500 THEN '1000-1500'
            WHEN distance >= 1500 AND distance < 2000 THEN '1500-2000'
            ELSE '2000+'
        END AS distance_group,
        is_cancelled
    FROM flight_weather_dashboard_top10_2016_2018
)
SELECT
    distance_group,
    COUNT(*) AS total_flights,
    SUM(is_cancelled) AS cancelled_flights,
    ROUND(
        100.0 * SUM(is_cancelled)::numeric / NULLIF(COUNT(*), 0),
        2
    ) AS cancellation_rate_percent
FROM distance_groups
GROUP BY distance_group
ORDER BY
    CASE
        WHEN distance_group = 'Under 250' THEN 1
        WHEN distance_group = '250-500' THEN 2
        WHEN distance_group = '500-1000' THEN 3
        WHEN distance_group = '1000-1500' THEN 4
        WHEN distance_group = '1500-2000' THEN 5
        WHEN distance_group = '2000+' THEN 6
    END;