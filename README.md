# 🎵 Spotify Real-Time Streaming Data Pipeline

[![GitHub last commit](https://img.shields.io/github/last-commit/Konstant-gk/spotify-streaming-pipeline-kafka)](https://github.com/Konstant-gk/spotify-streaming-pipeline-kafka/commits/main)
[![GitHub stars](https://img.shields.io/github/stars/Konstant-gk/spotify-streaming-pipeline-kafka)](https://github.com/Konstant-gk/spotify-streaming-pipeline-kafka/stargazers)
[![GitHub license](https://img.shields.io/github/license/Konstant-gk/spotify-streaming-pipeline-kafka)](https://github.com/Konstant-gk/spotify-streaming-pipeline-kafka/blob/main/LICENSE)
[![Python](https://img.shields.io/badge/Python-3.9+-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Kafka](https://img.shields.io/badge/Apache%20Kafka-231F20?logo=apache-kafka&logoColor=white)](https://kafka.apache.org/)
[![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?logo=snowflake&logoColor=white)](https://www.snowflake.com/)
[![dbt](https://img.shields.io/badge/dbt-FF694B?logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![Airflow](https://img.shields.io/badge/Airflow-017CEE?logo=apache-airflow&logoColor=white)](https://airflow.apache.org/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?logo=power-bi&logoColor=black)](https://powerbi.microsoft.com/)

---

## 📑 **TABLE OF CONTENTS**

1. Project Overview
2. Architecture
3. Tech Stack
4. Repository Structure
5. Pipeline Components
   - Data Source (Simulator)
   - Streaming (Kafka)
   - Storage (MinIO)
   - Orchestration (Airflow)
   - Warehouse (Snowflake)
   - Transformation (dbt)
   - Visualization (Power BI)
6. Data Model & Transformations
   - Bronze Layer (Raw)
   - Silver Layer (Cleaned)
   - Gold Layer (Business-ready)
7. How to run
8. Dashboard
9. What I Learned
10. Acknowledgements
12. License

---

## 📌 **PROJECT OVERVIEW**

This project implements a **real-time, end-to-end data engineering pipeline** for Spotify user event data. It simulates a live streaming scenario where user interactions (plays, skips, adds to playlist) are generated continuously, processed through a modern data stack, and finally visualized in an interactive Power BI dashboard.

### **🎯 Key Features**

- **Real-time Data Simulation:** A Python script generates infinite streaming events (1 event per second) instead of using static CSV files.
- **Streaming Ingestion:** Apache Kafka handles the real-time data stream.
- **Data Lake Storage:** MinIO (S3-compatible) stores raw event data as JSON files.
- **Orchestration:** Apache Airflow schedules and manages the pipeline to load data from MinIO to Snowflake.
- **Cloud Warehouse:** Snowflake serves as the central data warehouse.
- **In-warehouse Transformation:** dbt (data build tool) is used to transform raw data into clean, business-ready models following the medallion architecture (Bronze → Silver → Gold).
- **Real-time BI:** Power BI connects directly to Snowflake using the **Direct Query** method, ensuring dashboards update in real-time as new data arrives.
- **Containerization:** The entire ecosystem (Kafka, MinIO, Airflow) runs locally using Docker containers.

---

## 🏛️ **ARCHITECTURE**

The pipeline architecture follows a modern, decoupled design:

```
Simulator (Python) → Kafka → Consumer → MinIO (bronze/) → Airflow DAG → Snowflake Bronze
                                                                              ↓
                                                              dbt: Bronze → Silver → Gold
                                                                              ↓
                                                                      Power BI (Direct Query)
```


### **Data Flow Summary**
1.  **Simulator** generates streaming data.
2.  **Kafka** ingests the stream.
3.  **Consumer** batches messages and stores them as JSON files in **MinIO**.
4.  **Airflow DAG** runs hourly, picks up new JSON files, and loads the raw data into the **Snowflake Bronze** table.
5.  **dbt** transforms data from Bronze → Silver → Gold layers within Snowflake.
6.  **Power BI** connects to the Gold layer tables via Direct Query for real-time visualization.

---

## 🛠️ **TECH STACK**

| Category | Technology | Purpose |
|----------|------------|---------|
| **Language** | Python 3.9+ | Data simulation, consumption, orchestration code |
| **Streaming** | Apache Kafka | Real-time message queue for event streaming |
| **Containerization** | Docker, Docker Compose | Runs Kafka, Zookeeper, MinIO, Airflow, Postgres |
| **Data Lake** | MinIO | S3-compatible local storage for raw JSON files |
| **Workflow Orchestration** | Apache Airflow | Schedules and runs the data load from MinIO to Snowflake |
| **Cloud Data Warehouse** | Snowflake | Central repository for transformed data |
| **Data Transformation** | dbt (Data Build Tool) | Version-controlled SQL transformations (Bronze → Silver → Gold) |
| **Business Intelligence** | Microsoft Power BI | Real-time dashboards and visualizations (using Direct Query) |
| **Monitoring Tools** | Kafdrop | UI for monitoring Kafka topics and messages |

---

## 📂 **REPOSITORY STRUCTURE**

```
spotify-streaming-pipeline-kafka/
├── src/
│   ├── producers/          # Simulator (Producer.py)
│   └── consumers/          # Kafka → MinIO consumer
├── docker containers/
│   ├── docker-compose.yml  # Kafka, MinIO, Airflow, Zookeeper, Kafdrop
│   └── dags/               # Airflow DAGs (MinIO → Snowflake)
├── dbt/
│   ├── models/             # Silver and Gold dbt models
│   └── dbt_project.yml
├── docs/                   # Architecture diagrams
├── assets/                 # Power BI .pbix
├── requirements.txt
└── README.md
```

## 🔄 **PIPELINE COMPONENTS**

### 1. **Data Source (Simulator)**
- **File:** `simulator/producer.py`
- **Function:** Generates realistic Spotify listening events.
- **Key Features:**
    - Uses `Faker` and `UUID` to create unique user and event IDs.
    - Defines a list of 6 songs with corresponding artists.
    - Event types: `play`, `pause`, `skip`, `add_to_playlist`.
    - Runs in an infinite `while True` loop with a 1-second delay, creating a continuous real-time stream.
    - All configurations (Kafka broker, topic) are externalized in a `.env` file.

### 2. **Streaming (Kafka)**
- **Infrastructure:** Defined in `docker/docker-compose.yml`.
- **Components:**
    - **Zookeeper:** Required for Kafka coordination.
    - **Kafka Broker:** Core streaming service on port `9092`.
    - **Kafdrop:** UI on port `9000` for monitoring topics and messages.
- **Topic:** `spotify_events`

### 3. **Storage (MinIO)**
- **Infrastructure:** Defined in `docker/docker-compose.yml`.
- **Access:** UI on port `9001` (username/password set in `.env`).
- **Bucket:** A bucket named `spotify` is created (either manually or by the consumer script).
- **Data Organization:**

- Files are batched by the consumer (default batch size 10 events) and stored with timestamps to prevent overwrites.

### 4. **Orchestration (Airflow)**
- **Infrastructure:** Defined in `docker/docker-compose.yml` (includes Postgres backend, webserver, scheduler).
- **Access:** UI on port `8080`.
- **DAG:** `dags/minio_to_snowflake_dag.py`
- **DAG Tasks:**
1.  **`extract_from_minio`**: Connects to MinIO using `boto3`, lists objects in the `bronze/` prefix, downloads new JSON files to a temporary local path, and consolidates them.
2.  **`load_raw_to_snowflake`**: Connects to Snowflake, creates the `bronze` schema and table if they don't exist, and inserts the raw JSON data (event_id, user_id, timestamp, etc. as strings). The DAG is set to run **hourly** with catchup disabled.

### 5. **Warehouse (Snowflake)**
- **Initial Setup:**
- Create a database: `CREATE DATABASE SPOTIFY_DB;`
- Create a schema for raw data: `CREATE SCHEMA SPOTIFY_DB.BRONZE;`
- Create a schema for dbt transformations: `CREATE SCHEMA SPOTIFY_DB.TRANSFORM;`
- **Bronze Table Structure:**
```sql
CREATE TABLE IF NOT EXISTS SPOTIFY_DB.BRONZE.SPOTIFY_EVENTS (
    EVENT_ID STRING,
    USER_ID STRING,
    SONG_ID STRING,
    ARTIST_NAME STRING,
    SONG_NAME STRING,
    EVENT_TYPE STRING,
    DEVICE_TYPE STRING,
    COUNTRY STRING,
    TIMESTAMP_STR STRING  -- Ingested as string, transformed later
);
```

### 6. Transformation (dbt)
- Project Root: spotify_dbt/
- Initialization: dbt init spotify_dbt (configured for Snowflake connection).
- Source Configuration (models/bronze/source.yml):
```
version: 2
sources:
  - name: spotify
    database: SPOTIFY_DB
    schema: BRONZE
    tables:
      - name: spotify_events
```

- Silver Model (models/silver/spotify_silver.sql):
- Materialization: View (default).
- Transformations:
- Uses a CTE to select from the source.
- Filters out rows where critical IDs are NULL (a best practice).
- Casts the string TIMESTAMP_STR to a proper TIMESTAMP data type.
 
```sql
WITH bronze_data AS (
    SELECT
        EVENT_ID,
        USER_ID,
        SONG_ID,
        ARTIST_NAME,
        SONG_NAME,
        EVENT_TYPE,
        DEVICE_TYPE,
        COUNTRY,
        TO_TIMESTAMP(TIMESTAMP_STR) AS EVENT_TIMESTAMP
    FROM {{ source('spotify', 'spotify_events') }}
    WHERE EVENT_ID IS NOT NULL
      AND USER_ID IS NOT NULL
      AND SONG_ID IS NOT NULL
)
SELECT * FROM bronze_data
```
- Gold Models:
- models/gold/top_songs.sql (Materialized as View):
- Aggregates plays and skips per song.
- Ordered by total plays descending.
- models/gold/user_engagement.sql (Materialized as View):
- Aggregates user activity (plays, skips, adds_to_playlist) by USER_ID, DEVICE_TYPE, COUNTRY, and the event DAY.
- Ordered by total plays descending.
- Execution: After the Airflow DAG loads data, run dbt run from the spotify_dbt/ directory to build the Silver and Gold views.

### 7. Visualization (Power BI)

Data Source: Connect to SPOTIFY_DB.TRANSFORM schema.
- Tables Used: TOP_SONGS and USER_ENGAGEMENT.
  
Dashboard Features:
- KPIs: Total Plays, Total Songs, Total Users, Total Artists.
- Map: Visualizes play count by country.
- Bar Chart: Top 5 songs by play count.
- Donut Charts: Distribution of plays by device type and event type.
- Slicers: To filter data interactively.

## 📊 **DATA MODEL & TRANSFORMATIONS**
The medallion architecture ensures data quality and clarity at each stage.

### Bronze Layer (Raw)

- Location: Snowflake BRONZE schema.
- Table: SPOTIFY_EVENTS
- Description: Raw, unaltered data directly from the JSON files. All columns are stored as STRING to preserve the original payload. This layer serves as a single source of truth and an audit trail.

### Silver Layer (Cleaned)

- Location: Snowflake TRANSFORM schema (created by dbt).
- View: SPOTIFY_SILVER
- Transformations Applied:
- Data Type Casting: TIMESTAMP_STR converted to proper TIMESTAMP data type for time-series analysis.
- Data Quality Filters: Removed rows where core identifiers (EVENT_ID, USER_ID, SONG_ID) are NULL.
- Purpose: This view provides a clean, reliable dataset for analysts and serves as the foundation for all downstream business logic.

### Gold Layer (Business-ready)

- Location: Snowflake TRANSFORM schema (created by dbt).
- Views: TOP_SONGS, USER_ENGAGEMENT
- Business Logic: Daily user activity roll-up segmented by device and country.
- Use Case: Understanding user behavior, engagement patterns, and feature adoption across different segments.

## ℹ️**HOW TO RUN**

### 1. Install dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure environment

Copy `.env.example` to `.env` and set:

- Kafka bootstrap servers
- MinIO endpoint, access key, secret key
- Snowflake account, user, password, warehouse, database, schema
- Kafka topic name

### 3. Start Docker containers

```bash
cd "docker containers"
docker-compose up -d
```

Wait until Airflow reports `airflow db initialized successfully`.

### 4. Create Snowflake database and schemas

```sql
CREATE DATABASE SPOTIFY_DB;
USE SPOTIFY_DB;
CREATE SCHEMA bronze;
CREATE SCHEMA transform;
```

### 5. Run consumer first, then producer

**Important:** Start the consumer before the producer so batches are not overwritten (JSON files are named by timestamp).

```bash
# Terminal 1: Start consumer
cd src/consumers
python kafka_to_minio.py

# Terminal 2: Start producer
cd src/producers
python producer.py
```

### 6. Trigger Airflow DAG

In the Airflow UI, enable and trigger the MinIO → Snowflake DAG.

### 7. Run dbt transformations

```bash
cd dbt
dbt run
```

### 8. Connect Power BI

- Get Data → Snowflake
- Server: your Snowflake account (without `https://`)
- Warehouse: `COMPUTE_WH`
- Database: `SPOTIFY_DB`, Schema: `transform`
- Select Gold tables (`top_songs`, `user_engagement`)
- Use **Direct Query** for real-time refresh

---

## 💡 WHAT I LEARNED
- This project was instrumental in solidifying my understanding of a modern, real-time data stack:
- Real-Time is Different: Working with an infinite data stream (simulated) versus static batches highlighted the need for robust consumer offset management and idempotent processing to avoid data loss or duplication.
- Containerization is a Game-Changer: Docker Compose made it trivial to spin up a complex, multi-service ecosystem (Kafka, MinIO, Airflow) locally, exactly as it might run in production.
- Separation of Concerns in Action: The clear delineation between storage (MinIO), compute/warehouse (Snowflake), and transformation (dbt) proved how modular and scalable modern data architectures can be.
- Direct Query vs. Import: Understanding the trade-off between real-time updates (Direct Query) and dashboard performance (Import) was crucial for delivering the right user experience.
- End-to-End Ownership: Building a pipeline from the data source simulator all the way to a live dashboard gave me a holistic view of data engineering, reinforcing that the ultimate goal is always to deliver business value.

## 💯ACKNOWLEDGEMENTS

Project based on [Data with Jay] Spotify Data Analysis Pipeline idea

## 📄 LICENSE
This project is licensed under the MIT License - see the LICENSE file for details.

