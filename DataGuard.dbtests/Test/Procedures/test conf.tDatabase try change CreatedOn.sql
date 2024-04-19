CREATE PROCEDURE [test].[test conf.tDatabase try change CreatedOn]
AS
BEGIN

    DECLARE  @DatabaseName          SYSNAME =  'TestDB'

            ,@DatabaseId            INT
            ,@CreatedOn             DATETIME2(3)


    SELECT TOP (1)
             @DatabaseId = [DatabaseId]    
            ,@CreatedOn = [CreatedOn]
    FROM [conf].[tDatabase]
    WHERE [DatabaseName] = @DatabaseName


    IF @DatabaseId IS NOT NULL
    BEGIN 


    	EXEC tSQLt.ExpectException @ExpectedMessagePattern = 'Updating columns CreatedBy, CreatedOn is not allowed!', @ExpectedSeverity = NULL, @ExpectedState = NULL;
  
        UPDATE [DataGuard].[conf].[tDatabase]
            SET [CreatedOn] = '2000-01-01 00:00:00'
        WHERE DatabaseId = @DatabaseId

    END 
    ELSE 
    BEGIN
          DECLARE @ErrorMessage nvarchar(200) = CONCAT('The database record ', @DatabaseName, ' does not Exists in conf.tDatabase table')
          EXEC tSQLt.Fail @ErrorMessage 
    END
END;
GO