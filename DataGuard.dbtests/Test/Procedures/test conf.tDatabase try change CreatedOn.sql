CREATE PROCEDURE [test].[test conf.tDatabase try change CreatedOn]
AS
BEGIN

    DECLARE  @DatabaseName          SYSNAME =  'TestDB'

            ,@DatabaseId            INT
            ,@IsPermissionActive    BIT
            ,@CreatedOn        DATETIME2(3)
            ,@NewLastModifiedOn     DATETIME2(3)


    SELECT TOP (1)
             @DatabaseId = [DatabaseId]    
            ,@IsPermissionActive = [IsPermissionActive]
        --  ,[LastModifiedBy]
            ,@CreatedOn = [LastModifiedOn]
    FROM [conf].[tDatabase]
    WHERE [DatabaseName] = @DatabaseName


    IF @DatabaseId IS NOT NULL
    BEGIN 


    	EXEC tSQLt.ExpectException @ExpectedMessagePattern = 'Updating columns CreatedBy, CreatedOn is not allowed!', @ExpectedSeverity = NULL, @ExpectedState = NULL;
  
        UPDATE [DataGuard].[conf].[tDatabase]
            SET [CreatedOn] = '2000-01-01 00:00:00'
        WHERE DatabaseId = @DatabaseId


    --    SELECT TOP 1 @NewLastModifiedOn = [LastModifiedOn] FROM [conf].[tDatabase] WHERE [DatabaseId] = @DatabaseId

    --    PRINT CONCAT('@LastModifiedOn=<',@LastModifiedOn,'>, @NewLastModifiedOn=<', @NewLastModifiedOn,'>') 
    --     EXEC tSQLt.AssertNotEquals @LastModifiedOn, @NewLastModifiedOn;

    END 
    ELSE 
          DECLARE @ErrorMessage nvarchar(200) = CONCAT('The database record ', @DatabaseName, ' does not Exists in conf.tDatabase table')
          EXEC tSQLt.Fail @ErrorMessage 
  
END;
GO