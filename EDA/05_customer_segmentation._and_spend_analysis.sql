/*
==================================================================
EDA - Customer Segmentation & Spend Analysis
==================================================================
Script Purpose:
    Segments customers by total spend and order frequency using
    NTILE(3) bucketing. Identifies above-average spenders, maps
    spend buckets by country, and summarises bucket-level metrics.
    Useful for targeting, retention, and regional revenue analysis.

Tables Used:
    - gold.fact_sales
    - gold.dim_customers
==================================================================
*/

-- ==================================================================
-- 0. Quick Schema Inspection
-- ==================================================================
-- Scan both gold tables before analysis.
-- ==================================================================

SELECT * FROM gold.fact_sales;
SELECT * FROM gold.dim_customers;


-- ==================================================================
-- 1. Customer Spend Segmentation (High / Mid / Low)
-- ==================================================================
-- NTILE(3) divides all customers into three equal buckets ordered
-- by total spend DESC — top third = High, middle = Mid, rest = Low.
-- ==================================================================

SELECT
    b.customer_id,
    SUM(a.sales_amount)                                                     AS total_spend,
    CASE
        WHEN NTILE(3) OVER (ORDER BY SUM(a.sales_amount) DESC) = 1 THEN 'High'
        WHEN NTILE(3) OVER (ORDER BY SUM(a.sales_amount) DESC) = 2 THEN 'Mid'
        ELSE                                                                     'Low'
    END                                                                     AS spend_bucket
FROM gold.fact_sales        AS a
LEFT JOIN gold.dim_customers AS b ON a.customer_key = b.customer_key
GROUP BY b.customer_id;


-- ==================================================================
-- 2. Customer Order Frequency Segmentation
-- ==================================================================
-- Buckets customers by distinct order count:
--   Top third  → Frequent | Middle → Occasional | Bottom → One-Time
-- ==================================================================

SELECT
    b.customer_id,
    COUNT(DISTINCT a.sales_order_number)                                    AS total_orders,
    CASE
        WHEN NTILE(3) OVER (ORDER BY COUNT(DISTINCT a.sales_order_number) DESC) = 1 THEN 'Frequent'
        WHEN NTILE(3) OVER (ORDER BY COUNT(DISTINCT a.sales_order_number) DESC) = 2 THEN 'Occasional'
        ELSE                                                                                'One-Time'
    END                                                                     AS order_frequency
FROM gold.fact_sales        AS a
LEFT JOIN gold.dim_customers AS b ON a.customer_key = b.customer_key
GROUP BY b.customer_id;


-- ==================================================================
-- 3. Spend Bucket Summary — Customer Count & Avg Revenue
-- ==================================================================
-- Aggregates the segmentation from Query 1 to show how many
-- customers fall in each bucket and what they spend on average.
-- ==================================================================

SELECT
    spend_bucket,
    COUNT(*)                AS customer_count,
    AVG(total_spend)        AS avg_revenue
FROM (
    SELECT
        b.customer_id,
        SUM(a.sales_amount)                                                 AS total_spend,
        CASE
            WHEN NTILE(3) OVER (ORDER BY SUM(a.sales_amount) DESC) = 1 THEN 'High'
            WHEN NTILE(3) OVER (ORDER BY SUM(a.sales_amount) DESC) = 2 THEN 'Mid'
            ELSE                                                                 'Low'
        END                                                                 AS spend_bucket
    FROM gold.fact_sales        AS a
    LEFT JOIN gold.dim_customers AS b ON a.customer_key = b.customer_key
    GROUP BY b.customer_id
) AS segmented
GROUP BY spend_bucket
ORDER BY avg_revenue DESC;


-- ==================================================================
-- 4. Above-Average Spenders
-- ==================================================================
-- Filters to customers whose total spend exceeds the fleet average.
-- Uses ROW_NUMBER() to deduplicate per customer before comparing
-- against the window average.
-- ==================================================================

SELECT
    customer_id,
    total_spend
FROM (
    SELECT
        customer_id,
        total_spend,
        AVG(total_spend) OVER ()    AS avg_spend      -- fleet-wide average
    FROM (
        SELECT
            b.customer_id,
            SUM(a.sales_amount) OVER (PARTITION BY b.customer_id)           AS total_spend,
            ROW_NUMBER()        OVER (PARTITION BY b.customer_id
                                      ORDER BY a.sales_amount)              AS rn
        FROM gold.fact_sales        AS a
        LEFT JOIN gold.dim_customers AS b ON a.customer_key = b.customer_key
    ) AS ranked
    WHERE rn = 1                    -- one row per customer before averaging
) AS with_avg
WHERE total_spend > avg_spend;      -- keep only above-average spenders


-- ==================================================================
-- 5. Spend Bucket Distribution by Country
-- ==================================================================
-- Cross-tabulates spend segmentation with customer country to reveal
-- regional concentration of High / Mid / Low value customers.
-- ==================================================================

SELECT
    country,
    spend_bucket,
    COUNT(*)    AS customer_count
FROM (
    SELECT
        b.country,
        b.customer_id,
        SUM(a.sales_amount)                                                 AS total_spend,
        CASE
            WHEN NTILE(3) OVER (ORDER BY SUM(a.sales_amount) DESC) = 1 THEN 'High'
            WHEN NTILE(3) OVER (ORDER BY SUM(a.sales_amount) DESC) = 2 THEN 'Mid'
            ELSE                                                                 'Low'
        END                                                                 AS spend_bucket
    FROM gold.fact_sales        AS a
    LEFT JOIN gold.dim_customers AS b ON a.customer_key = b.customer_key
    GROUP BY b.customer_id, b.country
) AS segmented
GROUP BY country, spend_bucket
ORDER BY country, spend_bucket;
