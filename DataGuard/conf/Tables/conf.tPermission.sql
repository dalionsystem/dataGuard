CREATE TABLE [conf].[tPermission]
(
	[PermisstionId] INT				NOT NULL PRIMARY KEY,
	[EnvironmentId] TINYINT			NOT NULL,
	[DatabaseId]	int				NOT NULL,
	[UserName]		NVARCHAR(128)	NOT NULL,
	[ObjectType]	VARCHAR(128)	NOT NULL DEFAULT ('%'),
	[SchemaName]	SYSNAME			NOT NULL DEFAULT ('%'),
	[ObjectName]	SYSNAME			NOT NULL DEFAULT ('%'),
		[CreatedBy]				 NVARCHAR (128)		CONSTRAINT [conf_dfDatabase_CreatedBy]		DEFAULT (SYSTEM_USER)	NOT NULL,
	[CreatedOn]			     DATETIME2(3)		CONSTRAINT [conf_dfDatabase_CreatedOn]		DEFAULT (GETDATE())		NOT NULL,
	[LastModifiedBy]		 NVARCHAR (128)		CONSTRAINT [conf_dfDatabase_LastModifiedBy]	DEFAULT (SYSTEM_USER)	NOT NULL,
	[LastModifiedOn]		 DATETIME2(3)		CONSTRAINT [conf_dfDatabase_LastModifiedOn]	DEFAULT (GETDATE())		NOT NULL
												CONSTRAINT [conf_pkDatabase]					PRIMARY KEY CLUSTERED ([DatabaseId] ASC)
)
