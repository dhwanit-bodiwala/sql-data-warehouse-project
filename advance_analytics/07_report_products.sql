/*
=============================================================================
Product Report View  |  gold.report_products
=============================================================================
Purpose:
    - Consolidates key product metrics and behaviors into a single view
      for dashboard and reporting consumption.

Highlights:
    1. Gathers essential fields: product name, category, subcategory, cost.
    2. Segments products by revenue (High-Performers, Mid-Range, Low-Performers)
       using equal-sized tertiles (NTILE 3).
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)

Target Consumers:
    - Data Analysts building product performance dashboards and reports.

Note:
    - For monthly avg revenue breakdown per product, use:
      gold.report_products_monthly_revenue
=============================================================================
*/

IF OBJECT_ID('gold.report_products') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH product_base AS (
    SELECT
        b.product_id,
        b.product_name,
        b.category,
        b.subcategory,
        b.cost,
        COUNT(DISTINCT a.sales_order_number)                  AS total_orders,
        SUM(a.sales_amount)                                   AS total_sales,
        SUM(a.quantity)                                       AS total_quantity,
        COUNT(DISTINCT a.customer_key)                        AS total_customers,
        MIN(a.order_date)                                     AS first_sale_date,
        MAX(a.order_date)                                     AS last_sale_date,
        DATEDIFF(MONTH, MIN(a.order_date), MAX(a.order_date)) AS lifespan,
        DATEDIFF(MONTH, MAX(a.order_date), GETDATE())         AS months_since_last_sale,
        AVG(a.sales_amount)                                   AS avg_order_revenue
    FROM gold.fact_sales AS a
    LEFT JOIN gold.dim_products AS b
        ON a.product_key = b.product_key
    GROUP BY b.product_id, b.product_name, b.category, b.subcategory, b.cost
),

product_profile AS (
    SELECT
        product_id,
        product_name,
        category,
        subcategory,
        cost,
        CASE
            WHEN NTILE(3) OVER (ORDER BY total_sales DESC) = 1 THEN 'High-Performers'
            WHEN NTILE(3) OVER (ORDER BY total_sales DESC) = 2 THEN 'Mid-Range'
            ELSE                                                     'Low-Performers'
        END                  AS revenue_segment,
        total_orders,
        total_sales,
        total_quantity,
        total_customers,
        lifespan,
        months_since_last_sale,
        avg_order_revenue,
        first_sale_date,
        last_sale_date
    FROM product_base
)

SELECT *
FROM product_profile;
