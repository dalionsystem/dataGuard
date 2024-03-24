CREATE PROCEDURE [dbo].[pPermissionInSystem]
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
								@Tab, '@DatabaseName = ', @DatabaseName,	@CRLF,
								@Tab, '@IsDebug = ', @IsDebug )

		PRINT @ExecQuery
		 
	END


	IF OBJECT_ID('tempdb..#PermissionInSystem') IS NOT NULL  DROP TABLE #PermissionInSystem


	CREATE TABLE #PermissionInSystem
	(
	   [DatabaseName]	 sysname 
	  ,[Type]			 varchar(100)
	  ,[UserName]		 sysname
	  ,[ClassDesc]		 varchar(100)
	  ,[PermmisionType]	 varchar(100)
	  ,[PermmisionState] varchar(100)
	  ,[SchemaName]		 sysname
	  ,[ObjectType]		 varchar(100)
	  ,[PermmisionState] varchar(100)
	  ,[ObjectName]		 varchar(100)
	)

	--TODO

	SELECT 
		[DatabaseName]
		,[Type]
		,[UserName]
		,[Role]
		,[ClassDesc]
		,[PermissionType]
		,[PermissionState]
		,[SchemaName]
		,[ObjectType]									AS [SqlObjectType]
		,IIF([Role] IS NOT NULL, [Role], [ObjectName])	AS [ObjectName]
		,CASE 
			WHEN [Role] IS NOT NULL THEN 'Role'
			WHEN [ClassDesc] = 'SERVER' THEN 'Instance'
			WHEN [ClassDesc] = 'DATABASE_PRINCIPAL' THEN 'Database'
			WHEN [ClassDesc] = 'OBJECT_OR_COLUMN' AND [ObjectType] = 'USER_TABLE'						THEN 'Table'
			WHEN [ClassDesc] = 'OBJECT_OR_COLUMN' AND [ObjectType] = 'VIEW'								THEN 'View'
			WHEN [ClassDesc] = 'OBJECT_OR_COLUMN' AND [ObjectType] = 'SQL_STORED_PROCEDURE'				THEN 'SqlProcedure'
			WHEN [ClassDesc] = 'OBJECT_OR_COLUMN' AND [ObjectType] = 'EXTENDED_STORED_PROCEDURE'		THEN 'ExtendedProcedure'
			WHEN [ClassDesc] = 'OBJECT_OR_COLUMN' AND [ObjectType] = 'CLR_STORED_PROCEDURE'				THEN 'ClrProcedure'
			WHEN [ClassDesc] = 'OBJECT_OR_COLUMN' AND [ObjectType] = 'SQL_SCALAR_FUNCTION'				THEN 'ScalarFunction'
			WHEN [ClassDesc] = 'OBJECT_OR_COLUMN' AND [ObjectType] = 'SQL_INLINE_TABLE_VALUED_FUNCTION'	THEN 'InlineFunction'
			WHEN [ClassDesc] = 'OBJECT_OR_COLUMN' AND [ObjectType] = 'SQL_TABLE_VALUED_FUNCTION'		THEN 'InlineFunction'
			WHEN [ClassDesc] = 'OBJECT_OR_COLUMN' THEN [ClassDesc]
		END AS [ObjectType]
	FROM #PermissionInSystem
