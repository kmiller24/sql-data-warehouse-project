/*
==========================================
CREATE DATABASE AND SCHEMAS
==========================================
Script Purpose:
	This script creats a new database name 'DataWarehouse' after checking if it already exists.
	If the database exists, it is dropped recreated. Additionally, the script sets up three schemas within the databaseL 'bronze', 'silver', and 'gold'.

WARNING:
	Running this script will drop the entire 'DataWarehouse' database if it exists.
	All data in the database will be permanently deleted. 
	Proced with caustion and ensure you have proper backups before running this script.
*/

-- Create Database 'DataWarehouse'

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse
END;
GO

CREATE DATABASE DataWarehouse;

USE DataWarehouse;

CREATE SCHEMA bronze;
GO 
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
