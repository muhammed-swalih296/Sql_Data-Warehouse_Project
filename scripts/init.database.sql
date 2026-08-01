/*
================================================

CREATE DATABASE AND SCHEMAS

================================================

Script purpose :
	This script creates a new database named 'DataWarehouse' after checking if it already exists.
	If the database exists it is dropped and recreated. Additionally the script set up three schemas 
	within the database : 'bronze', 'silver' and 'gold'.

Warning :
	Running this script will drop the entire 'DataWarehouse' database if it exists. All the data in this 
	database will be permanently deleted. Proceed with caution and ensure that you have proper backups 
	before running this script.

*/

USE master;
GO

-- Drop and recreate 'DataWarehouse' databse

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse
END;

GO

-- Create databse 'DataWarehouse'

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas


CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
