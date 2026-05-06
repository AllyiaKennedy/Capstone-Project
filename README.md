# Flight Delay and Weather Analytics

A data analytics capstone project that studies how U.S. flight delays, cancellations, carrier performance, and airport weather conditions relate to each other from **2016 through 2018**.

The project starts with raw flight CSV files, cleans and reduces the data in Python, pulls historical weather data from the Open-Meteo API, joins flight records to weather by airport and date, loads the final tables into PostgreSQL, and visualizes the results in Metabase.

---

## Project Workflow

```text
Raw flight CSV files
        ↓
Python ingestion and cleaning notebook
        ↓
Open-Meteo historical weather API
        ↓
Cleaned flight + weather CSV outputs
        ↓
PostgreSQL database in Docker
        ↓
Metabase dashboard visualizations
```

---

## Main Goal

The goal of this project is to answer questions such as:

- How did flight volume and delays change from 2016 to 2018?
- Which airlines and airports experienced the most delay impact?
- Do bad weather days show higher delay or cancellation rates?
- How do precipitation, snow, wind, and weather categories relate to flight outcomes?
- Which dashboard visuals best explain the relationship between air travel and weather?

---

## Tech Stack

- **Python** for ingestion, cleaning, API requests, and table creation
- **pandas** for data cleaning and transformation
- **requests** for pulling Open-Meteo weather data
- **SQLAlchemy / psycopg2** for writing data into PostgreSQL
- **PostgreSQL 16** as the database
- **Docker Compose** for running PostgreSQL and Metabase locally
- **Metabase** for dashboard visualizations
- **DataGrip** for inspecting and querying PostgreSQL tables

---

## Repository Structure

```text
Capstone-Project/
│
├── ingestion.ipynb              # Main notebook for cleaning, weather pull, joins, and database load
├── docker-compose.yml           # Runs PostgreSQL and Metabase containers
├── requirements.txt             # Python package dependencies
├── README.md                    # Project documentation
│
└── data/                        # Local data folder; usually not pushed to GitHub
    ├── 2016.csv                 # Raw flight data for 2016
    ├── 2017.csv                 # Raw flight data for 2017
    ├── 2018.csv                 # Raw flight data for 2018
    │
    └── processed/               # Created by the notebook
        ├── flights_clean_2016_2018.csv
        ├── flights_top10_origins_2016_2018.csv
        ├── weather_top10_origins_2016_2018.csv
        ├── flight_weather_dashboard_top10_2016_2018.csv
        └── airport_traffic_2016_2018.csv
```

> The raw `data/` folder is expected to exist locally. It may be ignored by Git because the files are large.

---

## Data Sources

### Flight Data

The flight records come from yearly CSV files for:

- `2016.csv`
- `2017.csv`
- `2018.csv`

These files should be placed inside the local `data/` folder before running the notebook.

### Weather Data

Weather data is pulled from the **Open-Meteo Historical Weather API** using airport latitude and longitude coordinates.

The notebook currently pulls daily weather variables such as:

- maximum temperature
- minimum temperature
- precipitation
- snowfall
- maximum wind speed
- weather code

Weather codes are grouped into readable categories like:

- Clear
- Cloudy
- Fog
- Drizzle
- Rain
- Snow
- Thunderstorm
- Other

---

## Setup Instructions

### 1. Clone the repository

```bash
git clone <repository-url>
cd Capstone-Project
```

### 2. Create and activate a virtual environment

On Mac:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 3. Install Python dependencies

```bash
pip install -r requirements.txt
```

### 4. Start Docker Desktop

Make sure Docker Desktop is open before running Docker commands.

### 5. Start PostgreSQL and Metabase

```bash
docker compose up -d
```

This starts two containers:

- `capstone_postgres`
- `capstone_metabase`

PostgreSQL runs on port `5432` and Metabase runs on port `3000`.

### 6. Open the notebook

```bash
jupyter notebook
```

Then open:

```text
ingestion.ipynb
```

Run the notebook from top to bottom.

---

## How the Notebook Works

The notebook follows this general process:

1. Imports required Python packages.
2. Locates the local `data/` folder.
3. Reads the 2016, 2017, and 2018 flight CSV files.
4. Standardizes column names.
5. Keeps only the flight columns needed for analysis.
6. Cleans dates, delays, cancellations, diversions, carriers, origins, and destinations.
7. Creates useful fields such as:
   - `flight_year`
   - `month`
   - `month_name`
   - `season`
   - `route`
   - `is_dep_delayed_15`
   - `is_arr_delayed_15`
   - `arrival_delay_status`
8. Finds the top 10 origin airports by flight count.
9. Filters the flight dataset to those top 10 origin airports.
10. Pulls daily historical weather for those airports from Open-Meteo.
11. Cleans and labels the weather data.
12. Joins flights to weather using:

```text
origin airport + flight date
```

13. Saves processed CSV files into `data/processed/`.
14. Loads the final tables into PostgreSQL.

---

## Important Data Note

The final dashboard table focuses on the **top 10 origin airports** from the 2016-2018 flight data.

Weather is joined using the flight's **origin airport** and **flight date**. This means the weather fields describe conditions at the departure airport, not the destination airport.

This is why some visuals may only show the selected top airports rather than every airport in the original flight dataset.

---

## PostgreSQL Tables Created

The current notebook loads these main tables into PostgreSQL:

| Table | Purpose |
|---|---|
| `airport_traffic_2016_2018` | Ranks airports by flight count from 2016-2018 |
| `weather_top10_2016_2018` | Daily weather data for the top 10 origin airports |
| `flight_weather_dashboard_top10_2016_2018` | Main joined table for Metabase dashboards |

The most important table for dashboard work is:

```text
flight_weather_dashboard_top10_2016_2018
```

---

## Main Dashboard Table Fields

The dashboard table includes fields such as:

| Field | Meaning |
|---|---|
| `flight_year` | Year of the flight |
| `flight_date` | Date of the flight |
| `month` / `month_name` | Month information |
| `season` | Winter, Spring, Summer, or Fall |
| `op_carrier` | Airline carrier code |
| `origin` | Departure airport |
| `dest` | Destination airport |
| `route` | Origin-destination route |
| `distance` | Flight distance |
| `dep_delay_clean` | Cleaned departure delay value |
| `arr_delay_clean` | Cleaned arrival delay value |
| `is_cancelled` | Whether the flight was cancelled |
| `is_diverted` | Whether the flight was diverted |
| `is_dep_delayed_15` | Whether departure delay was at least 15 minutes |
| `is_arr_delayed_15` | Whether arrival delay was at least 15 minutes |
| `weather_group` | Readable weather category |
| `bad_weather_flag` | Flags weather conditions that may affect flights |
| `has_precipitation` | Whether precipitation occurred |
| `has_snow` | Whether snow occurred |
| `high_wind` | Whether wind speed was high |
| `temp_max_c` | Daily maximum temperature in Celsius |
| `temp_min_c` | Daily minimum temperature in Celsius |
| `precipitation_mm` | Daily precipitation in millimeters |
| `snow_mm` | Daily snowfall in millimeters |
| `wind_speed_mph` | Daily maximum wind speed in miles per hour |
| `weather_matched` | Whether weather data successfully joined to the flight |

---

## Connecting with DataGrip

Use these settings to connect DataGrip to the local PostgreSQL database:

| Setting | Value |
|---|---|
| Host | `localhost` |
| Port | `5432` |
| Database | `postgres` |
| User | `postgres` |
| Password | `postgres` |

After connecting, refresh the schema to see the tables created by the notebook.

---

## Connecting Metabase to PostgreSQL

Open Metabase in a browser:

```text
http://localhost:3000
```

When adding the PostgreSQL database in Metabase, use:

| Setting | Value |
|---|---|
| Database type | PostgreSQL |
| Host | `postgres` |
| Port | `5432` |
| Database name | `postgres` |
| Username | `postgres` |
| Password | `postgres` |

> Use `postgres` as the host inside Metabase because Metabase is running in Docker and connects to the PostgreSQL service by its Docker Compose service name.

---

## Recommended Metabase Visualizations

Useful dashboard visuals include:

1. Total flight volume by year
2. Average arrival delay by month
3. Delay rate by weather group
4. Cancellation rate by airport
5. Carrier delay comparison
6. Precipitation vs. arrival delay
7. High wind vs. delay rate
8. Top routes by flight volume
9. Bad weather vs. normal weather comparison
10. Seasonal delay trends

For the clearest dashboard, avoid charts with multiple scales on the same axis. Single-scale charts are easier to explain during a presentation.

---

## Common Commands

Start containers:

```bash
docker compose up -d
```

Stop containers:

```bash
docker compose down
```

Check running containers:

```bash
docker ps
```

View container logs:

```bash
docker logs capstone_postgres
```

```bash
docker logs capstone_metabase
```

Restart containers:

```bash
docker compose restart
```

---

## Troubleshooting

### Docker daemon is not running

If you see:

```text
Cannot connect to the Docker daemon
```

Open Docker Desktop and wait until it fully starts. Then run:

```bash
docker compose up -d
```

### Port 3000 is already in use

Metabase uses port `3000`. If something else is using that port, either stop the other process or change the Metabase port in `docker-compose.yml`.

Example alternative port:

```yaml
ports:
  - "3001:3000"
```

Then Metabase would open at:

```text
http://localhost:3001
```

### Notebook cannot find the CSV files

Make sure the raw files are named exactly:

```text
data/2016.csv
data/2017.csv
data/2018.csv
```

The notebook also checks for a folder named `Data`, but using lowercase `data` is recommended.

### Metabase does not show new tables

In Metabase, go to:

```text
Admin settings → Databases → PostgreSQL database → Sync database schema now
```

Then refresh the browser.

### Large CSV files make the notebook crash

The project includes chunk-loading logic to write processed CSV files into PostgreSQL in smaller groups. This helps avoid memory problems when working with millions of flight records.

---

## Project Summary

This project builds a complete data pipeline from raw flight records and weather API data into a PostgreSQL database and Metabase dashboard. The final dashboard table, `flight_weather_dashboard_top10_2016_2018`, is designed to make it easier to analyze flight delay patterns by year, month, airport, carrier, route, and weather condition.
