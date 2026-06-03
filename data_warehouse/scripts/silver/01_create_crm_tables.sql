/*
==================================================================
Create CRM Tables in Silver Layer
==================================================================

Script Purpose:
    Creates the CRM tables in the silver schema.

    These tables store cleansed and standardized customer,
    product, and sales data after transformation from the
    bronze layer.

WARNING:
    Existing tables will be dropped and recreated.

    All data stored in these tables will be permanently deleted.
==================================================================
*/

-- Customer information
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(30) NOT NULL,
    cst_firstname       VARCHAR(30),
    cst_lastname        VARCHAR(30),
    cst_marital_status  VARCHAR(10) NOT NULL,
    cst_gndr            VARCHAR(10) NOT NULL,
    cst_create_date     DATE,
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- Product information
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id          INT PRIMARY KEY NOT NULL,
    cat_id          NVARCHAR(30),
    prd_key         NVARCHAR(30) NOT NULL,
    prd_nm          NVARCHAR(40) NOT NULL,
    prd_cost        INT,
    prd_line        VARCHAR(20),
    prd_start_dt    DATE NOT NULL,
    prd_end_dt      DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Sales transaction details
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num     VARCHAR(20) NOT NULL,
    sls_prd_key     NVARCHAR(20) NOT NULL,
    sls_cust_id     INT NOT NULL,
    sls_order_dt    DATE,
    sls_ship_dt     DATE,
    sls_due_dt      DATE,
    sls_sales       INT,
    sls_quantity    INT NOT NULL,
    sls_price       INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
