/*
==================================================================
Create Customer Dimension
==================================================================

Purpose:
    Creates the Gold Layer Customer Dimension by combining
    customer information from CRM and ERP sources.

Source Tables:
    - silver.crm_cust_info
    - silver.erp_cust_az12
    - silver.erp_loc_a101

Business Rules:
    - CRM is the primary customer source.
    - ERP data enriches customer records.
    - CRM gender takes precedence over ERP gender.
    - ERP gender is used when CRM gender is unavailable.
==================================================================
*/

IF OBJECT_ID('gold.dim_customers') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS

SELECT
    ROW_NUMBER() OVER (
        ORDER BY a.cst_id
    ) AS customer_key,

    a.cst_id               AS customer_id,
    a.cst_key              AS customer_number,
    a.cst_firstname        AS first_name,
    a.cst_lastname         AS last_name,

    c.cntry                AS country,

    a.cst_marital_status   AS marital_status,

    CASE
        WHEN COALESCE(a.cst_gndr, 'N/A') = 'N/A'
            THEN COALESCE(b.gen, 'N/A')
        ELSE a.cst_gndr
    END AS gender,

    b.bdate                AS birthdate,
    a.cst_create_date      AS create_date

FROM silver.crm_cust_info AS a

LEFT JOIN silver.erp_cust_az12 AS b
    ON a.cst_key = b.cid

LEFT JOIN silver.erp_loc_a101 AS c
    ON a.cst_key = c.cid;
GO
