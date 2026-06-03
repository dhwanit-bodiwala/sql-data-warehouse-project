/*
==================================================================
EDA - Rankings and Top-N Analysis
==================================================================
Script Purpose:
    Identifies top and bottom performers across products and
    customers using both simple TOP N ordering and ROW_NUMBER()
    window-based ranking. Useful for spotting revenue drivers,
    slow-moving products, and high/low-value customer segments.

Tables Used:
    - gold.fact_sales
    - gold.dim_products
    - gold.dim_customers
==================================================================
*/

-- ==================================================================
-- 0. Quick Schema Inspection
-- ==================================================================
-- Scan all three gold tables before analysis.
-- ==================================================================

SELECT * FROM gold.fact_sales;
SELECT * FROM gold.dim_customers;
SELECT * FROM gold.dim_products;


-- ==================================================================
-- 1. Top 5 Products by Revenue (Best Performers)
-- ==================================================================

SELECT TOP 5
    b.product_name,
    SUM(a.sales_amount)     AS total_revenue
FROM gold.fact_sales        AS a
LEFT JOIN gold.dim_products AS b ON a.product_key = b.product_key
GROUP BY b.product_name
ORDER BY total_revenue DESC;


-- ==================================================================
-- 2. Bottom 5 Products by Revenue (Worst Performers)
-- ==================================================================

SELECT TOP 5
    b.product_name,
    SUM(a.sales_amount)     AS total_revenue
FROM gold.fact_sales        AS a
LEFT JOIN gold.dim_products AS b ON a.product_key = b.product_key
GROUP BY b.product_name
ORDER BY total_revenue ASC;


-- ==================================================================
-- 3. Top 5 Products by Revenue with Explicit Rank
-- ==================================================================
-- ROW_NUMBER() assigns a persistent rank visible in the result set,
-- useful when downstream queries need to filter or reference rank.
-- ==================================================================

SELECT TOP 5
    b.product_name,
    SUM(a.sales_amount)                                         AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(a.sales_amount) DESC)       AS rank
FROM gold.fact_sales        AS a
LEFT JOIN gold.dim_products AS b ON a.product_key = b.product_key
GROUP BY b.product_name
ORDER BY rank;


-- ==================================================================
-- 4. Top 10 Customers by Revenue with Explicit Rank
-- ==================================================================

SELECT TOP 10
    b.customer_id,
    SUM(a.sales_amount)                                         AS total_revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(a.sales_amount) DESC)       AS rank
FROM gold.fact_sales            AS a
LEFT JOIN gold.dim_customers    AS b ON a.customer_key = b.customer_key
GROUP BY b.customer_id
ORDER BY rank;


-- ==================================================================
-- 5. Bottom 3 Customers by Units Purchased (Least Active)
-- ==================================================================
-- Ranked by total quantity ASC — surfaces customers with the
-- fewest items purchased, useful for churn or re-engagement analysis.
-- ==================================================================

SELECT TOP 3
    b.customer_key,
    b.first_name,
    b.last_name,
    COUNT(DISTINCT a.sales_order_number)                        AS total_orders,
    ROW_NUMBER() OVER (ORDER BY SUM(a.quantity) ASC)            AS rank
FROM gold.fact_sales            AS a
LEFT JOIN gold.dim_customers    AS b ON a.customer_key = b.customer_key
GROUP BY b.customer_key, b.first_name, b.last_name
ORDER BY rank;
