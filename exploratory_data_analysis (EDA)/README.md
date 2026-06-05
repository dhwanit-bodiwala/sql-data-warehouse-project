# Exploratory Data Analysis (EDA)

SQL-based exploration of the Gold layer built in the Data Warehouse project. Five scripts cover the full analytical surface of the dataset — from high-level KPIs down to customer spend behaviour and regional breakdowns.

This is **Project 2 of 3** in this repository. All queries run directly against the Gold layer views produced by the Data Warehouse project.

---

## What's Explored

| Script | Focus | Key Techniques |
|--------|-------|---------------|
| `01_overview_metrics.sql` | Business KPIs | Aggregates, subqueries, UNION ALL (wide + long format) |
| `02_dimension_distributions.sql` | Distributions | GROUP BY, window functions, percentage share |
| `03_rankings_top_n.sql` | Top/Bottom N | TOP N, ROW_NUMBER(), revenue and order ranking |
| `04_time_series_analysis.sql` | Sales over time | YEAR(), MONTH(), DATENAME(), DATEPART() |
| `05_customer_segmentation_and_spend_analysis.sql` | Customer behaviour | NTILE(), subqueries, above-average filtering |

---

## Script Details

### `01_overview_metrics.sql` — High-Level Business Metrics
Entry point for the analysis. Establishes baseline numbers across sales, customers, and products before any segmentation.

Produces two formats:
- **Wide format** — all KPIs in a single row (dashboard-ready)
- **Long format** — unpivoted key-value pairs (easy to extend with UNION ALL)

Metrics covered: total sales, items sold, avg price, total orders, total products, total customers, customers with orders.

---

### `02_dimension_distributions.sql` — Distribution Analysis
Explores how customers, products, and sales are distributed across core business dimensions.

Queries:
1. Customer count by country
2. Customer count by gender
3. Product count by category
4. Average product cost by category
5. Total revenue by product category
6. Total revenue per customer
7. Item sales distribution by country with % share (window functions)

---

### `03_rankings_top_n.sql` — Rankings and Top-N Analysis
Identifies best and worst performers across products and customers.

Queries:
1. Top 5 products by revenue
2. Bottom 5 products by revenue
3. Top 5 products with explicit ROW_NUMBER() rank
4. Top 10 customers by revenue with rank
5. Bottom 3 customers by units purchased (churn/re-engagement signal)

---

### `04_time_series_analysis.sql` — Time-Series Analysis
Analyses sales performance across time dimensions to identify seasonal patterns and peak periods.

Queries:
1. Revenue and orders by year
2. Revenue by calendar month (chronological)
3. Revenue by week of year
4. Revenue by year-month combination (best periods first)
5. Best performing calendar month overall across all years

---

### `05_customer_segmentation_and_spend_analysis.sql` — Customer Segmentation
Segments customers by spend and order frequency. Identifies above-average spenders and maps spend distribution by country.

Queries:
1. Customer spend segmentation — High / Mid / Low (NTILE 3 by total spend)
2. Order frequency segmentation — Frequent / Occasional / One-Time (NTILE 3 by order count)
3. Spend bucket summary — customer count and avg revenue per bucket
4. Above-average spenders — customers whose total spend exceeds the fleet average
5. Spend bucket distribution by country — regional concentration of value segments

---

## Tables Used

All queries run against the Gold layer:

| Table | Description |
|-------|-------------|
| `gold.fact_sales` | Sales transactions (orders, amounts, quantities, dates) |
| `gold.dim_customers` | Customer demographics (country, gender, birthdate) |
| `gold.dim_products` | Product catalogue (category, subcategory, cost) |

---

## Key SQL Techniques

- Aggregate functions with `GROUP BY`
- Window functions: `SUM() OVER()`, `ROW_NUMBER() OVER()`, `NTILE()`
- Subqueries and derived tables
- `UNION ALL` for long-format unpivoting
- `TOP N` with `ORDER BY` for ranking
- Date functions: `YEAR()`, `MONTH()`, `DATENAME()`, `DATEPART()`
- Percentage share calculation with `CAST(... AS FLOAT)`
