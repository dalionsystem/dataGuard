﻿CREATE PROCEDURE [dbo].[pGetListOfDatabaseObject]
	
	@DatabaseName	sysname,
	@Type			varchar(30) ='%',
	@Schema			sysname = '%',
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
								@Tab, '@DatabaseName = ', @DatabaseName,	@CRLF,
								@Tab, '@Type = ', @Type,	@CRLF,
								@Tab, '@Schema = ', @Schema,	@CRLF,
								@Tab, '@IsDebug = ', @IsDebug )

		PRINT @ExecQuery
		 
	END


	IF DB_ID(@DatabaseName) IS NULL OR HAS_DBACCESS(@DatabaseName) = 0
	BEGIN
		SET @ErrorMesssage = CONCAT('The database ',@DatabaseName,' not exists!')
		;THROW 50001, @ErrorMesssage ,1;
	END


	DECLARE @ObjectTable TABLE 
	(
	--	 [DatabaseName] sysname
		 [Type]			varchar(20)
		,[Schema]		sysname
		,[ObjectName]	sysname
	)



	IF @Type = 'Table' OR @Type = '%'
	BEGIN
		INSERT INTO @ObjectTable([Type],[Schema],[ObjectName])
		SELECT 'Table' AS [Type]
			  ,[Table_SCHEMA] AS [Schema]

		FROM [DataGuard].[INFORMATION_SCHEMA].[TABLES]
		WHERE [TABLE_TYPE] = 'BASE TABLE'
			AND ([TABLE_SCHEMA] = @Schema OR @Schema = '%') 
 
	END


	--TODO

	/*
	SET @sql = CONCAT('
		SELECT ',QUOTENAME(@DatabaseName,''''),' AS DatabaseName 
				,c.[type]						AS [Type]
				,c.[name]						AS [UserName]
				,m.[class_desc]					AS [ClassDesc]
				,m.[permission_name]			AS [PermmisionType]
				,m.[state_desc]					AS [PermmisionState]
				,COALESCE(sm.[name], so.[name])	AS [SchemaName]
				,o.[type_desc]					AS [ObjectType]
				,m.[state_desc]					AS [PermmisionState]
				,o.[name]						AS [ObjectName]
		FROM		', QUOTENAME(@DatabaseName),'.sys.database_principals (nolock) c
		LEFT JOIN	', QUOTENAME(@DatabaseName),'.sys.database_permissions (nolock) m ON m.[grantee_principal_id] = c.[principal_id]
		LEFT JOIN 	', QUOTENAME(@DatabaseName),'.sys.all_objects (nolock) o ON m.[major_id] = o.[object_id]
		LEFT JOIN 	', QUOTENAME(@DatabaseName),'.sys.schemas (nolock) so  ON o.[schema_id] = so.[schema_id]
		LEFT JOIN 	', QUOTENAME(@DatabaseName),'.sys.schemas (nolock) sm  ON m.[major_id] = sm.[schema_id]'
	)
	*/
	PRINT @sql


	EXEC SP_executesql @sql
