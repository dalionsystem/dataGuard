CREATE PROCEDURE [dbo].[pGetListOfDatabaseUsers]
	@DatabaseName	sysname,
	@IsDebug		BIT		= 0
AS
	DECLARE @Sql nvarchar(3000)
			,@ErrorMessage nvarchar(2000) 
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

	EXEC [dbo].[pThrowErrorIfDatabaseNotExists] @DatabaseName = @DatabaseName, @IsDebug = @IsDebug


	SET @sql = CONCAT('
		SELECT ',QUOTENAME(@DatabaseName,''''),'									AS DatabaseName 
				,c.[name]															AS [UserName]
				,c.[type]															AS [Type]
				,c.[authentication_type]											AS [AuthenticationType]
				,CASE WHEN m.[permission_name] = N''CONNECT'' THEN 1  ELSE 0 END 	AS [IsEnable]
		
		FROM		', QUOTENAME(@DatabaseName),'.sys.database_principals (nolock) c
		LEFT JOIN	', QUOTENAME(@DatabaseName),'.sys.database_permissions (nolock) m ON m.[grantee_principal_id] = c.[principal_id] AND m.[permission_name] = N''CONNECT''
		WHERE c.type IN (''S'',''G'',''U'')
			AND c.sid IS NOT NULL
		    AND c.name <> N''guest''
		'
	)
	PRINT @sql


	EXEC SP_executesql @sql
