CREATE PROCEDURE [dbo].[pObjectInSystem]
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
								@Tab, ' @DatabaseName = ', IIF(@DatabaseName LIKE '%', QUOTENAME(@DatabaseName,''''), @DatabaseName ) ,	@CRLF,							
								@Tab, ',@IsDebug = ', @IsDebug )

		PRINT @ExecQuery
		 
	END


	IF OBJECT_ID('tempdb..#ObjectInSystem') IS NOT NULL  DROP TABLE #ObjectInSystem


	CREATE TABLE #ObjectInSystem
	(
	   [DatabaseName]	 sysname 		NULL
	  ,[Type]			 varchar(100)
	  ,[SchemaName]		 sysname		NULL
	  ,[ObjectName]		 varchar(100)
	)



	IF @DatabaseName <> '%'
	BEGIN
		INSERT INTO #ObjectInSystem ([DatabaseName], [Type], [SchemaName], [ObjectName])
		EXEC [dbo].[pGetListOfDatabaseObject] @DatabaseName=@DatabaseName, @IsDebug= @IsDebug
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
					INSERT INTO #ObjectInSystem ([DatabaseName], [Type], [SchemaName], [ObjectName])
				EXEC [dbo].[pGetListOfDatabaseObject] @DatabaseName=@DatabaseNameLoop, @IsDebug= @IsDebug
			END TRY
			BEGIN CATCH	
				SET @ErrorMessage  = CONCAT('Error when get data from dbo.pGetListOfDatabaseObject on DatabaseName ', @DatabaseNameLoop)
				PRINT @ErrorMessage 
			END CATCH


			FETCH NEXT FROM  databaseNameCursor INTO @DatabaseNameLoop
		END

		CLOSE databaseNameCursor 
		DEALLOCATE databaseNameCursor 

	END 



	SELECT *
	FROM #ObjectInSystem
