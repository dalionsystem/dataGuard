CREATE PROCEDURE [test].[test database DataGuard existing]
AS
BEGIN

  EXEC [dbo].[pThrowErrorIfDatabaseNotExists] @DatabaseName = [DataGuard], @IsDebug =1 
  
END;
GO