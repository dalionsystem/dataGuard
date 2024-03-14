CREATE PROCEDURE [dbo].[pIsSchemaExists]
	@SchemaName		sysname,
	@DatabaseName	sysname 
AS
	DECLARE @Sql nvarchar(3000)
			,@ErrorMesssage nvarchar(2000) 
			,@Result BIT = 0

	IF DB_ID(@DatabaseName) IS NULL OR HAS_DBACCESS(@DatabaseName) = 0
	BEGIN
		SET @ErrorMesssage = CONCAT('The database ',@DatabaseName,' not exists!')
		;THROW 50001, @ErrorMesssage ,1;
	END


	--TODO
	SET @sql = CONCAT('SELECT @Result = 1 FROM ',QUOTENAME(@DatabaseName),'.[sys].[schemas] where [name] = @SchemaName')
	PRINT @sql

--

RETURN @Result
