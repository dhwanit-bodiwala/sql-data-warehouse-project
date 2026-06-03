/*
==================================================================
EDA - Time-Series Analysis
==================================================================
Script Purpose:
    Analyses sales performance across time dimensions — year,
    month, week, and year-month combinations. Identifies
    seasonal patterns and peak revenue periods within the
    available data range.

Tables Used:
    - gold.fact_sales
==================================================================
*/

-- ==================================================================
-- 0. Quick Schema Inspection
-- ==================================================================

SELECT * FROM gold.fact_sales;


-- ==================================================================
-- 1. Revenue and Orders by Year
-- ==================================================================

SELECT
    YEAR(order_date)                            AS year,
    SUM(sales_amount)                           AS total_revenue,
    COUNT(DISTINCT sales_order_number)          AS total_orders
FROM gold.fact_sales
GROUP BY YEAR(order_date)
ORDER BY year ASC;


-- ==================================================================
-- 2. Revenue by Month (Chronological)
-- ==================================================================

SELECT
    MONTH(order_date)                           AS month_number,
    DATENAME(month, order_date)                 AS month_name,
    SUM(sales_amount)                           AS total_revenue
FROM gold.fact_sales
GROUP BY MONTH(order_date), DATENAME(month, order_date)
ORDER BY month_number;


-- ==================================================================
-- 3. Revenue by Week of Year
-- ==================================================================

SELECT
    DATEPART(week, order_date)                  AS week_number,
    SUM(sales_amount)                           AS total_revenue
FROM gold.fact_sales
GROUP BY DATEPART(week, order_date)
ORDER BY week_number;


-- ==================================================================
-- 4. Revenue by Year-Month Combination (Best Periods First)
-- ==================================================================
-- Granular view of revenue across every year-month pair.
-- Sorted by revenue descending to surface peak periods.
-- ==================================================================

SELECT
    YEAR(order_date)                            AS year,
    MONTH(order_date)                           AS month_number,
    SUM(sales_amount)                           AS total_revenue
FROM gold.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY total_revenue DESC, year, month_number;


-- ==================================================================
-- 5. Best Performing Month Overall (Across All Years)
-- ==================================================================
-- Collapses years to find which calendar month consistently
-- generates the highest revenue regardless of year.
-- ==================================================================

SELECT TOP 1
    MONTH(order_date)                           AS month_number,
    DATENAME(month, order_date)                 AS month_name,
    SUM(sales_amount)                           AS total_revenue
FROM gold.fact_sales
GROUP BY MONTH(order_date), DATENAME(month, order_date)
ORDER BY total_revenue DESC;
