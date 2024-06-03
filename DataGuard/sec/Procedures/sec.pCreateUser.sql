CREATE PROCEDURE [sec].[pCreateUser]
	@DatabaseName	sysname
   ,@UserName		VARCHAR(128) 
   ,@LoginName 		VARCHAR(128) 
   ,@DefaultSchema  VARCHAR(128) --= 'dbo'
   ,@IsDebug		BIT		= 0
AS
	DECLARE @Sql nvarchar(3000)
			,@Messsage nvarchar(4000) 
			,@ErrorMessage nvarchar(2000) 
			,@ExecQuery nvarchar(4000)
			,@CRLF CHAR(2) = CHAR(13)+CHAR(10)
			,@Tab nvarchar(10) = CHAR(9)

	IF @IsDebug = 1 
	BEGIN
		SET @ExecQuery = CONCAT( 'EXEC ', QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)), '.', QUOTENAME(OBJECT_NAME(@@PROCID)), @CRLF,
		 						@Tab, ' @DatabaseName = ', @DatabaseName,	@CRLF,
								@Tab, ' @UserName = ', @UserName,	@CRLF,
								@Tab, ' @LoginName = ', @LoginName,	@CRLF,
								@Tab, ' @DefaultSchema  = ', @DefaultSchema ,	@CRLF,
								@Tab, ',@IsDebug = ', @IsDebug )
		PRINT @ExecQuery		 
	END




		SET @Messsage = CONCAT('On Database ', @DatabaseName, ' User ', @UserName, ' will be created for login ', @LoginName)
		IF @IsDebug=1 PRINT @Messsage

		SET @Sql = CONCAT('USE ', QUOTENAME(@DatabaseName), @CRLF,
				' CREATE USER ', QUOTENAME(@UserName), ' FOR LOGIN ' , QUOTENAME(@UserName) , ' WITH DEFAULT_SCHEMA = ''' + @DefaultSchema + '''' )



	SET @Messsage = CONCAT('Create User ', QUOTENAME(@UserName))
	IF @IsDebug=1 PRINT @Messsage

	BEGIN TRAN
		EXEC sp_executesql @sql
	
	ROLLBACK


	SET @Messsage = CONCAT('User ', QUOTENAME(@UserName) , ' was created.')
	IF @IsDebug=1 PRINT @Messsage

