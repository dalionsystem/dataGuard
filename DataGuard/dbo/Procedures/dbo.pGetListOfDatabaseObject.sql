CREATE PROCEDURE [dbo].[pGetListOfDatabaseObject]
	
	@DatabaseName	sysname,
	@Type			varchar(30) ='%',
	@Schema			sysname = '%',
	@IsDebug		BIT		= 0
AS
	DECLARE @Sql nvarchar(3000)
			,@ErrorMesssage nvarchar(2000) 
			,@ExecQuery nvarchar(max)
			,@CRLF CHAR(2) = CHAR(13)+CHAR(10)
			,@Tab nvarchar(10) = CHAR(9)

	IF @IsDebug = 1 
	BEGIN
		SET @ExecQuery = CONCAT( 'EXEC ', QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)), '.', QUOTENAME(OBJECT_NAME(@@PROCID)), @CRLF,
								@Tab, ' @DatabaseName = ', IIF(@DatabaseName LIKE '%', QUOTENAME(@DatabaseName,''''), @DatabaseName ),	@CRLF,
								@Tab, ',@Type = ', @Type,	@CRLF,
								@Tab, ',@Schema = ', @Schema,	@CRLF,
								@Tab, ',@IsDebug = ', @IsDebug )

		PRINT @ExecQuery		 
	END

	EXEC [dbo].[pThrowErrorIfDatabaseNotExists] @DatabaseName = @DatabaseName , @IsDebug = @IsDebug


/*	DECLARE @ObjectTable TABLE 
	(
		 [DatabaseName] sysname
		 [Type]			varchar(20)
		,[Schema]		sysname
		,[ObjectName]	sysname
	)
*/


	IF @Type = 'Table' 
	BEGIN
		SET @Sql = CONCAT('
				SELECT @DatabaseName	AS [DatabaseName] 						  	
						,''Table''		AS [Type]
						,[Table_SCHEMA]	AS [Schema]
						,[TABLE_NAME]	AS [TableName]
				FROM ', QUOTENAME(@DatabaseName),'.[INFORMATION_SCHEMA].[TABLES]  (nolock)
				WHERE [TABLE_TYPE] = ''BASE TABLE''
				', 
				IIF(@Schema = '%', NULL, ' AND [TABLE_SCHEMA] = @Schema ')
				)
	END



	IF @Type = 'View' 
	BEGIN
		SET @Sql = CONCAT('
				SELECT @DatabaseName	AS [DatabaseName] 						  	
						,''View''		AS [Type]
						,[Table_SCHEMA]	AS [Schema]
						,[TABLE_NAME]	AS [TableName]
				FROM ', QUOTENAME(@DatabaseName),'.[INFORMATION_SCHEMA].[TABLES] (nolock)
				WHERE [TABLE_TYPE] = ''View''
				', 
				IIF(@Schema = '%', NULL, ' AND [TABLE_SCHEMA] = @Schema ')
				)
	END


	IF @Type = 'Procedure' 
	BEGIN
		SET @Sql = CONCAT('
				SELECT @DatabaseName		AS [DatabaseName] 						  	
						,''Procedure''		AS [Type]
						,[SPECIFIC_SCHEMA]	AS [Schema]
						,[SPECIFIC_NAME]	AS [TableName]
				FROM ', QUOTENAME(@DatabaseName),'.[INFORMATION_SCHEMA].[ROUTINES] (nolock)
				WHERE [ROUTINE_TYPE] = ''PROCEDURE''
				', 
				IIF(@Schema = '%', NULL, ' AND [SPECIFIC_SCHEMA] = @Schema ')
				)
	END


	IF @Type = 'InlineFunction' 
	BEGIN
		SET @Sql = CONCAT('
				SELECT @DatabaseName		AS	[DatabaseName] 						  	
						,''InlineFunction''	AS [Type]
						,[SPECIFIC_SCHEMA]	AS [Schema]
						,[SPECIFIC_NAME]	AS [TableName]
				FROM ', QUOTENAME(@DatabaseName),'.[INFORMATION_SCHEMA].[ROUTINES] (nolock)
				WHERE [ROUTINE_TYPE] = ''FUNCTION''
					AND DATA_TYPE = ''TABLE''
				', 
				IIF(@Schema = '%', NULL, ' AND [SPECIFIC_SCHEMA] = @Schema ')
				)
	END


	IF @Type = 'ScalarFunction' 
	BEGIN

		SET @Sql = CONCAT('
			SELECT @DatabaseName			AS [DatabaseName] 						  	
					,''ScalarFunction''		AS [Type]
					,[SPECIFIC_SCHEMA]		AS [Schema]
					,[SPECIFIC_NAME]		AS [TableName]
			FROM ', QUOTENAME(@DatabaseName),'.[INFORMATION_SCHEMA].[ROUTINES] (nolock)
			WHERE [ROUTINE_TYPE] = ''FUNCTION''
				AND DATA_TYPE != ''TABLE''
			', 
			IIF(@Schema = '%', NULL, ' AND [SPECIFIC_SCHEMA] = @Schema ')
			) 
	END


	IF @Type = '%'
	BEGIN

		SET @Sql = CONCAT('
				SELECT @DatabaseName	AS [DatabaseName] 						  	
						,CASE
							WHEN [TABLE_TYPE] = ''View'' THEN ''View''
							WHEN [TABLE_TYPE] = ''BASE TABLE'' THEN ''Table''
							ELSE [TABLE_TYPE]
						END AS [Type]
						,[Table_SCHEMA]	AS [Schema]
						,[TABLE_NAME]		AS [TableName]
				FROM ', QUOTENAME(@DatabaseName),'.[INFORMATION_SCHEMA].[TABLES] (nolock)
				', 
				IIF(@Schema = '%', NULL, ' WHERE [TABLE_SCHEMA] = @Schema ')
				,'
			UNION ALL
			SELECT @DatabaseName			AS	[DatabaseName] 						  	
					,CASE 
						WHEN [ROUTINE_TYPE] = ''PROCEDURE'' THEN ''Procedure''
						WHEN [ROUTINE_TYPE] = ''FUNCTION'' AND DATA_TYPE != ''TABLE'' THEN ''ScalarFunction''
						WHEN [ROUTINE_TYPE] = ''FUNCTION'' AND DATA_TYPE  = ''TABLE'' THEN ''InlineFunction''
						ELSE [ROUTINE_TYPE] 
					END						AS [Type]
					,[SPECIFIC_SCHEMA]		AS [Schema]
					,[SPECIFIC_NAME]		AS [TableName]
			FROM ', QUOTENAME(@DatabaseName),'.[INFORMATION_SCHEMA].[ROUTINES] (nolock)
			', 
			IIF(@Schema = '%', NULL, ' WHERE [SPECIFIC_SCHEMA] = @Schema ')
			) 
	END


	IF @IsDebug =1 PRINT @sql


	EXEC sp_executesql @sql , N'@DatabaseName nvarchar(255) ,@Schema SYSNAME' , @DatabaseName = @DatabaseName, @Schema = @Schema
