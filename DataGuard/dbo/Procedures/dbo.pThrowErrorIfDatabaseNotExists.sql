CREATE PROCEDURE [dbo].[pThrowErrorIfDatabaseNotExists]
	@DatabaseName	sysname,
	@IsDebug		BIT		= 0
AS
	DECLARE @Sql nvarchar(3000)
			,@ErrorMesssage nvarchar(2000) 
			,@ExecQuery nvarchar(4000)
			,@CRLF CHAR(2) = CHAR(13)+CHAR(10)
			,@Tab nvarchar(10) = CHAR(9)

	IF @IsDebug = 1 
	BEGIN
		SET @ExecQuery = CONCAT( 'EXEC ', QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)), '.', QUOTENAME(OBJECT_NAME(@@PROCID)), @CRLF,
								@Tab, ' @DatabaseName = ', @DatabaseName,	@CRLF,
								@Tab, ',@IsDebug = ', @IsDebug )

		PRINT @ExecQuery
		 
	END


	IF DB_ID(@DatabaseName) IS NULL OR HAS_DBACCESS(@DatabaseName) = 0
	BEGIN
		SET @ErrorMesssage = CONCAT('The database ',@DatabaseName,' not exists!')
		;THROW 50001, @ErrorMesssage ,1;
	END

