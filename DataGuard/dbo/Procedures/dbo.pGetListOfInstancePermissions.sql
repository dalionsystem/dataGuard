CREATE PROCEDURE [dbo].[pGetListOfInstancePermissions]
	@IsDebug		BIT		= 0
AS
	DECLARE 
			 @ErrorMessage nvarchar(2000) 
			,@ExecQuery nvarchar(4000)
			,@CRLF CHAR(2) = CHAR(13)+CHAR(10)
			,@Tab nvarchar(10) = CHAR(9)

	IF @IsDebug = 1 
	BEGIN
		SET @ExecQuery = CONCAT( 'EXEC ', QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID)), '.', QUOTENAME(OBJECT_NAME(@@PROCID)), @CRLF,
								@Tab, '@IsDebug = ', @IsDebug )

		PRINT @ExecQuery
		 
	END


		SELECT DISTINCT
				 c.[type]						 AS [Type]
				,c.[name]						 AS [UserName]		--RoleName
				,m.[class_desc]					 AS [ClassDesc]
				,m.[permission_name]			 AS [PermmisionType]
				,m.[state_desc]					 AS [PermmisionState]
		
		FROM		sys.server_principals (nolock) c
		INNER JOIN	sys.server_permissions (nolock) m ON m.[grantee_principal_id] = c.[principal_id]
		



