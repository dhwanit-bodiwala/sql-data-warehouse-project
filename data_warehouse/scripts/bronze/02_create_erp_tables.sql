/*
==================================================================
Create ERP Tables in Bronze Layer
==================================================================

Script Purpose:
    Creates the ERP source tables in the bronze schema.

    These tables store raw customer, location, and product
    category data loaded directly from ERP source files.

WARNING:
    Existing tables will be dropped and recreated.

    All data stored in these tables will be permanently deleted.
==================================================================
*/

-- Customer demographic information
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid         VARCHAR(20) NOT NULL,
    bdate       DATE NOT NULL,
    gen         VARCHAR(20)
);
GO

-- Customer location information
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid         VARCHAR(20) NOT NULL,
    cntry       VARCHAR(20)
);
GO

-- Product category information
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id              NVARCHAR(20) PRIMARY KEY NOT NULL,
    cat             VARCHAR(20) NOT NULL,
    subcat          VARCHAR(20) NOT NULL,
    maintainence    VARCHAR(20) NOT NULL
);
GO
