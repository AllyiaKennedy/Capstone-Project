-- ============================================================
-- Final Capstone: Flight Delay Analytics SQL
-- ============================================================


-- Step 1: Verify yearly tables loaded correctly

SELECT COUNT(*) AS rows_2016 FROM takeoffs_2016;
SELECT COUNT(*) AS rows_2017 FROM takeoffs_2017;
SELECT COUNT(*) AS rows_2018 FROM takeoffs_2018;


-- Step 2: Preview yearly tables

SELECT * FROM takeoffs_2016 LIMIT 10;
SELECT * FROM takeoffs_2017 LIMIT 10;
SELECT * FROM takeoffs_2018 LIMIT 10;


-- Step 3: Check column names and data types

SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name IN ('takeoffs_2016', 'takeoffs_2017', 'takeoffs_2018')
ORDER BY table_name, ordinal_position;


-- Step 4: Create combined view

DROP VIEW IF EXISTS all_takeoffs;

CREATE VIEW all_takeoffs AS
SELECT *, 2016 AS flight_year FROM takeoffs_2016
UNION ALL
SELECT *, 2017 AS flight_year FROM takeoffs_2017
UNION ALL
SELECT *, 2018 AS flight_year FROM takeoffs_2018;


SELECT COUNT(*) AS total_rows
FROM all_takeoffs;

SELECT *
FROM all_takeoffs
LIMIT 10;


-- Flights by year

DROP TABLE IF EXISTS flights_by_year;

CREATE TABLE flights_by_year AS
SELECT
    flight_year,
    COUNT(*) AS total_flights
FROM all_takeoffs
GROUP BY flight_year
ORDER BY flight_year;

SELECT *
FROM flights_by_year;


-- Average departure delay by year

DROP TABLE IF EXISTS avg_departure_delay_by_year;

CREATE TABLE avg_departure_delay_by_year AS
SELECT
    flight_year,
    ROUND(AVG(dep_delay)::numeric, 2) AS avg_departure_delay_minutes
FROM all_takeoffs
WHERE cancelled = 0
GROUP BY flight_year
ORDER BY flight_year;

SELECT *
FROM avg_departure_delay_by_year;


-- Worst origin airports by average departure delay

DROP TABLE IF EXISTS worst_origin_airports_delay;

CREATE TABLE worst_origin_airports_delay AS
SELECT
    origin,
    COUNT(*) AS total_flights,
    ROUND(AVG(dep_delay)::numeric, 2) AS avg_departure_delay_minutes
FROM all_takeoffs
WHERE cancelled = 0
GROUP BY origin
HAVING COUNT(*) >= 1000
ORDER BY avg_departure_delay_minutes DESC;

SELECT *
FROM worst_origin_airports_delay
LIMIT 20;


-- Cancellation rate by airport

DROP TABLE IF EXISTS cancellation_rate_by_airport;

CREATE TABLE cancellation_rate_by_airport AS
SELECT
    origin,
    COUNT(*) AS total_flights,
    SUM(cancelled) AS cancelled_flights,
    ROUND((100.0 * SUM(cancelled) / COUNT(*))::numeric, 2) AS cancellation_rate_percent
FROM all_takeoffs
GROUP BY origin
HAVING COUNT(*) >= 1000
ORDER BY cancellation_rate_percent DESC;

SELECT *
FROM cancellation_rate_by_airport
LIMIT 10;



-- Step 13: Monthly delay summary

DROP TABLE IF EXISTS monthly_delay_summary;

CREATE TABLE monthly_delay_summary AS
SELECT
    EXTRACT(YEAR FROM fl_date::date) AS year,
    EXTRACT(MONTH FROM fl_date::date) AS month,
    COUNT(*) AS total_flights,
    ROUND(AVG(dep_delay)::numeric, 2) AS avg_departure_delay_minutes,
    ROUND(AVG(arr_delay)::numeric, 2) AS avg_arrival_delay_minutes
FROM all_takeoffs
WHERE cancelled = 0
GROUP BY
    EXTRACT(YEAR FROM fl_date::date),
    EXTRACT(MONTH FROM fl_date::date)
ORDER BY year, month;

SELECT *
FROM monthly_delay_summary;



-- ============================================================
-- Weather Analytics Section
-- ============================================================


-- Step 15: Verify weather table loaded

SELECT COUNT(*) AS weather_rows
FROM airport_weather;

SELECT *
FROM airport_weather
LIMIT 10;


-- Flight-weather


DROP TABLE IF EXISTS flight_weather_joined;

CREATE TABLE flight_weather_joined AS
SELECT
    f.flight_year,
    f.fl_date::date AS flight_date,
    f.op_carrier,
    f.op_carrier_fl_num,
    f.origin,
    f.dest,
    f.crs_dep_time,
    f.dep_time,
    f.dep_delay,
    f.arr_delay,
    f.cancelled,
    f.diverted,
    f.distance,
    f.carrier_delay,
    f.weather_delay,
    f.nas_delay,
    f.security_delay,
    f.late_aircraft_delay,
    w.temp_max_c,
    w.temp_min_c,
    w.precipitation_mm,
    w.snow_mm,
    w.wind_speed_mph,
    w.weather_code,
    CASE
        WHEN w.weather_code = 0 THEN 'Clear'
        WHEN w.weather_code IN (1, 2, 3) THEN 'Cloudy'
        WHEN w.weather_code IN (45, 48) THEN 'Fog'
        WHEN w.weather_code IN (51, 53, 55, 56, 57) THEN 'Drizzle'
        WHEN w.weather_code IN (61, 63, 65, 66, 67) THEN 'Rain'
        WHEN w.weather_code IN (71, 73, 75, 77) THEN 'Snow'
        WHEN w.weather_code IN (80, 81, 82) THEN 'Rain Showers'
        WHEN w.weather_code IN (85, 86) THEN 'Snow Showers'
        WHEN w.weather_code IN (95, 96, 99) THEN 'Thunderstorm'
        ELSE 'Other'
    END AS weather_category,
    CASE
        WHEN w.precipitation_mm > 0
             OR w.snow_mm > 0
             OR w.wind_speed_mph >= 25
            THEN 'Poor Weather'
        ELSE 'Favorable Weather'
    END AS weather_condition
FROM all_takeoffs f
JOIN airport_weather w
    ON f.origin = w.airport_code
    AND f.fl_date::date = w.date::date;

SELECT *
FROM flight_weather_joined
LIMIT 10;


--Average delay by weather category

DROP TABLE IF EXISTS delay_by_weather_category;

CREATE TABLE delay_by_weather_category AS
SELECT
    weather_category,
    COUNT(*) AS total_flights,
    ROUND(AVG(dep_delay)::numeric, 2) AS avg_departure_delay_minutes,
    ROUND(AVG(arr_delay)::numeric, 2) AS avg_arrival_delay_minutes,
    ROUND((100.0 * SUM(cancelled) / COUNT(*))::numeric, 2) AS cancellation_rate_percent
FROM flight_weather_joined
GROUP BY weather_category
ORDER BY avg_departure_delay_minutes DESC;

SELECT *
FROM delay_by_weather_category;

 
 --High wind impact

DROP TABLE IF EXISTS high_wind_delay_impact;

CREATE TABLE high_wind_delay_impact AS
SELECT
    CASE
        WHEN wind_speed_mph >= 30 THEN 'High Wind'
        WHEN wind_speed_mph >= 20 THEN 'Moderate Wind'
        ELSE 'Low Wind'
    END AS wind_category,
    COUNT(*) AS total_flights,
    ROUND(AVG(dep_delay)::numeric, 2) AS avg_departure_delay_minutes,
    ROUND(AVG(arr_delay)::numeric, 2) AS avg_arrival_delay_minutes,
    ROUND((100.0 * SUM(cancelled) / COUNT(*))::numeric, 2) AS cancellation_rate_percent
FROM flight_weather_joined
GROUP BY wind_category
ORDER BY avg_departure_delay_minutes DESC;

SELECT *
FROM high_wind_delay_impact;

-- Busient flight routes
SELECT
    origin || ' → ' || dest AS route,
    COUNT(*) AS total_flights,
    ROUND(AVG(dep_delay)::numeric, 2) AS avg_departure_delay,
    ROUND(AVG(arr_delay)::numeric, 2) AS avg_arrival_delay,
    ROUND(100.0 * AVG(cancelled)::numeric, 2) AS cancellation_rate_pct
FROM all_flights
GROUP BY origin, dest
HAVING COUNT(*) >= 1000
ORDER BY total_flights DESC
LIMIT 10;