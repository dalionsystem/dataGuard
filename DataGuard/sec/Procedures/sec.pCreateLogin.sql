CREATE PROCEDURE [sec].[pCreateLogin]
	@LoginName		VARCHAR(128) 
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
								@Tab, ' @LoginName = ', @LoginName,	@CRLF,
								@Tab, ',@IsDebug = ', @IsDebug )
		PRINT @ExecQuery		 
	END


	IF @LoginName LIKE '%\%'
	BEGIN

		IF SUSER_SID(@LoginName) IS NULL
		BEGIN		
		
			SET @ErrorMessage = CONCAT('The LoginName ''', @LoginName ,''' not exists in AD or you don''t have permissions')

			;THROW 50000, @ErrorMessage, 1 

		END 

		SET @Messsage = CONCAT('Windows login ', @LoginName, ' will be created')
		IF @IsDebug=1 PRINT @Messsage

		SET @Sql = CONCAT('CREATE LOGIN ', QUOTENAME(@LoginName), ' FROM WINDOWS')

	END
	ELSE 
	BEGIN

		SET @Messsage = CONCAT('SQL login ', @LoginName, ' will be created. You must change password')
		IF @IsDebug=1 PRINT @Messsage

		SET @Sql = CONCAT('CREATE LOGIN ', QUOTENAME(@LoginName), ' WITH PASSWORD=N''', NEWID() ,''' MUST_CHANGE, CHECK_EXPIRATION=ON')

	END 


	SET @Messsage = CONCAT('Create login ', QUOTENAME(@LoginName))
	IF @IsDebug=1 PRINT @Messsage

	BEGIN TRAN
		EXEC sp_executesql @sql
	
	ROLLBACK


	SET @Messsage = CONCAT('Login ', QUOTENAME(@LoginName) , ' was created.')
	IF @IsDebug=1 PRINT @Messsage

