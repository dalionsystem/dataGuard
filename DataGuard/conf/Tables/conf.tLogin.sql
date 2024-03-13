CREATE TABLE [conf].[tLogin]
(
	[LoginId]				INT				IDENTITY (1, 1)														NOT NULL,
	[LoginName]				NVARCHAR(256)																		NOT	NULL,
	[TypeLoginId]			CHAR(1)														DEFAULT('S')			NOT NULL,
	[DefaultDatabaseName]	NVARCHAR(128)																			NULL,
	[IsActive]				BIT															DEFAULT(1)				NOT NULL,
	[CreatedBy]				NVARCHAR (128)	CONSTRAINT [conf_dfLogin_CreatedBy]			DEFAULT (SUSER_SNAME())	NOT NULL,
	[CreatedOn]				DATETIME2(3)	CONSTRAINT [conf_dfLogin_CreatedOn]			DEFAULT (SYSDATETIME())	NOT NULL,
	[LastModifiedBy]		NVARCHAR (128)	CONSTRAINT [conf_dfLogin_LastModifiedBy]	DEFAULT (SUSER_SNAME())	NOT NULL,
	[LastModifiedOn]		DATETIME2(3)	CONSTRAINT [conf_dfLogin_LastModifiedOn]	DEFAULT (SYSDATETIME())	NOT NULL,

		CONSTRAINT [conf_pkLogin]				PRIMARY KEY CLUSTERED ([LoginId] ASC),
		CONSTRAINT [conf_fkLogin_ToTypeLogin]	FOREIGN KEY ([TypeLoginId]) REFERENCES [def].[tTypeLogin] ([TypeLoginId]),
)

GO



CREATE UNIQUE NONCLUSTERED INDEX [uxLogin_LoginName]
	ON [conf].[tLogin]([LoginName] ASC);
GO
