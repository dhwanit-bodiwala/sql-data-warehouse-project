/*
==================================================================
Create ERP Tables in Silver Layer
==================================================================

Script Purpose:
    Creates the ERP tables in the silver schema.

    These tables store cleansed and standardized customer,
    location, and product category data after transformation
    from the bronze layer.

WARNING:
    Existing tables will be dropped and recreated.

    All data stored in these tables will be permanently deleted.
==================================================================
*/

-- Customer demographic information
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid             VARCHAR(20) NOT NULL,
    bdate           DATE,
    gen             VARCHAR(20),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Customer location information
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid              VARCHAR(20) NOT NULL,
    cntry            VARCHAR(20),
    dwh_create_date  DATETIME2 DEFAULT GETDATE()
);
GO

-- Product category information
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id              NVARCHAR(20) PRIMARY KEY NOT NULL,
    cat             VARCHAR(20) NOT NULL,
    subcat          VARCHAR(20) NOT NULL,
    maintainence    VARCHAR(20) NOT NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
