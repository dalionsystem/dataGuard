﻿CREATE PROCEDURE [dbo].[pGetListOfDatabasePermissions]
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
		SELECT DISTINCT
				',QUOTENAME(@DatabaseName,''''),' AS [DatabaseName] 
				,c.[type]						 AS [Type]
				,c.[name]						 AS [UserName]
				,m.[class_desc]					 AS [ClassDesc]
				,m.[permission_name]			 AS [PermisssionType]
				,m.[state_desc]					 AS [PermisssionState]
				,COALESCE(sm.[name], so.[name])	 AS [SchemaName]
				,o.[type_desc]					 AS [ObjectType]
				,o.[name]						 AS [ObjectName]
		FROM		', QUOTENAME(@DatabaseName),'.sys.database_principals (nolock) c
		LEFT JOIN	', QUOTENAME(@DatabaseName),'.sys.database_permissions (nolock) m ON m.[grantee_principal_id] = c.[principal_id]
		LEFT JOIN 	', QUOTENAME(@DatabaseName),'.sys.all_objects (nolock) o ON m.[major_id] = o.[object_id]
		LEFT JOIN 	', QUOTENAME(@DatabaseName),'.sys.schemas (nolock) so  ON o.[schema_id] = so.[schema_id]
		LEFT JOIN 	', QUOTENAME(@DatabaseName),'.sys.schemas (nolock) sm  ON m.[major_id] = sm.[schema_id]
		WHERE c.[Type] IN (''U'',''G'')'
	)
	PRINT @sql


	EXEC sp_executesql @sql





