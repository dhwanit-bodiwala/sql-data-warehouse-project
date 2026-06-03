/*
==================================================================
Load Data into Silver Layer
==================================================================

Script Purpose:
    Loads cleansed and transformed CRM and ERP data
    from the bronze layer into the silver layer.

    Data quality rules, standardization, validation,
    and transformation rules are applied before loading.

WARNING:
    Existing data in silver tables will be removed
    before loading.
==================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @proc_start_time DATETIME2,
                @proc_end_time DATETIME2,
                @crm_start_time DATETIME2,
                @crm_end_time DATETIME2,
                @erp_start_time DATETIME2,
                @erp_end_time DATETIME2,
                @start_time DATETIME2,
                @end_time DATETIME2;

        SET @proc_start_time = SYSDATETIME();

        PRINT '=======================';
        PRINT 'Loading Silver Layer';
        PRINT '=======================';

        PRINT 'Loading CRM Tables...';

        SET @crm_start_time = SYSDATETIME();

        ----------------------------------------------------------------
        -- crm_cust_info
        ----------------------------------------------------------------

        PRINT 'Loading crm_cust_info...';

        SET @start_time = SYSDATETIME();

         -- Load customer information
        IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
            TRUNCATE TABLE silver.crm_cust_info;

        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            TRIM(cst_key) AS cst_key,
            ISNULL(NULLIF(TRIM(cst_firstname), ''), 'N/A') AS cst_firstname,
            ISNULL(NULLIF(TRIM(cst_lastname), ''), 'N/A') AS cst_lastname,
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'N/A'
            END AS cst_marital_status,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'N/A'
            END AS cst_gndr,
            cst_create_date
        FROM (
            SELECT
                cst_id,
                cst_key,
                cst_firstname,
                cst_lastname,
                cst_marital_status,
                cst_gndr,
                cst_create_date,
                ROW_NUMBER() OVER (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS rn
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE rn = 1;

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        ----------------------------------------------------------------
        -- crm_prd_info
        ----------------------------------------------------------------

        PRINT 'Loading crm_prd_info...';

        SET @start_time = SYSDATETIME();

                -- Load product information
        IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
            TRUNCATE TABLE silver.crm_prd_info;

        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            TRIM(prd_nm) AS prd_nm,
            COALESCE(prd_cost, 0) AS prd_cost,
            CASE
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'N/A'
            END AS prd_line,
            prd_start_dt,
            DATEADD(
                DAY,
                -1,
                LEAD(prd_start_dt, 1) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                )
            ) AS prd_end_dt
        FROM bronze.crm_prd_info;

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        ----------------------------------------------------------------
        -- crm_sales_details
        ----------------------------------------------------------------

        PRINT 'Loading crm_sales_details...';

        SET @start_time = SYSDATETIME();

                -- Load sales information
        IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
            TRUNCATE TABLE silver.crm_sales_details;

        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE
                WHEN sls_order_dt = 0 OR LEN(CAST(sls_order_dt AS VARCHAR)) <> 8
                    THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR(8)) AS DATE)
            END AS sls_order_dt,
            CASE
                WHEN sls_ship_dt = 0 OR LEN(CAST(sls_ship_dt AS VARCHAR)) <> 8
                    THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR(8)) AS DATE)
            END AS sls_ship_dt,
            CASE
                WHEN sls_due_dt = 0 OR LEN(CAST(sls_due_dt AS VARCHAR)) <> 8
                    THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR(8)) AS DATE)
            END AS sls_due_dt,
            CASE
                WHEN sls_sales IS NULL
                     OR sls_sales <= 0
                     OR sls_sales <> sls_quantity * ABS(sls_price)
                    THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,
            sls_quantity,
            CASE
                WHEN sls_price IS NULL
                     OR sls_price <= 0
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price
        FROM bronze.crm_sales_details;

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        SET @crm_end_time = SYSDATETIME();

        PRINT 'CRM Load Complete';

        PRINT '~ Total CRM Duration: '
            + CAST(
                DATEDIFF(
                    MILLISECOND,
                    @crm_start_time,
                    @crm_end_time
                ) AS NVARCHAR
              )
            + ' ms';

        PRINT '=======================';
        PRINT 'Loading ERP Tables';
        PRINT '=======================';

        SET @erp_start_time = SYSDATETIME();

        ----------------------------------------------------------------
        -- erp_cust_az12
        ----------------------------------------------------------------

        PRINT 'Loading erp_cust_az12...';

        SET @start_time = SYSDATETIME();

        IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
            truncate table silver.erp_cust_az12;

        insert into silver.erp_cust_az12 (
        cid,
        bdate,
        gen
        )
        SELECT
               (case
                    when cid like 'NAS%' then SUBSTRING(cid,4,len(cid))
                    else cid
                end) as [cid]
              ,CASE
                    WHEN bdate > CAST(SYSDATETIME() AS DATE) THEN NULL
                    ELSE bdate
                END as [bdate]
              ,(case
                    WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
                    WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
                    when trim(gen) is null then 'N/A'
                    when trim(gen) = '' then 'N/A'
                    else trim(gen)
                end) as [gen]
        FROM bronze.erp_cust_az12

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        ----------------------------------------------------------------
        -- erp_loc_a101
        ----------------------------------------------------------------

        PRINT 'Loading erp_loc_a101...';

        SET @start_time = SYSDATETIME();

            IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
            truncate table silver.erp_loc_a101;

        insert into silver.erp_loc_a101 (
        cid,
        cntry
        )
        SELECT replace(cid,'-','') as [cid]
              ,(case when trim(cntry) = '' or trim(cntry) is null then 'N/A'
                     when upper(trim(cntry)) = 'DE' then 'Germany'
                     when upper(trim(cntry)) in ('USA','US') then 'United States'
                     else trim(cntry)
                end) as [cntry]
          FROM bronze.erp_loc_a101

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        ----------------------------------------------------------------
        -- erp_px_cat_g1v2
        ----------------------------------------------------------------

        PRINT 'Loading erp_px_cat_g1v2...';

        SET @start_time = SYSDATETIME();

            IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
            TRUNCATE TABLE silver.erp_px_cat_g1v2;

        insert into silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintainence
        )
        SELECT [id]
              ,[cat]
              ,[subcat]
              ,[maintainence]
          FROM bronze.erp_px_cat_g1v2

        SET @end_time = SYSDATETIME();

        PRINT '~ Duration: '
            + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS NVARCHAR)
            + ' ms';

        SET @erp_end_time = SYSDATETIME();

        PRINT 'ERP Load Complete';

        PRINT '~ Total ERP Duration: '
            + CAST(
                DATEDIFF(
                    MILLISECOND,
                    @erp_start_time,
                    @erp_end_time
                ) AS NVARCHAR
              )
            + ' ms';

        SET @proc_end_time = SYSDATETIME();

        PRINT '==================================';
        PRINT 'Silver Layer Loading Successful';
        PRINT '==================================';

        PRINT 'Total Silver Load Duration: '
            + CAST(
                DATEDIFF(
                    MILLISECOND,
                    @proc_start_time,
                    @proc_end_time
                ) AS NVARCHAR
              )
            + ' ms';

    END TRY

    BEGIN CATCH

        PRINT '==================================';
        PRINT 'Error occurred during loading Silver Layer';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Line   : ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '==================================';

    END CATCH

END;
GO

 EXEC silver.load_silver;
 GO
