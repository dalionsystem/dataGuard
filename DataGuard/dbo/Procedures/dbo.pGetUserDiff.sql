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


	INSERT INTO #DatabaseUser 
	EXEC [dbo].[pGetListOfDatabaseUsers] @DatabaseName =@DatabaseName, @IsDebug =@IsDebug


	select * from #DatabaseUser

	SELECT DISTINCT 
		COALESCE(c.DatabaseName, i.[DatabaseName] )			AS DatabaseName
		,COALESCE(c.UserName, i.[UserName] )				AS UserName
		,c.IsEnable
		,i.IsEnable											AS SysIsEnable

		,NULLIF(c.UserName, i.UserName)					AS CreatUser
		,NULLIF(i.UserName, c.UserName)					AS DropUser
		,CASE 
			WHEN NULLIF(c.UserName, i.UserName) IS NULL AND NULLIF(i.UserName, c.UserName) IS NULL 
			THEN NULLIF(c.IsEnable, i.IsEnable)	
		END 											AS SwitchUser

	FROM [conf].[tUser] c (nolock)
	FULL OUTER JOIN #DatabaseUser  d (nolock) ON c.[DatabaseName] = d.[DatabaseName]  AND c.[UserName] = d.[UserName]
	--WHERE i.[Type]			IN ('S', 'U', 'K')   --C, R, S, U
	--   OR c.[TypeLoginId]	IN ('S', 'U', 'K') 

