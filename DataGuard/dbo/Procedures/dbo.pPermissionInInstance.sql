﻿CREATE PROCEDURE [dbo].[pPermissionInInstance]
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
								@Tab, ' @DatabaseName = ', IIF(@DatabaseName LIKE '%', QUOTENAME(@DatabaseName,''''), @DatabaseName ) ,	@CRLF,							
								@Tab, ',@IsDebug = ', @IsDebug )

		PRINT @ExecQuery
		 
	END


	IF OBJECT_ID('tempdb..#PermissionInSystemInternal') IS NOT NULL  DROP TABLE #PermissionInSystemInternal


	CREATE TABLE #PermissionInSystemInternal
	(
	   [DatabaseName]	 sysname 		NULL
	  ,[Type]			 varchar(100)
	  ,[UserName]		 sysname		NULL
	  ,[RoleName]	     sysname		NULL
	  ,[ClassDesc]		 varchar(100)
	  ,[PermissionType]	 varchar(100)
	  ,[PermissionState] varchar(100)
	  ,[SchemaName]		 sysname		NULL
	  ,[ObjectType]		 varchar(100)
	  ,[ObjectName]		 varchar(100)
	)



	IF @DatabaseName <> '%'
	BEGIN
		INSERT INTO #PermissionInSystemInternal ([DatabaseName], [Type], [UserName], [ClassDesc], [PermissionType], [PermissionState], [SchemaName], [ObjectType], [ObjectName])
		EXEC [dbo].[pGetListOfDatabasePermissions] @DatabaseName=@DatabaseName, @IsDebug= @IsDebug

		INSERT INTO #PermissionInSystemInternal ([DatabaseName], [Type], [UserName], [RoleName])
		EXEC [dbo].[pGetListOfDatabaseRoles] @DatabaseName=@DatabaseName, @IsDebug= @IsDebug
	END


	IF @DatabaseName IS NULL
	BEGIN
		INSERT INTO #PermissionInSystemInternal ([Type], [UserName], [ClassDesc], [PermissionType], [PermissionState])
		EXEC [dbo].[pGetListOfInstancePermissions] @IsDebug= @IsDebug

		INSERT INTO #PermissionInSystemInternal ( [ClassDesc], [Type], [UserName], [RoleName])
		EXEC [dbo].[pGetListOfInstanceRoles] @IsDebug= @IsDebug
	END

	IF @DatabaseName = '%'
	BEGIN
		
		DECLARE @DatabaseNameLoop sysname

		DECLARE databaseNameCursor CURSOR READ_ONLY FOR
			SELECT DatabaseName 
			FROM [conf].[tDatabase] (nolock) 
			WHERE IsPermissionActive = 1 
				AND DatabaseName IS NOT NULL
		
		OPEN databaseNameCursor
		FETCH NEXT FROM  databaseNameCursor INTO @DatabaseNameLoop

		WHILE @@FETCH_STATUS =0 
		BEGIN

			BEGIN TRY
				INSERT INTO #PermissionInSystemInternal ([DatabaseName], [Type], [UserName], [ClassDesc], [PermissionType], [PermissionState], [SchemaName], [ObjectType], [ObjectName])
				EXEC [dbo].[pGetListOfDatabasePermissions] @DatabaseName=@DatabaseNameLoop, @IsDebug= @IsDebug
			END TRY
			BEGIN CATCH	
				SET @ErrorMessage  = CONCAT('Error when get data from dbo.pGetListOfDatabasePermissions on DatabaseName ', @DatabaseNameLoop)
				PRINT @ErrorMessage 
			END CATCH


			BEGIN TRY
				INSERT INTO #PermissionInSystemInternal ([DatabaseName], [Type], [UserName], [RoleName])
				EXEC [dbo].[pGetListOfDatabaseRoles] @DatabaseName=@DatabaseNameLoop, @IsDebug= @IsDebug
			END TRY
			BEGIN CATCH	
				SET @ErrorMessage  = CONCAT('Error when get data from dbo.pGetListOfDatabaseRoles on DatabaseName ', @DatabaseNameLoop)
				PRINT @ErrorMessage 
			END CATCH



			FETCH NEXT FROM  databaseNameCursor INTO @DatabaseNameLoop
		END

		CLOSE databaseNameCursor 
		DEALLOCATE databaseNameCursor 



		INSERT INTO #PermissionInSystemInternal ([Type], [UserName], [ClassDesc], [PermissionType], [PermissionState])
		EXEC [dbo].[pGetListOfInstancePermissions] @IsDebug= @IsDebug

		INSERT INTO #PermissionInSystemInternal ( [ClassDesc], [Type], [UserName], [RoleName])
		EXEC [dbo].[pGetListOfInstanceRoles] @IsDebug= @IsDebug


	END 


	IF OBJECT_ID('tempdb..#PermissionInSystem') IS NOT NULL  
	BEGIN
		INSERT INTO #PermissionInSystem
		SELECT 
			[DatabaseName]
			,[Type]
			,[UserName]
			,[RoleName]
			,[ClassDesc]
			,[PermissionType]
			,[PermissionState]
			,[SchemaName]
			,[ObjectType]												AS [SqlObjectType]
			,IIF([RoleName] IS NOT NULL, [RoleName], [ObjectName])		AS [ObjectName]
			,CASE 
				WHEN [RoleName] IS NOT NULL THEN 'Role'
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
		FROM #PermissionInSystemInternal

	END
	ELSE 
	BEGIN
		SELECT 
			[DatabaseName]
			,[Type]
			,[UserName]
			,[RoleName]
			,[ClassDesc]
			,[PermissionType]
			,[PermissionState]
			,[SchemaName]
			,[ObjectType]												AS [SqlObjectType]
			,IIF([RoleName] IS NOT NULL, [RoleName], [ObjectName])		AS [ObjectName]
			,CASE 
				WHEN [RoleName] IS NOT NULL THEN 'Role'
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
		FROM #PermissionInSystemInternal
	END
