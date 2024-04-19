CREATE PROCEDURE [test].[test conf.tDatabase try change CreatedBy]
AS
BEGIN

    DECLARE  @DatabaseName          SYSNAME =  'TestDB'

            ,@DatabaseId            INT
            ,@CreatedBy             NVARCHAR(128)


    SELECT TOP (1)
             @DatabaseId = [DatabaseId]    
            ,@CreatedBy = [CreatedBy]
    FROM [conf].[tDatabase]
    WHERE [DatabaseName] = @DatabaseName


    IF @DatabaseId IS NOT NULL
    BEGIN 


    	EXEC tSQLt.ExpectException @ExpectedMessagePattern = 'Updating columns CreatedBy, CreatedOn is not allowed!', @ExpectedSeverity = NULL, @ExpectedState = NULL;
  
        UPDATE [DataGuard].[conf].[tDatabase]
            SET [CreatedBy] = 'WrongTestUser-ManualChenged'
        WHERE DatabaseId = @DatabaseId

    END 
    ELSE 
          DECLARE @ErrorMessage nvarchar(200) = CONCAT('The database record ', @DatabaseName, ' does not Exists in conf.tDatabase table')
          EXEC tSQLt.Fail @ErrorMessage 
  
END;
GO