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
    Ensure the bronze schema exists before executing this script.

    Modifying table structures after data loads may impact
    downstream ETL processes.
==================================================================
*/

-- Customer information
CREATE TABLE bronze.crm_cust_info (
    cst_id              INT PRIMARY KEY NOT NULL,
    cst_key             NVARCHAR(30) NOT NULL,
    cst_firstname       VARCHAR(30) NOT NULL,
    cst_lastname        VARCHAR(30) NOT NULL,
    cst_marital_status  CHAR(1) NOT NULL,
    cst_gndr            CHAR(1) NOT NULL,
    cst_create_date     DATE NOT NULL
);

-- Product information
CREATE TABLE bronze.crm_prd_info (
    prd_id          INT PRIMARY KEY NOT NULL,
    prd_key         NVARCHAR(30) NOT NULL,
    prd_nm          NVARCHAR(40) NOT NULL,
    prd_cost        INT NOT NULL,
    prd_line        CHAR(1) NOT NULL,
    prd_start_dt    DATE NOT NULL,
    prd_end_dt      DATE NULL
);

-- Sales transaction details
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num     VARCHAR(20) NOT NULL,
    sls_prd_key     NVARCHAR(20) NOT NULL,
    sls_cust_id     INT NOT NULL,
    sls_order_dt    INT NOT NULL,
    sls_ship_dt     INT NOT NULL,
    sls_due_dt      INT NOT NULL,
    sls_sales       INT NOT NULL,
    sls_quantity    INT NOT NULL,
    sls_price       INT NOT NULL
);
