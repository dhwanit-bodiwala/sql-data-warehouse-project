/*
==================================================================
Create DataWarehouse Database and Schemas
==================================================================

Script Purpose:
    Creates the DataWarehouse database and the foundational
    schemas used in the Medallion Architecture:

    - bronze : Raw source data
    - silver : Cleansed and transformed data
    - gold   : Business-ready data for reporting and analytics

WARNING:
    This script drops and recreates the entire DataWarehouse
    database if it already exists.

    All existing data will be permanently deleted.
==================================================================
*/

-- Switch to master database
USE master;
GO

-- Drop database if it already exists
IF EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = N'DataWarehouse'
)
BEGIN
    DROP DATABASE DataWarehouse;
END
GO

-- Create database
CREATE DATABASE DataWarehouse;
GO

-- Switch to DataWarehouse database
USE DataWarehouse;
GO

-- Create schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
