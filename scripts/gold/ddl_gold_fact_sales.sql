/*

# Create Fact Sales View

Purpose:
Creates the sales fact view for the Gold Layer.

Business Rules:
- Maps sales transactions to product dimension keys.
- Maps sales transactions to customer dimension keys.
- Exposes cleansed sales measures and dates.
- Serves as the central fact table for analytical reporting.
============================================================

*/

IF OBJECT_ID('gold.fact_sales') IS NOT NULL
DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS

SELECT
a.sls_ord_num      AS sales_order_number,
b.product_key      AS product_key,
c.customer_key     AS customer_key,


a.sls_order_dt     AS order_date,
a.sls_ship_dt      AS shipping_date,
a.sls_due_dt       AS due_date,

a.sls_sales        AS sales_amount,
a.sls_quantity     AS quantity,
a.sls_price        AS price


FROM silver.crm_sales_details AS a

LEFT JOIN gold.dim_products AS b
ON a.sls_prd_key = b.product_number

LEFT JOIN gold.dim_customers AS c
ON a.sls_cust_id = c.customer_id;
GO
