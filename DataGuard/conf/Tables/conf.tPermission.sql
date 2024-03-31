CREATE TABLE [conf].[tPermission]
(
	[PermissionId]			INT					IDENTITY (1, 1)		NOT NULL,
	[EnvironmentId]			TINYINT									NOT NULL,					--TODO
	[DatabaseId]			INT										NOT NULL,
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

