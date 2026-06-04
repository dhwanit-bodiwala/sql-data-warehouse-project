/*
=============================================================================
Customer Report View  |  gold.report_customers
=============================================================================
Purpose:
    - Consolidates key customer metrics and behaviors into a single view
      for dashboard and reporting consumption.

Highlights:
    1. Gathers essential fields: name, age, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) based on
       lifespan and total spend.
    3. Classifies customers into age groups (Young, Middle-aged, Senior).
    4. Aggregates customer-level metrics:
       - total orders
       - total sales
       - total quantity purchased
       - total products
       - lifespan (in months)
    5. Calculates KPIs:
       - recency (months since last order)
       - average order value

Target Consumers:
    - Data Analysts building customer dashboards and reports.

Note:
    - For monthly avg spend breakdown per customer, use:
      gold.report_customers_monthly_spend
=============================================================================
*/

IF OBJECT_ID('gold.report_customers') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS

WITH customer_base AS (
    SELECT
        b.customer_id,
        b.first_name,
        b.last_name,
        DATEDIFF(YEAR, b.birthdate, GETDATE())                AS age,
        COUNT(a.order_date)                                   AS total_orders,
        SUM(a.sales_amount)                                   AS total_spend,
        SUM(a.quantity)                                       AS total_quantity,
        COUNT(DISTINCT a.product_key)                         AS total_products,
        MIN(a.order_date)                                     AS first_purchase_date,
        MAX(a.order_date)                                     AS last_purchase_date,
        DATEDIFF(MONTH, MIN(a.order_date), MAX(a.order_date)) AS lifespan,
        DATEDIFF(MONTH, MAX(a.order_date), GETDATE())         AS months_since_last_order,
        AVG(a.sales_amount)                                   AS avg_order_value
    FROM gold.fact_sales AS a
    LEFT JOIN gold.dim_customers AS b
        ON a.customer_key = b.customer_key
    GROUP BY b.customer_id, b.first_name, b.last_name, b.birthdate
),

customer_profile AS (
    SELECT
        customer_id,
        CONCAT(first_name, ' ', last_name)                    AS full_name,
        age,
        CASE
            WHEN age <= 34             THEN 'Young'
            WHEN age BETWEEN 35 AND 54 THEN 'Middle-aged'
            ELSE                            'Senior'
        END                                                   AS age_group,
        CASE
            WHEN lifespan >= 12 AND total_spend > 5000  THEN 'VIP'
            WHEN lifespan >= 12 AND total_spend <= 5000 THEN 'Regular'
            ELSE                                             'New'
        END                                                   AS customer_segment,
        total_orders,
        total_spend,
        total_quantity,
        total_products,
        lifespan,
        months_since_last_order,
        avg_order_value,
        first_purchase_date,
        last_purchase_date
    FROM customer_base
)

SELECT *
FROM customer_profile;
