CREATE PROCEDURE [test].[test database TestDataTest not existing]
AS
BEGIN

--EXEC tSQLt.ExpectException @ExpectedMessagePattern = '%Part of Expected Message%', @ExpectedSeverity = NULL, @ExpectedState = NULL;
  EXEC tSQLt.ExpectException @Message = 'The database TestDataTest23 not exists!', @ExpectedSeverity = 16, @ExpectedState = 1;
  EXEC [dbo].[pThrowErrorIfDatabaseNotExists] @DatabaseName = [TestDataTest], @IsDebug =1 
  
END;
GO