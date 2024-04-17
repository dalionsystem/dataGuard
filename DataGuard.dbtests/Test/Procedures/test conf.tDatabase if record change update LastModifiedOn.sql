CREATE PROCEDURE [test].[test conf.tDatabase if record change update LastModifiedOn]
AS
BEGIN

    DECLARE  @DatabaseName          SYSNAME =  'TestDB'

            ,@DatabaseId            INT
            ,@IsPermissionActive    BIT
            ,@LastModifiedOn        DATETIME2(3)
            ,@NewLastModifiedOn     DATETIME2(3)


    SELECT TOP (1)
             @DatabaseId = [DatabaseId]    
            ,@IsPermissionActive = [IsPermissionActive]
        --  ,[LastModifiedBy]
            ,@LastModifiedOn = [LastModifiedOn]
    FROM [conf].[tDatabase]
    WHERE [DatabaseName] = @DatabaseName


    IF @DatabaseId IS NOT NULL
    BEGIN 

        UPDATE [DataGuard].[conf].[tDatabase]
            SET [IsPermissionActive] = ~[IsPermissionActive]
        WHERE DatabaseId = @DatabaseId


        SELECT TOP 1 @NewLastModifiedOn = [LastModifiedOn] FROM [conf].[tDatabase] WHERE [DatabaseId] = @DatabaseId

        PRINT CONCAT('@LastModifiedOn=<',@LastModifiedOn,'>, @NewLastModifiedOn=<', @NewLastModifiedOn,'>') 
         EXEC tSQLt.AssertNotEquals @LastModifiedOn, @NewLastModifiedOn;

    END 
    ELSE 
          DECLARE @ErrorMessage nvarchar(200) = CONCAT('The database record ', @DatabaseName, ' does not Exists in conf.tDatabase table')
          EXEC tSQLt.Fail @ErrorMessage 
  
END;
GO