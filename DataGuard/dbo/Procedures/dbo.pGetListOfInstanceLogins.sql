CREATE PROCEDURE [dbo].[pGetListOfInstanceLogin]
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
								@Tab, ',@IsDebug = ', @IsDebug )
		PRINT @ExecQuery		 
	END



		SELECT  'SERVER'		 AS [ClassDesc]
				,s.[type]		 AS [Type]
				,s.[name]		 AS [LoginName]	
		FROM		sys.server_principals (nolock) s



	EXEC SP_executesql @sql