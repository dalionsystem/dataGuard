CREATE PROCEDURE [dbo].[pGetListOfDatabaseObject]
	
	@DatabaseName	sysname,
	@Type			varchar(30) ='%',
	@Schema			sysname = '%',
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
								@Tab, '@Type = ', @Type,	@CRLF,
								@Tab, '@Schema = ', @Schema,	@CRLF,
								@Tab, '@IsDebug = ', @IsDebug )

		PRINT @ExecQuery
		 
	END


	IF DB_ID(@DatabaseName) IS NULL OR HAS_DBACCESS(@DatabaseName) = 0
	BEGIN
		SET @ErrorMesssage = CONCAT('The database ',@DatabaseName,' not exists!')
		;THROW 50001, @ErrorMesssage ,1;
	END


	DECLARE @ObjectTable TABLE 
	(
	--	 [DatabaseName] sysname
		 [Type]			varchar(20)
		,[Schema]		sysname
		,[ObjectName]	sysname
	)



	IF @Type = 'Table' --OR @Type = '%'
	BEGIN
		SET @Sql = CONCAT('
					SELECT @DatabaseName	AS	[DatabaseName] 						  	
						  ,''Table''			AS [Type]
						  ,[Table_SCHEMA]	AS [Schema]
						  ,[TABLE_NAME]		AS [TableName]
					FROM ', QUOTENAME(@DatabaseName),'.[INFORMATION_SCHEMA].[TABLES]
					WHERE [TABLE_TYPE] = ''BASE TABLE''', @CRLF,
					IIF(@Schema = '%', NULL, ' AND [TABLE_SCHEMA] = @Schema ')
					)

	/*	INSERT INTO @ObjectTable([Type],[Schema],[ObjectName])
		SELECT 'Table'			AS [Type]
			  ,[Table_SCHEMA]	AS [Schema]
			  ,[TABLE_NAME]		AS [TableName]
		FROM [DataGuard].[INFORMATION_SCHEMA].[TABLES]
		WHERE [TABLE_TYPE] = 'BASE TABLE'
			AND ([TABLE_SCHEMA] = @Schema OR @Schema = '%') 
	*/
	END



	IF @Type = 'View' 
	BEGIN
		SET @Sql = CONCAT('
			SELECT @DatabaseName	AS	[DatabaseName] 						  	
					,''View''			AS [Type]
					,[Table_SCHEMA]	AS [Schema]
					,[TABLE_NAME]		AS [TableName]
			FROM ', QUOTENAME(@DatabaseName),'.[INFORMATION_SCHEMA].[TABLES]
			WHERE [TABLE_TYPE] = ''View''', @CRLF,
			IIF(@Schema = '%', NULL, ' AND [TABLE_SCHEMA] = @Schema ')
			)
	END


	IF @Type = 'Procedure' OR @Type = '%'
	BEGIN
		INSERT INTO @ObjectTable([Type],[Schema],[ObjectName])
		SELECT 'Procedure'			AS [Type]
			  ,[SPECIFIC_SCHEMA]	AS [Schema]
			  ,[SPECIFIC_NAME]		AS [ObjectName]
		FROM [DataGuard].[INFORMATION_SCHEMA].[ROUTINES]
		WHERE [ROUTINE_TYPE] = 'PROCEDURE'
			AND ([SPECIFIC_SCHEMA] = @Schema OR @Schema = '%') 
	END


	IF @Type = 'InlineFunction' OR @Type = '%'
	BEGIN
		INSERT INTO @ObjectTable([Type],[Schema],[ObjectName])
		SELECT 'InlineFunction'		AS [Type]
			  ,[SPECIFIC_SCHEMA]	AS [Schema]
			  ,[SPECIFIC_NAME]		AS [ObjectName]
		FROM [DataGuard].[INFORMATION_SCHEMA].[ROUTINES]
		WHERE [ROUTINE_TYPE] = 'FUNCTION'
			AND DATA_TYPE = 'TABLE'
			AND ([SPECIFIC_SCHEMA] = @Schema OR @Schema = '%') 
	END


	IF @Type = 'ScalarFunction' OR @Type = '%'
	BEGIN
		INSERT INTO @ObjectTable([Type],[Schema],[ObjectName])
		SELECT 'ScalarFunction'		AS [Type]
			  ,[SPECIFIC_SCHEMA]	AS [Schema]
			  ,[SPECIFIC_NAME]		AS [ObjectName]
		FROM [DataGuard].[INFORMATION_SCHEMA].[ROUTINES]
		WHERE [ROUTINE_TYPE] = 'FUNCTION'
			AND DATA_TYPE != 'TABLE'
			AND ([SPECIFIC_SCHEMA] = @Schema OR @Schema = '%') 
	END


	--TODO

	PRINT @sql




	EXEC SP_executesql @sql , N'@DatabaseName nvarchar(255) ,@Schema SYSNAME' , @DatabaseName = @DatabaseName, @Schema = @Schema
