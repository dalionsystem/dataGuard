CREATE PROCEDURE [test].[test conf.tDatabase if record change update LastModifiedOn]
AS
BEGIN

    DECLARE  @DatabaseName          SYSNAME =  'TestDB'

            ,@DatabaseId            INT
            ,@LastModifiedOn        varchar(30) --DATETIME2(3)
            ,@NewLastModifiedOn     varchar(30) --DATETIME2(3)


    SELECT TOP (1)
             @DatabaseId = [DatabaseId]    
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
        EXEC tSQLt.AssertNotEquals  @NewLastModifiedOn, @LastModifiedOn;


    END 
    ELSE 
    BEGIN
          DECLARE @ErrorMessage nvarchar(200) = CONCAT('The database record ', @DatabaseName, ' does not Exists in conf.tDatabase table')
          EXEC tSQLt.Fail @ErrorMessage 
    END
END;
GO  