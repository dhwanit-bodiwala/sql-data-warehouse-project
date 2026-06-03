/*
==================================================================
Load Data into Bronze Layer
==================================================================

Script Purpose:
    Loads raw CRM and ERP data from source CSV files into
    the bronze layer tables.

    Existing data is removed before loading to prevent
    duplicate records from multiple executions.

WARNING:
    This script truncates all bronze tables before loading.

    Any existing data in the bronze layer will be deleted.
==================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @proc_start_time DATETIME2,
                @proc_end_time DATETIME2,
                @start_time DATETIME2,
                @end_time DATETIME2,
                @crm_start_time DATETIME2,
                @crm_end_time DATETIME2,
                @erp_start_time DATETIME2,
                @erp_end_time DATETIME2;

        SET @proc_start_time = SYSDATETIME();

        PRINT '=======================';
        PRINT 'Loading Bronze Layer';
        PRINT '=======================';

        -- Truncate CRM tables
        PRINT 'Truncating CRM tables...';

        SET @start_time = SYSDATETIME();

        TRUNCATE TABLE bronze.crm_cust_info;
        TRUNCATE TABLE bronze.crm_prd_info;
        TRUNCATE TABLE bronze.crm_sales_details;

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        -- Truncate ERP tables
        PRINT 'Truncating ERP tables...';

        SET @start_time = SYSDATETIME();

        TRUNCATE TABLE bronze.erp_cust_az12;
        TRUNCATE TABLE bronze.erp_loc_a101;
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        PRINT '=======================';
        PRINT 'Loading CRM Tables';
        PRINT '=======================';

        SET @crm_start_time = SYSDATETIME();

        -- Load CRM customer data
        PRINT 'Loading crm_cust_info...';

        SET @start_time = SYSDATETIME();

        BULK INSERT bronze.crm_cust_info
        FROM 'D:\Dhwanit\DE\SQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        -- Load CRM product data
        PRINT 'Loading crm_prd_info...';

        SET @start_time = SYSDATETIME();

        BULK INSERT bronze.crm_prd_info
        FROM 'D:\Dhwanit\DE\SQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        -- Load CRM sales data
        PRINT 'Loading crm_sales_details...';

        SET @start_time = SYSDATETIME();

        BULK INSERT bronze.crm_sales_details
        FROM 'D:\Dhwanit\DE\SQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        SET @crm_end_time = SYSDATETIME();

        PRINT 'CRM Load Complete';
        PRINT '~ Total CRM Duration: '
            + CAST(DATEDIFF(MILLISECOND, @crm_start_time, @crm_end_time) AS NVARCHAR)
            + ' ms';

        PRINT '=======================';
        PRINT 'Loading ERP Tables';
        PRINT '=======================';

        SET @erp_start_time = SYSDATETIME();

        -- Load ERP customer data
        PRINT 'Loading erp_cust_az12...';

        SET @start_time = SYSDATETIME();

        BULK INSERT bronze.erp_cust_az12
        FROM 'D:\Dhwanit\DE\SQL\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        -- Load ERP location data
        PRINT 'Loading erp_loc_a101...';

        SET @start_time = SYSDATETIME();

        BULK INSERT bronze.erp_loc_a101
        FROM 'D:\Dhwanit\DE\SQL\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        -- Load ERP product category data
        PRINT 'Loading erp_px_cat_g1v2...';

        SET @start_time = SYSDATETIME();

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'D:\Dhwanit\DE\SQL\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        SET @erp_end_time = SYSDATETIME();

        PRINT 'ERP Load Complete';
        PRINT '~ Total ERP Duration: '
            + CAST(DATEDIFF(MILLISECOND, @erp_start_time, @erp_end_time) AS NVARCHAR)
            + ' ms';

        SET @proc_end_time = SYSDATETIME();

        PRINT '==================================';
        PRINT 'Bronze Layer Loading Successful';
        PRINT '==================================';

        PRINT 'Total Bronze Load Duration: '
            + CAST(DATEDIFF(MILLISECOND, @proc_start_time, @proc_end_time) AS NVARCHAR)
            + ' ms';

    END TRY

    BEGIN CATCH

        PRINT '==================================';
        PRINT 'Error occurred during loading Bronze Layer';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT '==================================';

    END CATCH

END;
GO

--EXEC bronze.load_bronze;
--GO
