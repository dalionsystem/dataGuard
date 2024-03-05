CREATE TABLE [conf].[tPermission]
(
	[PermissionId] INT				NOT NULL PRIMARY KEY,
	[EnvironmentId] TINYINT			NOT NULL,
	[DatabaseId]	int				NOT NULL,
	[UserName]		NVARCHAR(128)	NOT NULL,
	[ObjectType]	VARCHAR(128)	NOT NULL DEFAULT ('%'),
	[SchemaName]	SYSNAME			NOT NULL DEFAULT ('%'),
	[ObjectName]	SYSNAME			NOT NULL DEFAULT ('%'),
	[CreatedBy]				 NVARCHAR (128)		CONSTRAINT [conf_dfPermission_CreatedBy]		DEFAULT (SYSTEM_USER)	NOT NULL,
	[CreatedOn]			     DATETIME2(3)		CONSTRAINT [conf_dfPermission_CreatedOn]		DEFAULT (GETDATE())		NOT NULL,
	[LastModifiedBy]		 NVARCHAR (128)		CONSTRAINT [conf_dfPermission_LastModifiedBy]	DEFAULT (SYSTEM_USER)	NOT NULL,
	[LastModifiedOn]		 DATETIME2(3)		CONSTRAINT [conf_dfPermission_LastModifiedOn]	DEFAULT (GETDATE())		NOT NULL
												CONSTRAINT [conf_pkPermission]					PRIMARY KEY CLUSTERED ([PermissionId] ASC)
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

