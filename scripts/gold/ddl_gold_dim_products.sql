/*
==================================================================
Create Product Dimension
==================================================================

Purpose:
    Creates the Gold Layer Product Dimension by combining
    product information from CRM and ERP sources.

Source Tables:
    - silver.crm_prd_info
    - silver.erp_px_cat_g1v2

Business Rules:
    - CRM is the primary product source.
    - ERP category data enriches product records.
    - Only current/active products are included.
==================================================================
*/

IF OBJECT_ID('gold.dim_products') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS

SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            a.prd_start_dt,
            a.prd_key
    ) AS product_key,

    a.prd_id             AS product_id,
    a.prd_key            AS product_number,
    a.prd_nm             AS product_name,

    a.cat_id             AS category_id,
    b.cat                AS category,
    b.subcat             AS subcategory,
    b.maintainence       AS maintainence,

    a.prd_cost           AS cost,
    a.prd_line           AS product_line,
    a.prd_start_dt       AS start_date

FROM silver.crm_prd_info AS a

LEFT JOIN silver.erp_px_cat_g1v2 AS b
    ON a.cat_id = b.id

WHERE a.prd_end_dt IS NULL;
GO
