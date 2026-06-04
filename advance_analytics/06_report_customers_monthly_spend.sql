/*
=============================================================================
Customer Monthly Spend View  |  gold.report_customers_monthly_spend
=============================================================================
Purpose:
    - Provides a month-level breakdown of average spend per customer
      for trend and seasonality analysis in dashboards.

Highlights:
    1. Calculates average sales amount per customer per calendar month.
    2. Complements gold.report_customers which operates at customer grain.

Target Consumers:
    - Data Analysts building customer spend trend and seasonality dashboards.

Note:
    - This view operates at customer + month grain (not customer grain).
      Join with gold.report_customers on customer_id for full profile context.
=============================================================================
*/

IF OBJECT_ID('gold.report_customers_monthly_spend') IS NOT NULL
    DROP VIEW gold.report_customers_monthly_spend;
GO

CREATE VIEW gold.report_customers_monthly_spend AS

SELECT
    b.customer_id,
    MONTH(a.order_date)  AS month,
    AVG(a.sales_amount)  AS avg_monthly_spend
FROM gold.fact_sales AS a
LEFT JOIN gold.dim_customers AS b
    ON a.customer_key = b.customer_key
GROUP BY b.customer_id, MONTH(a.order_date);
