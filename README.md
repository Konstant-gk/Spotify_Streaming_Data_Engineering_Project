# Spotify Streaming Data Engineering Pipeline

A comprehensive end-to-end data engineering project that simulates, processes, and analyzes Spotify streaming events using modern data engineering tools and best practices. This project demonstrates the complete data lifecycle from real-time event generation to business intelligence dashboard.

## Project Overview

This project implements a production-ready data pipeline that processes streaming music events through multiple layers of data transformation. The architecture follows the medallion (Bronze-Silver-Gold) data lakehouse pattern, ensuring data quality and enabling scalable analytics.

The pipeline simulates Spotify streaming events, captures them in real-time via Kafka, stores them in object storage, orchestrates data movement with Apache Airflow, transforms data using dbt, and visualizes insights in Power BI. This end-to-end implementation showcases modern data engineering practices including event-driven architecture, containerization, infrastructure as code, and data transformation best practices.

## Objectives

The primary objectives of this project were to:

- **Build a Real-Time Data Pipeline**: Create a streaming data pipeline capable of processing events in near real-time using Kafka for event streaming and Python for data generation and consumption.

- **Implement Medallion Architecture**: Apply the Bronze-Silver-Gold data architecture pattern to ensure proper data quality, transformation, and business-ready analytics layers.

- **Demonstrate Modern Data Stack**: Integrate industry-standard tools including Kafka, MinIO, Apache Airflow, Snowflake, dbt, and Power BI to showcase proficiency with the modern data engineering ecosystem.

- **Orchestrate Complex Workflows**: Design and implement automated data workflows using Apache Airflow with proper error handling, retries, and scheduling capabilities.

- **Enable Business Intelligence**: Transform raw streaming data into actionable insights through structured transformations and interactive dashboards.

- **Apply Best Practices**: Implement code versioning, environment configuration, containerization, and infrastructure as code principles throughout the project.

## Architecture

The project follows a layered architecture pattern:

1. **Data Generation Layer**: Python-based simulator generates realistic Spotify streaming events with configurable parameters for users, songs, and event types.

2. **Streaming Layer**: Apache Kafka captures events in real-time, providing a distributed messaging system for event streaming with proper partitioning and consumer groups.

3. **Storage Layer**: MinIO (S3-compatible object storage) stores raw events in a partitioned structure (date/hour) for efficient data lake operations.

4. **Orchestration Layer**: Apache Airflow schedules and monitors data pipeline workflows, handling data extraction from MinIO and loading into Snowflake.

5. **Data Warehouse Layer**: Snowflake serves as the cloud data warehouse, storing data in Bronze (raw), Silver (cleaned), and Gold (aggregated) schemas.

6. **Transformation Layer**: dbt (data build tool) performs SQL-based transformations, implementing data quality checks, incremental models, and business logic.

7. **Analytics Layer**: Power BI dashboards provide interactive visualizations for business users to explore streaming analytics.

## Technology Stack

### Data Processing & Streaming
- **Apache Kafka**: Distributed event streaming platform for real-time data ingestion
- **Zookeeper**: Coordination service for Kafka cluster management
- **Kafdrop**: Web UI for Kafka cluster monitoring and topic exploration

### Storage & Data Lake
- **MinIO**: S3-compatible object storage for data lake implementation
- **Snowflake**: Cloud data warehouse for structured data storage and analytics

### Orchestration & Workflow
- **Apache Airflow**: Workflow orchestration platform for scheduling and monitoring data pipelines
- **PostgreSQL**: Metadata database for Airflow

### Data Transformation
- **dbt (data build tool)**: SQL-based transformation framework for analytics engineering
- **dbt-snowflake**: Snowflake adapter for dbt
- **dbt-utils**: Utility macros for common dbt transformations

### Data Generation & Consumption
- **Python 3.x**: Core programming language
- **kafka-python**: Python client for Apache Kafka
- **boto3**: AWS SDK for Python (used for MinIO S3-compatible API)
- **Faker**: Library for generating realistic fake data
- **python-dotenv**: Environment variable management

### Infrastructure & DevOps
- **Docker**: Containerization platform
- **Docker Compose**: Multi-container Docker application orchestration
- **Git**: Version control system

### Visualization
- **Power BI**: Business intelligence and data visualization platform


## Data Flow

1. **Event Generation**: The Python simulator (`Producer.py`) generates realistic Spotify streaming events (play, pause, skip, add_to_playlist) and publishes them to a Kafka topic.

2. **Event Consumption**: A Kafka consumer (`kafka-to-minio.py`) reads events from Kafka, batches them, and writes to MinIO object storage in a partitioned structure (`bronze/date=YYYY-MM-DD/hour=HH/`).

3. **Data Orchestration**: An Apache Airflow DAG runs hourly, extracting all JSON files from MinIO, combining them, and loading the raw data into Snowflake's Bronze schema.

4. **Data Transformation**: dbt models transform the data through three layers:
   - **Bronze**: Raw data as ingested from the pipeline
   - **Silver**: Cleaned and validated data with proper data types and null handling
   - **Gold**: Aggregated business metrics including top songs and user engagement analytics

5. **Visualization**: Power BI connects to Snowflake's Gold layer to create interactive dashboards for business users.

## Key Features

### Real-Time Event Streaming
- Configurable event generation with realistic user behavior simulation
- Kafka topic partitioning for scalable event processing
- Consumer groups for parallel processing and fault tolerance

### Data Quality & Validation
- Data type conversions and timestamp parsing in Silver layer
- Null value filtering and data quality checks
- Referential integrity through dbt source definitions

### Scalable Architecture
- Containerized infrastructure for easy deployment and scaling
- Partitioned storage structure for efficient data lake queries
- Incremental processing capabilities in dbt models

### Production-Ready Practices
- Environment variable management for secure configuration
- Error handling and retry logic in Airflow tasks
- Logging and monitoring throughout the pipeline
- Version-controlled code with proper project structure

## Results Summary

The pipeline successfully processes streaming events end-to-end, demonstrating:

- **Real-Time Processing**: Events flow from generation to storage in seconds
- **Data Quality**: Silver layer ensures clean, validated data with proper types
- **Business Insights**: Gold layer provides actionable metrics including:
  - Top songs by play count and skip rate
  - User engagement metrics by device type, country, and time period
  - Event type distribution and trends

- **Scalability**: Architecture supports horizontal scaling of Kafka consumers and parallel dbt model execution
- **Reliability**: Airflow orchestration ensures data pipeline reliability with automated scheduling and error recovery
