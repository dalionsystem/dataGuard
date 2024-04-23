CREATE PROCEDURE [dbo].[pPermissionInSystemAsXml]
	@DatabaseName	sysname,
	@UserName		sysname,
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
								@Tab, ' @DatabaseName = ', IIF(@DatabaseName LIKE '%', QUOTENAME(@DatabaseName,''''), @DatabaseName ) ,	@CRLF,
								@Tab, ' @UserName = ', IIF(@UserName LIKE '%', QUOTENAME(@UserName,''''), @UserName ) ,	@CRLF,
								@Tab, ',@IsDebug = ', @IsDebug )

		PRINT @ExecQuery
		 
	END


	IF OBJECT_ID('tempdb..#PermissionInSystem') IS NOT NULL  DROP TABLE #PermissionInSystem


	CREATE TABLE #PermissionInSystem
	--DECLARE @PermissionInSystemXml TABLE 
	(
	   [DatabaseName]	 sysname 		NULL
	  ,[Type]			 varchar(100)
	  ,[UserName]		 sysname		NULL
	  ,[RoleName]	     sysname		NULL
	  ,[ClassDesc]		 varchar(100)
	  ,[PermissionType]	 varchar(100)
	  ,[PermissionState] varchar(100)
	  ,[SchemaName]		 sysname		NULL
	  ,[SqlObjectType]	 varchar(100)
	  ,[ObjectName]		 varchar(100)
	  ,[ObjectType]		 varchar(100)

	 
	)


	--	INSERT INTO @PermissionInSystemXml ([DatabaseName], [Type], [UserName], [RoleName], [ClassDesc], [PermissionType], [PermissionState], [SchemaName], [SqlObjectType], [ObjectName], [ObjectType])
		EXEC [dbo].[pPermissionInSystem] @DatabaseName=@DatabaseName, @IsDebug= @IsDebug

		SELECT * FROM #PermissionInSystem