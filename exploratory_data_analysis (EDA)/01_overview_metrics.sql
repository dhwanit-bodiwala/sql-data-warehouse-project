/*
==================================================================
EDA - High-Level Business Metrics Overview
==================================================================
Script Purpose:
    Provides a top-level summary of key business metrics across
    sales, customers, and products. Intended as the entry point
    for exploratory analysis — establishing baseline numbers
    before any segmentation or deeper investigation.

    Two formats are provided:
        1. Wide format  — single-row result, useful for dashboards
        2. Long format  — unpivoted key-value pairs, useful for
                          quick comparison and reporting tools

Tables Used:
    - gold.fact_sales
    - gold.dim_products
    - gold.dim_customers
==================================================================
*/

-- ==================================================================
-- 1. Wide Format — All Metrics in a Single Row
-- ==================================================================
-- Aggregates core business KPIs into one horizontal result.
-- Subqueries for totalProducts and totalCustomers reflect
-- catalog/customer base size independent of sales activity.
-- totalCustomers_withOrders isolates only customers who transacted.
-- ==================================================================

SELECT
    SUM(a.sales_amount)                         AS total_sales,
    SUM(a.quantity)                             AS items_sold,
    AVG(a.price)                                AS avg_price,
    COUNT(DISTINCT a.sales_order_number)        AS total_orders,
    (SELECT COUNT(*) FROM gold.dim_products)    AS total_products,
    (SELECT COUNT(*) FROM gold.dim_customers)   AS total_customers,
    COUNT(DISTINCT a.customer_key)              AS total_customers_with_orders
FROM gold.fact_sales        AS a
LEFT JOIN gold.dim_products  AS b ON a.product_key  = b.product_key
LEFT JOIN gold.dim_customers AS c ON a.customer_key = c.customer_key;


-- ==================================================================
-- 2. Long Format — Metrics as Key-Value Pairs (Unpivoted)
-- ==================================================================
-- Presents the same KPIs as rows rather than columns.
-- Easier to extend — adding a new metric = one UNION ALL block.
-- ==================================================================

SELECT 'total_sales'                AS measure_name, SUM(sales_amount)               AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'items_sold'                 AS measure_name, SUM(quantity)                   AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'avg_price'                  AS measure_name, AVG(price)                      AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'total_orders'               AS measure_name, COUNT(DISTINCT sales_order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'total_products'             AS measure_name, COUNT(*)                        AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'total_customers'            AS measure_name, COUNT(*)                        AS measure_value FROM gold.dim_customers
UNION ALL
SELECT 'total_customers_with_orders' AS measure_name, COUNT(DISTINCT customer_key)  AS measure_value FROM gold.fact_sales;
