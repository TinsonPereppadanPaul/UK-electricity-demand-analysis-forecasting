UK Electricity Demand Analysis & Forecasting (2009–2024)
Project Overview

This project focuses on analyzing historical electricity demand in England and Wales and building a machine learning model to forecast future demand.

The dataset contains 278,464 records and 19 variables, representing half-hourly electricity demand from 2009 to 2024. The goal of this project is to transform raw energy consumption data into actionable insights and predictive forecasts using modern data analytics tools.

This project demonstrates an end-to-end data analytics pipeline, including data cleaning, SQL analysis, business intelligence dashboarding, and machine learning forecasting.

Dataset

Source: UK electricity demand dataset

Time period: 2009 – 2024

Total records: 278,464 rows

Total columns: 19 features

Frequency: Half-hourly electricity demand

Key variable used:

england_wales_demand – electricity consumption value

Project Workflow
1 Data Cleaning and Preparation (Python)

Raw data was cleaned and prepared using Python (Pandas & NumPy) to ensure high data quality for analysis and modeling.

Main tasks performed:

Converted settlement_date to datetime format

Removed missing and inconsistent records

Structured the dataset for time-series analysis

Created time-based variables for analysis

Prepared the dataset for machine learning models

Feature engineering included:

Hour of day

Day of week

Month

Lag features (previous demand values)

These features help capture daily and seasonal electricity demand patterns.

2 Data Analysis using MySQL

To explore the dataset and extract insights, MySQL queries were used for analytical exploration.

Key SQL analysis included:

Identifying peak demand hours

Analyzing monthly electricity consumption trends

Calculating average electricity demand

Exploring seasonal patterns in energy usage

Detecting long-term demand trends

This step helped understand electricity consumption behavior before visualization.

3 Power BI Dashboard (Business Intelligence)

An interactive Power BI dashboard was developed to visualize electricity demand patterns.

The dashboard includes:

Key Visualizations

Electricity demand trend over time

Monthly seasonal demand patterns

Demand distribution analysis

Map visualizations

Interactive filters and slicers

DAX Measures

Custom DAX calculations were used to create business metrics such as:

Total Electricity Demand

Average Demand

These measures allow dynamic analysis and improved decision-making insights.

4 Machine Learning Forecasting (Python)

A machine learning model using XGBoost regression was developed to forecast future electricity demand.

The model uses historical data and engineered features to predict one month of future demand values.

Model features include:

Hour of day

Day of week

Month

Previous demand values (lag features)

This approach enables short-term electricity demand forecasting based on historical patterns.

Key Insights

Electricity demand shows clear daily patterns with peaks during evening hours.

Seasonal demand variation occurs, with higher usage during colder months.

Machine learning models can effectively predict short-term future electricity demand.

Technologies Used

Programming and Data Processing

Python

Pandas

NumPy

Database

MySQL

SQL Queries

Business Intelligence

Power BI

DAX

Machine Learning

XGBoost Regression

Skills Demonstrated

Data Cleaning and Preprocessing

SQL Data Analysis

Time Series Feature Engineering

Machine Learning Forecasting

Business Intelligence Dashboard Development

DAX Calculations


Project Architecture
Raw Dataset (CSV)
        │
        ▼
Python Data Cleaning (Pandas, NumPy)
        │
        ▼
Feature Engineering (Time features, Lag variables)
        │
        ▼
MySQL Data Analysis (SQL Queries)
        │
        ▼
Power BI Dashboard (DAX + Visualizations)
        │
        ▼
Machine Learning Model (XGBoost)
        │
        ▼
Future Electricity Demand Forecast

