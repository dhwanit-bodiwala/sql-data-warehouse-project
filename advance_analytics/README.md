# Advanced Analytics

Window functions, segmentation logic, cumulative metrics, and production-ready report views for analyst consumption. Eight scripts built on top of the Gold layer from the Data Warehouse project.

This is **Project 3 of 3** in this repository. Scripts 01–04 are analytical queries; scripts 05–08 are `CREATE VIEW` statements that expose production views in the Gold schema.

---

## Scripts

| Script | Type | What it builds |
|--------|------|---------------|
| `01_cumulative_analysis.sql` | Query | Monthly running total + moving average |
| `02_performance_analysis.sql` | Query | YoY change and avg performance flag per product per year |
| `03_part_to_whole_analysis.sql` | Query | Revenue contribution % per product category |
| `04_data_segmentation.sql` | Query | Product cost buckets + customer VIP/Regular/New segments |
| `05_report_customers.sql` | View | `gold.report_customers` — full customer profile |
| `06_report_customers_monthly_spend.sql` | View | `gold.report_customers_monthly_spend` — avg spend by month |
| `07_report_products.sql` | View | `gold.report_products` — full product profile |
| `08_report_products_monthly_revenue.sql` | View | `gold.report_products_monthly_revenue` — avg revenue by month |

---

## Script Details

### `01_cumulative_analysis.sql` — Cumulative Analysis
Tracks sales momentum over time using cumulative and rolling metrics.

| Column | Description |
|--------|-------------|
| `month` | Truncated to month using `DATETRUNC()` |
| `total_sales` | Monthly sales aggregate |
| `running_total` | Cumulative sum from start to current month (`ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`) |
| `moving_avg` | Rolling average of monthly sales up to current month |

---

### `02_performance_analysis.sql` — Performance Analysis
Compares each product's yearly sales against its own historical average and the prior year.

| Column | Description |
|--------|-------------|
| `total_sales` | Sales for that product in that year |
| `avg_sales` | Product's average across all years (`AVG() OVER PARTITION BY product_id`) |
| `yoy_change` | Current year minus previous year (`LAG()`) |
| `avg_performance` | `Above Average` / `Average` / `Below Average` flag |

---

### `03_part_to_whole_analysis.sql` — Part-to-Whole Analysis
Shows each product category's share of total revenue.

Uses a CTE to aggregate category-level sales, then computes contribution % with `SUM() OVER()` as the denominator. Result sorted by revenue descending.

---

### `04_data_segmentation.sql` — Data Segmentation
Two independent segmentation analyses:

**Product cost segmentation** — splits products into equal tertiles by cost using `NTILE(3)`:
- `High` / `Mid` / `Low` cost buckets
- Implemented across two CTEs to avoid computing `NTILE` twice

**Customer lifecycle segmentation** — classifies customers by lifespan and total spend:
- `VIP` — lifespan ≥ 12 months AND spend > 5,000
- `Regular` — lifespan ≥ 12 months AND spend ≤ 5,000
- `New` — lifespan < 12 months

---

### `05_report_customers.sql` — Customer Report View

**View:** `gold.report_customers`  
**Grain:** One row per customer  
**Target consumers:** Data Analysts building customer dashboards

Built with two CTEs:

`customer_base` — raw aggregates per customer:
- Age, total orders, total spend, total quantity, total products
- First/last purchase date, lifespan, months since last order, avg order value

`customer_profile` — derived fields on top of base:
- `full_name` — concatenated first + last name
- `age_group` — Young (≤34) / Middle-aged (35–54) / Senior (55+)
- `customer_segment` — VIP / Regular / New

> For monthly avg spend breakdown, use `gold.report_customers_monthly_spend`

---

### `06_report_customers_monthly_spend.sql` — Customer Monthly Spend View

**View:** `gold.report_customers_monthly_spend`  
**Grain:** One row per customer per calendar month  
**Target consumers:** Analysts building spend trend and seasonality dashboards

Calculates average `sales_amount` per customer per calendar month. Companion view to `gold.report_customers` — join on `customer_id` for full profile context.

---

### `07_report_products.sql` — Product Report View

**View:** `gold.report_products`  
**Grain:** One row per product  
**Target consumers:** Data Analysts building product performance dashboards

Built with two CTEs:

`product_base` — raw aggregates per product:
- Product name, category, subcategory, cost
- Total orders, total sales, total quantity, total customers
- First/last sale date, lifespan, months since last sale, avg order revenue

`product_profile` — derived fields:
- `revenue_segment` — High-Performers / Mid-Range / Low-Performers (NTILE 3 by total sales)

> For monthly avg revenue breakdown, use `gold.report_products_monthly_revenue`

---

### `08_report_products_monthly_revenue.sql` — Product Monthly Revenue View

**View:** `gold.report_products_monthly_revenue`  
**Grain:** One row per product per calendar month  
**Target consumers:** Analysts building product revenue trend and seasonality dashboards

Calculates average `sales_amount` per product per calendar month. Companion view to `gold.report_products` — join on `product_id` for full profile context.

---

## Gold Views Produced

| View | Grain | Key Fields |
|------|-------|-----------|
| `gold.report_customers` | Per customer | full_name, age_group, customer_segment, total_orders, total_spend, lifespan, months_since_last_order, avg_order_value |
| `gold.report_customers_monthly_spend` | Customer + month | customer_id, month, avg_monthly_spend |
| `gold.report_products` | Per product | product_name, category, revenue_segment, total_orders, total_sales, total_customers, lifespan, avg_order_revenue |
| `gold.report_products_monthly_revenue` | Product + month | product_id, month, avg_monthly_revenue |

---

## Key SQL Techniques

- `SUM() OVER()`, `AVG() OVER()` — window aggregates
- `LAG()` — year-over-year comparison
- `NTILE()` — equal-sized bucketing
- `DATETRUNC()` — month-level date truncation
- `DATEDIFF()` — lifespan and recency calculations
- CTEs — multi-step logic without subquery nesting
- `CREATE VIEW` with `IF OBJECT_ID ... DROP VIEW` — idempotent view creation
