/*
=============================================================================
Data Segmentation
=============================================================================
Purpose:
    - Groups products and customers into meaningful segments for
      distribution analysis.

Highlights:
    1. Product cost segmentation — splits products into High / Mid / Low
       cost buckets using equal-sized tertiles (NTILE 3).
    2. Customer segmentation — classifies customers into VIP / Regular / New
       based on purchase lifespan and total spend.
=============================================================================
*/

-- ============================================================
-- Product Segmentation by Cost
-- ============================================================

WITH product_cost_segment AS (
    SELECT
        product_id,
        cost,
        NTILE(3) OVER (ORDER BY cost DESC) AS cost_tier
    FROM gold.dim_products
),

product_cost_bucket AS (
    SELECT
        *,
        CASE cost_tier
            WHEN 1 THEN 'High'
            WHEN 2 THEN 'Mid'
            ELSE        'Low'
        END AS cost_bucket
    FROM product_cost_segment
)

SELECT
    cost_bucket,
    COUNT(*) AS total_products
FROM product_cost_bucket
GROUP BY cost_bucket
ORDER BY total_products DESC;


-- ============================================================
-- Customer Segmentation by Spend & Lifespan
-- ============================================================

WITH customer_segmentation AS (
    SELECT
        b.customer_id,
        SUM(a.sales_amount)                                   AS total_spend,
        MIN(a.order_date)                                     AS first_purchase_date,
        MAX(a.order_date)                                     AS last_purchase_date,
        DATEDIFF(MONTH, MIN(a.order_date), MAX(a.order_date)) AS lifespan,
        CASE
            WHEN DATEDIFF(MONTH, MIN(a.order_date), MAX(a.order_date)) >= 12
                 AND SUM(a.sales_amount) > 5000  THEN 'VIP'
            WHEN DATEDIFF(MONTH, MIN(a.order_date), MAX(a.order_date)) >= 12
                 AND SUM(a.sales_amount) <= 5000 THEN 'Regular'
            ELSE                                     'New'
        END                                                   AS customer_segment
    FROM gold.fact_sales AS a
    LEFT JOIN gold.dim_customers AS b
        ON a.customer_key = b.customer_key
    GROUP BY b.customer_id
)

SELECT
    customer_segment,
    COUNT(*) AS total_customers
FROM customer_segmentation
GROUP BY customer_segment
ORDER BY total_customers DESC;
