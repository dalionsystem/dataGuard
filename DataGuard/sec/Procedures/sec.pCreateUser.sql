CREATE PROCEDURE [sec].[pCreateUser]
	@UserName		VARCHAR(128) 
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
								@Tab, ' @UserName = ', @UserName,	@CRLF,
								@Tab, ',@IsDebug = ', @IsDebug )
		PRINT @ExecQuery		 
	END




		SET @Messsage = CONCAT('SQL User ', @UserName, ' will be created. You must change password')
		IF @IsDebug=1 PRINT @Messsage

		SET @Sql = CONCAT('CREATE User ', QUOTENAME(@UserName), ' WITH PASSWORD=N''', NEWID() ,''' MUST_CHANGE, CHECK_EXPIRATION=ON')



	SET @Messsage = CONCAT('Create User ', QUOTENAME(@UserName))
	IF @IsDebug=1 PRINT @Messsage

	BEGIN TRAN
		EXEC sp_executesql @sql
	
	ROLLBACK


	SET @Messsage = CONCAT('User ', QUOTENAME(@UserName) , ' was created.')
	IF @IsDebug=1 PRINT @Messsage

