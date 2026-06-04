/*
=============================================================================
Part-to-Whole Analysis
=============================================================================
Purpose:
    - Evaluates each product category's contribution to overall sales revenue.

Highlights:
    1. Total sales aggregated per category from fact_sales.
    2. Contribution % — each category's share of total revenue across
       all categories.
=============================================================================
*/

WITH category_sales AS (
    SELECT
        b.category,
        SUM(a.sales_amount) AS total_sales
    FROM gold.fact_sales AS a
    LEFT JOIN gold.dim_products AS b
        ON a.product_key = b.product_key
    GROUP BY b.category
)

SELECT
    category,
    total_sales,
    CONCAT(
        ROUND(
            total_sales / CAST(SUM(total_sales) OVER() AS FLOAT) * 100
        , 2),
    ' %')                AS contribution_pct
FROM category_sales
ORDER BY total_sales DESC;
