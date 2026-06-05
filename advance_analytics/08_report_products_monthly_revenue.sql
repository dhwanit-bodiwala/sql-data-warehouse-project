/*
=============================================================================
Product Monthly Revenue View  |  gold.report_products_monthly_revenue
=============================================================================
Purpose:
    - Provides a month-level breakdown of average revenue per product
      for trend and seasonality analysis in dashboards.

Highlights:
    1. Calculates average sales amount per product per calendar month.
    2. Complements gold.report_products which operates at product grain.

Target Consumers:
    - Data Analysts building product revenue trend and seasonality dashboards.

Note:
    - This view operates at product + month grain (not product grain).
      Join with gold.report_products on product_id for full profile context.
=============================================================================
*/

IF OBJECT_ID('gold.report_products_monthly_revenue') IS NOT NULL
    DROP VIEW gold.report_products_monthly_revenue;
GO

CREATE VIEW gold.report_products_monthly_revenue AS

SELECT
    b.product_id,
    MONTH(a.order_date)  AS month,
    AVG(a.sales_amount)  AS avg_monthly_revenue
FROM gold.fact_sales AS a
LEFT JOIN gold.dim_products AS b
    ON a.product_key = b.product_key
GROUP BY b.product_id, MONTH(a.order_date);
