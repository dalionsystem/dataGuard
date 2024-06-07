 CREATE PROCEDURE [dbo].[pGetUserDiff]
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


	

	CREATE TABLE #DatabaseUser
	(
		 [DatabaseName]			SYSNAME 		COLLATE SQL_Latin1_General_CP1_CI_AS  
		,[UserName]				VARCHAR(128)	COLLATE SQL_Latin1_General_CP1_CI_AS  
		,[Type]					CHAR(1)
		,[AuthenticationType]	VARCHAR(20)		COLLATE SQL_Latin1_General_CP1_CI_AS  
		,[IsEnable]				BIT
	)


	IF @DatabaseName <> '%'
	BEGIN
		INSERT INTO #DatabaseUser 
		EXEC [dbo].[pGetListOfDatabaseUsers] @DatabaseName =@DatabaseName, @IsDebug =@IsDebug
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
				INSERT INTO #DatabaseUser 
				EXEC [dbo].[pGetListOfDatabaseUsers] @DatabaseName=@DatabaseNameLoop, @IsDebug= @IsDebug
			END TRY
			BEGIN CATCH	
				SET @ErrorMessage  = CONCAT('Error when get users from dbo.pGetListOfDatabaseUsers on DatabaseName ', @DatabaseNameLoop)
				PRINT @ErrorMessage 
			END CATCH

			FETCH NEXT FROM  databaseNameCursor INTO @DatabaseNameLoop
		END

		CLOSE databaseNameCursor 
		DEALLOCATE databaseNameCursor 
	END


--	select * from #DatabaseUser

	SELECT DISTINCT 
		 COALESCE(cd.DatabaseName, d.[DatabaseName] )		AS DatabaseName
		,COALESCE(c.UserName, d.[UserName] )				AS UserName
		,c.IsActive											AS IsEnable
		,d.IsEnable											AS SysIsEnable
		,NULLIF(c.UserName, d.UserName)						AS CreateUser
		,NULLIF(d.UserName, c.UserName)						AS DropUser
		,CASE 
			WHEN NULLIF(c.UserName, d.UserName) IS NULL AND NULLIF(d.UserName, c.UserName) IS NULL 
			THEN NULLIF(c.IsActive, d.IsEnable)	
		END 												AS SwitchUser

	FROM [conf].[tUser] c (nolock)
	INNER JOIN [conf].[tPermission] p (nolock) ON c.UserId = p.UserId
	INNER JOIN [conf].[tDatabase] cd (nolock) ON c.DatabaseId =cd.DatabaseId 
	FULL OUTER JOIN #DatabaseUser  d (nolock) ON cd.[DatabaseName] = d.[DatabaseName]  AND c.[UserName] = d.[UserName]


