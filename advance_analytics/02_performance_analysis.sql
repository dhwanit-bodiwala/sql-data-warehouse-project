/*
=============================================================================
Performance Analysis
=============================================================================
Purpose:
    - Analyzes yearly product sales performance against historical benchmarks.

Highlights:
    1. Yearly total sales per product aggregated from fact_sales.
    2. Average sales — product's historical avg across all years.
    3. YoY change — difference between current and previous year's sales.
    4. Avg performance flag — classifies each year as Above / At / Below
       the product's average.
=============================================================================
*/

SELECT
    YEAR(a.order_date)                                               AS year,
    b.product_id,
    SUM(a.sales_amount)                                              AS total_sales,
    AVG(SUM(a.sales_amount)) OVER (
        PARTITION BY b.product_id
    )                                                                AS avg_sales,
    SUM(a.sales_amount) - LAG(SUM(a.sales_amount), 1) OVER (
        PARTITION BY b.product_id
        ORDER BY YEAR(a.order_date)
    )                                                                AS yoy_change,
    CASE
        WHEN SUM(a.sales_amount) > AVG(SUM(a.sales_amount)) OVER (
            PARTITION BY b.product_id)                THEN 'Above Average'
        WHEN SUM(a.sales_amount) = AVG(SUM(a.sales_amount)) OVER (
            PARTITION BY b.product_id)                THEN 'Average'
        ELSE                                               'Below Average'
    END                                                              AS avg_performance
FROM gold.fact_sales AS a
LEFT JOIN gold.dim_products AS b
    ON a.product_key = b.product_key
WHERE a.order_date IS NOT NULL
GROUP BY b.product_id, YEAR(a.order_date)
ORDER BY b.product_id, YEAR(a.order_date);
