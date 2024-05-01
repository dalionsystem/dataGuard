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

			,@XmlResult XML

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


	--	INSERT INTO @PermissionInSystem ([DatabaseName], [Type], [UserName], [RoleName], [ClassDesc], [PermissionType], [PermissionState], [SchemaName], [SqlObjectType], [ObjectName], [ObjectType])
		EXEC [dbo].[pPermissionInSystem] @DatabaseName=@DatabaseName, @IsDebug= @IsDebug

--		SELECT * FROM #PermissionInSystem

		
		SET @XmlResult = (
			SELECT un.[UserName] as [@UserName],
				   un.[LoginName] as [@LoginName],
				   un.[State] as [@State]
				,(	
					SELECT db.[DatabaseName] AS [Database/@Name],
						(	
							SELECT rn.[RoleName] as [Role]
							FROM (	SELECT DISTINCT r.[RoleName]
									FROM #PermissionInSystem r
									WHERE db.[UserName] = r.[UserName]
										AND (db.[DatabaseName] = r.[DatabaseName] OR (db.[DatabaseName] IS NULL AND r.[DatabaseName] IS NULL))
										AND r.RoleName IS NOT NULL								
								 ) rn
							FOR XML PATH(''), TYPE
						) AS [Database],
						(
							SELECT  ps.ObjectType AS [Object/@ObjectType],
									ps.SchemaName AS [Object/@SchemaName],
									ps.ObjectName AS [Object/@ObjectName],
									ps.PermissionType AS [Object/@PermissionType],
									ps.PermissionState AS [Object/@PermissionState]
							FROM (	SELECT DISTINCT p.[PermissionState], p.[ObjectType], p.[PermissionType], p.[SchemaName], p.[ObjectName]
									FROM #PermissionInSystem p
									WHERE p.PermissionState IS NULL
										AND db.[UserName] = p.[UserName]
										AND (db.[DatabaseName] = p.[DatabaseName] OR (db.[DatabaseName] IS NULL AND p.[DatabaseName] IS NULL)) 
										AND p.RoleName IS NOT NULL	
								) ps
							ORDER BY ps.ObjectType, ps.SchemaName, ps.ObjectName
							FOR XML PATH(''), TYPE
								
						) as [Database]
					FROM (	
							SELECT DISTINCT d.[DatabaseName], d.[UserName]
							FROM #PermissionInSystem d
							WHERE COALESCE(un.[UserName], un.[LoginName]) = d.[UserName]					
						) db
					FOR XML PATH(''), TYPE
				)
			FROM (
					SELECT u2.[UserName]
						  ,u2.[LoginName]
						  ,CASE 
							 WHEN su.[UserName] IS NOT NULL THEN 'Enabled'
							 WHEN sl.[UserName] IS NOT NULL THEN 'Enabled'
							 ELSE 'Disbled'
						  END AS [State]
					FROM (
						SELECT DISTINCT IIF(u.[DatabaseName] IS NOT NULL, u.[UserName], NULL) AS [UserName],
										IIF(u.[DatabaseName] IS NULL, u.[UserName], NULL) AS [LoginName]
						FROM #PermissionInSystem u
						WHERE u.[UserName] = @UserName OR @UserName = '%'
						) u2
					LEFT JOIN #PermissionInSystem su ON u2.[UserName] = su.[UserName]
														AND su.PermissionType  = 'CONNECT'
														AND su.PermissionState = 'GRANT'
					LEFT JOIN #PermissionInSystem sl ON u2.[LoginName] = sl.[UserName]
														AND sl.PermissionType  = 'CONNECT SQL'
														AND sl.PermissionState = 'GRANT'
				) un
			FOR XML PATH('Permission'), ROOT('Permissions')
				
		)

		SELECT @XmlResult
