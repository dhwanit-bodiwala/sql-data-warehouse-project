/*
==================================================================
Create ERP Tables in Bronze Layer
==================================================================

Script Purpose:
    Creates the ERP source tables in the bronze schema.

    These tables store raw customer, location, and product
    category data loaded directly from ERP source files.

WARNING:
    Ensure the bronze schema exists before executing this script.

    Modifying table structures after data loads may impact
    downstream ETL processes.
==================================================================
*/

-- Customer demographic information
CREATE TABLE bronze.erp_cust_az12 (
    cid         INT PRIMARY KEY NOT NULL,
    bdate       DATE NOT NULL,
    gender      VARCHAR(20)
);

-- Customer location information
CREATE TABLE bronze.erp_loc_a101 (
    cid         INT PRIMARY KEY NOT NULL,
    country     VARCHAR(20)
);

-- Product category information
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id              NVARCHAR(20) PRIMARY KEY NOT NULL,
    cat             VARCHAR(20) NOT NULL,
    subcat          VARCHAR(20) NOT NULL,
    maintainence    VARCHAR(20) NOT NULL
);
