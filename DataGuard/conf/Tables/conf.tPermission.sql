CREATE TABLE [conf].[tPermission]
(
	[PermissionId]			INT					IDENTITY (1, 1)		NOT NULL,
	[EnvironmentId]			TINYINT									NOT NULL,					--TODO
--	[DatabaseId]			INT										NOT NULL,
	[UserId]				INT										NOT NULL,
	[ObjectType]			VARCHAR(128)		DEFAULT ('%')		NOT NULL,
	[SchemaName]			SYSNAME				DEFAULT ('%')		NOT NULL,
	[ObjectName]			SYSNAME				DEFAULT ('%')		NOT NULL,
	[CreatedBy]				NVARCHAR (128)		CONSTRAINT [conf_dfPermission_CreatedBy]		DEFAULT (SYSTEM_USER)	NOT NULL,
	[CreatedOn]			    DATETIME2(3)		CONSTRAINT [conf_dfPermission_CreatedOn]		DEFAULT (GETDATE())		NOT NULL,
	[LastModifiedBy]		NVARCHAR (128)		CONSTRAINT [conf_dfPermission_LastModifiedBy]	DEFAULT (SYSTEM_USER)	NOT NULL,
	[LastModifiedOn]		DATETIME2(3)		CONSTRAINT [conf_dfPermission_LastModifiedOn]	DEFAULT (GETDATE())		NOT NULL,
												CONSTRAINT [conf_pkPermission]					PRIMARY KEY CLUSTERED ([PermissionId] ASC),
												CONSTRAINT [conf_fkPermission_ToDatabase]		FOREIGN KEY ([DatabaseId])	REFERENCES [conf].[tDatabase]	([DatabaseId]),
  												CONSTRAINT [conf_fkPermission_ToUser]			FOREIGN KEY ([UserId])		REFERENCES [conf].[tUser]		([UserId]),
)

GO 

ALTER TABLE [conf].[tPermission] ADD CONSTRAINT conf_chkPermission_ObjectType  CHECK ( [ObjectType]  IN ('%',
																										 'Inlinefunction',
																										 'ScalarFunction',
																										 'Procedure',
																										 'Role',
																										 'Schema',																										 
																										 'Table',																										 
																										 'View')
																					 )
																					 --'User',
																					 --'Login',
																					 --'Securable',
GO



CREATE TRIGGER [conf].[trg_tPermission_ModyficationMeta]
	ON [conf].[tPermission]
	WITH EXECUTE AS OWNER		
	AFTER INSERT, UPDATE 
AS
BEGIN 
	
	IF (ROWCOUNT_BIG() =0)
	RETURN;

	SET NOCOUNT ON;
	IF EXISTS (
		SELECT CreatedBy, CreatedOn FROM deleted
		EXCEPT 
		SELECT CreatedBy, CreatedOn FROM inserted
	)
	BEGIN
		;THROW 51000, N'Updating columns CreatedBy, CreatedOn is not allowed!', 1;
	END

	DECLARE @SuserSname nvarchar(128) 
			,@Datetime DATETIME2(3) = SYSDATETIME()

	EXECUTE AS CALLER 
		SET @SuserSname = SUSER_SNAME()
	REVERT;

	--CreateRecord
	UPDATE u 
		SET CreatedBy		= @SuserSname 
		   ,CreatedOn		= @Datetime
		   ,LastModifiedBy	= @SuserSname
		   ,LastModifiedOn	= @Datetime
	FROM inserted i
	INNER JOIN [conf].[tPermission] u ON i.PermissionId = u.PermissionId
	LEFT JOIN deleted d				ON i.PermissionId = d.PermissionId
	WHERE d.PermissionId IS NULL



	IF EXISTS (
		SELECT LastModifiedBy, LastModifiedOn FROM deleted
		EXCEPT 
		SELECT LastModifiedBy, LastModifiedOn FROM inserted
	)
	AND NOT EXISTS (
		SELECT EnvironmentId, --DatabaseId, 
				UserId, ObjectType, SchemaName, ObjectName FROM deleted
		EXCEPT 
		SELECT EnvironmentId, --DatabaseId, 
				UserId, ObjectType, SchemaName, ObjectName FROM inserted
	)
	BEGIN 
		UPDATE u 
			SET LastModifiedBy	= @SuserSname
		FROM inserted i
		INNER JOIN [conf].[tPermission] u ON i.PermissionId = u.PermissionId
		LEFT JOIN deleted d				ON i.PermissionId = d.PermissionId
		WHERE	i.LastModifiedBy	<> @SuserSname

		UPDATE u 
			SET LastModifiedOn	= d.LastModifiedOn
		FROM inserted i
		INNER JOIN [conf].[tPermission] u ON i.PermissionId = u.PermissionId
		LEFT JOIN deleted d				ON i.PermissionId = d.PermissionId
		WHERE	i.LastModifiedBy	= @SuserSname
			AND i.LastModifiedOn	<> @Datetime
	END

	IF EXISTS (
		SELECT * FROM deleted
		EXCEPT 
		SELECT * FROM inserted
	)
	BEGIN 
	--UpdateRecord
	UPDATE u 
		SET LastModifiedBy	= @SuserSname
		   ,LastModifiedOn	= @Datetime
	FROM inserted i
	INNER JOIN [conf].[tPermission] u ON i.PermissionId = u.PermissionId
	LEFT JOIN deleted d				ON i.PermissionId = d.PermissionId
	WHERE	i.LastModifiedBy		<> @SuserSname
		OR  i.LastModifiedOn		<> @Datetime
	--	OR  i.[LoginId]				<> d.[LoginId]
	--  OR  i.[DefaultSchema]	<> d.[DefaultSchema]
	--	OR	i.[IsActive]			<> d.[IsActive]

	END 

END 