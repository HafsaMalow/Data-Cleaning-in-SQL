# 🧹 Data Cleaning and Exploratory Data Analysis (EDA) in SQL

This repository showcases my SQL skills in importing, cleaning, and exploring datasets to uncover actionable insights. The project is split into two primary phases: data cleaning (transforming messy raw data into a structured format) and exploratory data analysis (writing analytical queries to answer key business questions).

## 📁 Repository Structure

*   **`Data Cleaning .sql`**: Contains queries focused on cleaning and preparing the raw data. This includes handling missing values, standardizing formats, removing duplicates, and structuring tables for analysis.
*   **`EDA.sql`**: Contains exploratory queries designed to analyze trends, aggregate metrics, and extract insights from the cleaned dataset.

---

## 🛠️ Key SQL Techniques Applied

### 1. Data Cleaning Phase
In the `Data Cleaning .sql` script, the following database hygiene practices were implemented:
*   **Standardizing Data Formats:** Converting text dates to actual date formats and unifying inconsistent text entries.
*   **Handling Null & Missing Values:** Populating missing records using joins on matching fields.
*   **Breaking Out Columns:** Splitting combined address strings into separate columns (e.g., Street, City, State) using functions like `SUBSTRING` or `PARSENAME`.
*   **Removing Duplicates:** Detecting and removing redundant rows using CTEs (Common Table Expressions) and window functions like `ROW_NUMBER()`.
*   **Dropping Unused Columns:** Streamlining the final database schema by removing obsolete raw columns.

### 2. Exploratory Data Analysis (EDA) Phase
In the `EDA.sql` script, analytical queries were built to explore the data using:
*   **Aggregations & Grouping:** Using `GROUP BY`, `SUM`, `AVG`, `COUNT`, and `HAVING` to summarize metrics.
*   **Temporary Tables & CTEs:** Breaking complex multi-step analysis down into readable, modular queries.
*   **Window Functions:** Utilizing `PARTITION BY`, `RANK()`, and rolling sums to analyze performance over time.

