/*
==================================================================
EDA - Distribution Analysis Across Key Dimensions
==================================================================
Script Purpose:
    Explores how customers, products, and sales are distributed
    across core business dimensions — geography, gender, and
    product category. Establishes the shape of the data before
    any time-based or behavioural analysis.

Tables Used:
    - gold.dim_customers
    - gold.dim_products
    - gold.fact_sales
==================================================================
*/

-- ==================================================================
-- 1. Customer Distribution by Country
-- ==================================================================

SELECT
    country,
    COUNT(*)    AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;


-- ==================================================================
-- 2. Customer Distribution by Gender
-- ==================================================================

SELECT
    gender,
    COUNT(*)    AS total_customers
FROM gold.dim_customers
GROUP BY gender;


-- ==================================================================
-- 3. Product Count by Category
-- ==================================================================

SELECT
    category,
    COUNT(*)    AS total_products
FROM gold.dim_products
GROUP BY category;


-- ==================================================================
-- 4. Average Product Cost by Category
-- ==================================================================

SELECT
    category,
    AVG(cost)   AS avg_cost
FROM gold.dim_products
GROUP BY category;


-- ==================================================================
-- 5. Total Revenue by Product Category
-- ==================================================================

SELECT
    b.category,
    SUM(a.price)    AS total_revenue
FROM gold.fact_sales        AS a
LEFT JOIN gold.dim_products AS b ON a.product_key = b.product_key
GROUP BY b.category;


-- ==================================================================
-- 6. Total Revenue per Customer
-- ==================================================================

SELECT
    b.customer_id,
    SUM(a.price)    AS total_revenue
FROM gold.fact_sales            AS a
LEFT JOIN gold.dim_customers    AS b ON a.customer_key = b.customer_key
GROUP BY b.customer_id
ORDER BY b.customer_id ASC;


-- ==================================================================
-- 7. Item Sales Distribution by Country (with % Share)
-- ==================================================================
-- Window functions compute country-level and global totals in one
-- pass, avoiding a self-join. Percentage share shows each country's
-- contribution to total units sold.
-- ==================================================================

SELECT DISTINCT
    b.country,
    SUM(a.quantity) OVER (PARTITION BY b.country)   AS items_sold_per_country,
    SUM(a.quantity) OVER ()                         AS items_sold_total,
    ROUND(
        SUM(a.quantity) OVER (PARTITION BY b.country)
        / CAST(SUM(a.quantity) OVER () AS FLOAT) * 100
    , 2)                                            AS pct_share
FROM gold.fact_sales            AS a
LEFT JOIN gold.dim_customers    AS b ON a.customer_key = b.customer_key;
