CREATE TABLE [conf].[tDatabase]
(
	[DatabaseId]			 INT				IDENTITY (1, 1)													NOT NULL,
	[DatabaseName]			 NVARCHAR(256)																		NOT	NULL,
	[IsActive]				 BIT														DEFAULT(1)				NOT NULL,
	[CreatedBy]				 NVARCHAR (255)		CONSTRAINT [dfDatabase_CreatedBy]		DEFAULT (SYSTEM_USER)	NOT NULL,
	[CreatedOn]			     DATETIME2(3)		CONSTRAINT [dfDatabase_CreatedOn]		DEFAULT (GETDATE())		NOT NULL,
	[LastModifiedBy]		 NVARCHAR (255)		CONSTRAINT [dfDatabase_LastModifiedBy]	DEFAULT (SYSTEM_USER)	NOT NULL,
	[LastModifiedOn]		 DATETIME2(3)		CONSTRAINT [dfDatabase_LastModifiedOn]	DEFAULT (GETDATE())		NOT NULL
												CONSTRAINT [pkDatabase]					PRIMARY KEY CLUSTERED ([DatabaseId] ASC)
);

GO

CREATE UNIQUE NONCLUSTERED INDEX [uxDatabase_DatabaseName]
	ON [conf].[tDatabase]([DatabaseName] ASC);
GO
