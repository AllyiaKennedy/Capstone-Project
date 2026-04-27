# Capstone-Project

# Flight Delay and Weather Analytics

This project analyzes flight records from 2016 through 2018 and combines them with historical airport weather data from the Open-Meteo API. The goal is to understand how flight activity, delays, cancellations, carrier performance, and weather conditions relate to each other.

## Workflow

CSV flight files → Python ingestion notebook → PostgreSQL → SQL analytics tables → Metabase dashboard

## Data Sources

- Flight CSV files for 2016, 2017, and 2018
- Open-Meteo Historical Weather API for selected airport locations

## Main Database Tables

- `takeoffs_2016`
- `takeoffs_2017`
- `takeoffs_2018`
- `airport_weather`
- `all_takeoffs`
- `flight_weather_joined`

## Analytics Tables

- `flights_by_year`
- `avg_departure_delay_by_year`
- `delayed_flight_rate_by_year`
- `cancellation_rate_by_airport`
- `carrier_delay_summary`
- `weather_condition_comparison`
- `delay_by_weather_category`
- `high_wind_delay_impact`
- `precipitation_delay_impact`
- `monthly_weather_delay_trend`

## Dashboard

The Metabase dashboard includes 8 visualizations covering yearly flight volume, delay trends, cancellation rates, carrier performance, and the effect of weather conditions on flight outcomes.