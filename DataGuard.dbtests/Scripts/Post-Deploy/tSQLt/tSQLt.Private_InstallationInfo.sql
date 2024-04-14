--Fix tSQLt version for SQL Server 2022
CREATE OR ALTER FUNCTION [tSQLt].[Private_InstallationInfo]() 
RETURNS TABLE 
AS 
RETURN SELECT CAST(16.00 AS NUMERIC(10,2)) AS SqlVersion;