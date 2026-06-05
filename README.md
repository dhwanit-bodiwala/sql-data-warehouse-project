# SQL Medallion Architecture Pipeline

An end-to-end SQL project built on **SQL Server**, progressing from raw data ingestion through to production-ready analytical views. Three interconnected projects built on the same dataset and database.

---

## Projects

| # | Project | Description |
|---|---------|-------------|
| 1 | [Data Warehouse](#1-data-warehouse) | ETL pipeline — raw CSV → Medallion Architecture → Star Schema |
| 2 | [Exploratory Data Analysis](#2-exploratory-data-analysis-eda) | SQL-based exploration of the Gold layer — distributions, rankings, time-series |
| 3 | [Advanced Analytics](#3-advanced-analytics) | Window functions, segmentation, cumulative metrics, and report views |

All three projects run on the same **DataWarehouse** SQL Server database and consume the same Gold layer (`gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`).

---

## Repository Structure

```
sql-data-warehouse-project/
│
├── data_warehouse/                  # Project 1 — ETL & Star Schema
│   ├── docs/
│   │   ├── data_architecture.jpeg
│   │   ├── data_flow.jpeg
│   │   ├── data_integration.jpeg
│   │   ├── data_model.jpeg
│   │   ├── data_catalog.md
│   │   └── naming_conventions.md
│   ├── scripts/
│   │   ├── setup/
│   │   ├── bronze/
│   │   ├── silver/
│   │   └── gold/
│   └── tests/
│
├── exploratory_data_analysis (EDA)/ # Project 2 — EDA
│   ├── 01_overview_metrics.sql
│   ├── 02_dimension_distributions.sql
│   ├── 03_rankings_top_n.sql
│   ├── 04_time_series_analysis.sql
│   └── 05_customer_segmentation_and_spend_analysis.sql
│
├── advance_analytics/               # Project 3 — Advanced Analytics
│   ├── 01_cumulative_analysis.sql
│   ├── 02_performance_analysis.sql
│   ├── 03_part_to_whole_analysis.sql
│   ├── 04_data_segmentation.sql
│   ├── 05_report_customers.sql
│   ├── 06_report_customers_monthly_spend.sql
│   ├── 07_report_products.sql
│   └── 08_report_products_monthly_revenue.sql
│
└── README.md
```

---

## 1. Data Warehouse

Builds the foundation — a three-layer Medallion Architecture on SQL Server that ingests raw CRM and ERP CSV files and produces a Star Schema in the Gold layer.

**Layers:**

| Layer | Type | Load Strategy | Purpose |
|-------|------|---------------|---------|
| Bronze | Tables | Truncate & Insert | Raw ingestion — data as-is from source |
| Silver | Tables | Truncate & Insert | Cleansed, standardized, deduplicated |
| Gold | Views | Query-time | Business-ready Star Schema |

**Gold Layer Output:**
- `gold.dim_customers` — customer demographics (CRM + ERP enriched)
- `gold.dim_products` — product catalogue with category and cost
- `gold.fact_sales` — sales transactions linked to both dimensions

→ [Data Warehouse README](data_warehouse/README.md)

---

## 2. Exploratory Data Analysis (EDA)

SQL-based exploration of the Gold layer across five analytical dimensions.

| Script | What it answers |
|--------|----------------|
| `01_overview_metrics.sql` | Total sales, orders, customers, products — wide and long format |
| `02_dimension_distributions.sql` | Customer and product distribution by country, gender, category |
| `03_rankings_top_n.sql` | Top/bottom products and customers by revenue and order frequency |
| `04_time_series_analysis.sql` | Revenue by year, month, week, and year-month combinations |
| `05_customer_segmentation_and_spend_analysis.sql` | Spend buckets, order frequency, above-average spenders, regional breakdown |

→ [EDA README](exploratory_data_analysis&#32;(EDA)/README.md)

---

## 3. Advanced Analytics

Window functions, segmentation logic, and production report views consumed by analysts.

| Script | What it does |
|--------|-------------|
| `01_cumulative_analysis.sql` | Monthly running total and moving average |
| `02_performance_analysis.sql` | YoY change and avg performance flag per product |
| `03_part_to_whole_analysis.sql` | Category revenue contribution % |
| `04_data_segmentation.sql` | Product cost buckets and customer VIP/Regular/New segments |
| `05_report_customers.sql` | `gold.report_customers` view — full customer profile |
| `06_report_customers_monthly_spend.sql` | `gold.report_customers_monthly_spend` view |
| `07_report_products.sql` | `gold.report_products` view — full product profile |
| `08_report_products_monthly_revenue.sql` | `gold.report_products_monthly_revenue` view |

→ [Advanced Analytics README](advance_analytics/README.md)

---

## Tech Stack

- **SQL Server** — database engine
- **T-SQL** — all ETL, stored procedures, window functions, and views
- **SSMS** — development and execution environment
- **Draw.io** — architecture and data model diagrams
- **Git / GitHub** — version control

---

## Author

**Dhwanit Bodiwala**  
Computer Engineering Student · Aspiring Data Engineer  
[github.com/dhwanit-bodiwala](https://github.com/dhwanit-bodiwala)

---

## License

This project is licensed under the [MIT License](LICENSE).
