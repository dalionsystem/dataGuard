﻿CREATE PROCEDURE [dbo].[pIsDatabaseExists]
	@DatabaseName	sysname,
	@IsDebug		BIT		= 0
AS
	DECLARE @Sql nvarchar(3000)
			,@ErrorMessage nvarchar(2000) 
			,@Result BIT = 0
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
		SET @ErrorMessage = CONCAT('The database ',@DatabaseName,' not exists!')
		;THROW 50001, @ErrorMessage ,1;
	END

	SET @sql = 'SELECT @Result = 1 FROM [sys].[databases] (nolock) where [name] = @DatabaseName'
	IF @IsDebug = 1 PRINT @sql

	EXEC sp_executesql @sql, N'@Result bit OUTPUT, @DatabaseName sysname', @Result=@Result OUTPUT, @DatabaseName =@DatabaseName

	IF @IsDebug = 1 PRINT @Result



RETURN @Result
