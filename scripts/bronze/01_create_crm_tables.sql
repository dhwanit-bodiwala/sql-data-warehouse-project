/*
==================================================================
Create CRM Tables in Bronze Layer
==================================================================

Script Purpose:
    Creates the CRM source tables in the bronze schema.

    These tables store raw customer, product, and sales data
    loaded directly from source files before any cleansing
    or transformation is applied.

WARNING:
    Existing tables will be dropped and recreated.

    All data stored in these tables will be permanently deleted.
==================================================================
*/

-- Customer information
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(30) NOT NULL,
    cst_firstname       VARCHAR(30) NOT NULL,
    cst_lastname        VARCHAR(30) NOT NULL,
    cst_marital_status  CHAR(1) NOT NULL,
    cst_gndr            CHAR(1) NOT NULL,
    cst_create_date     DATE
);
GO

-- Product information
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id          INT PRIMARY KEY NOT NULL,
    prd_key         NVARCHAR(30) NOT NULL,
    prd_nm          NVARCHAR(40) NOT NULL,
    prd_cost        INT,
    prd_line        VARCHAR(20),
    prd_start_dt    DATE NOT NULL,
    prd_end_dt      DATE NULL
);
GO

-- Sales transaction details
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num     VARCHAR(20) NOT NULL,
    sls_prd_key     NVARCHAR(20) NOT NULL,
    sls_cust_id     INT NOT NULL,
    sls_order_dt    INT NOT NULL,
    sls_ship_dt     INT NOT NULL,
    sls_due_dt      INT NOT NULL,
    sls_sales       INT,
    sls_quantity    INT NOT NULL,
    sls_price       INT
);
GO
