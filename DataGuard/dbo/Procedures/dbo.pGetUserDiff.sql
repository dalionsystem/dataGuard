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

/*
	SELECT DISTINCT 
		COALESCE(c.LoginName , i.[LoginName] )				AS LoginName
		,c.IsActive
		,i.IsActive											AS SysIsActive
		,COALESCE(i.[LastModifiedOn] ,c.[LastModifiedOn] )	AS LastModifiedOn
		,NULLIF(c.LoginName, i.LoginName)					AS CreatLogin
		,NULLIF(i.LoginName, c.LoginName)					AS Droplogin
		,CASE 
			WHEN NULLIF(c.LoginName, i.LoginName) IS NULL AND NULLIF(i.LoginName, c.LoginName) IS NULL 
			THEN NULLIF(c.IsActive, i.IsActive)	
		END 											AS SwitchLogin

	FROM [conf].[tLogin] c (nolock)
	FULL OUTER JOIN #InstanceLogin i (nolock) ON c.LoginName = i.LoginName
	WHERE i.[Type]			IN ('S', 'U', 'K')   --C, R, S, U
	   OR c.[TypeLoginId]	IN ('S', 'U', 'K') 
*/
