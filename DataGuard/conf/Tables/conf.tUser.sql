CREATE TABLE [conf].[tUser]
(
	[UserId]			 INT				IDENTITY (1, 1)													NOT NULL,
	[UserName]			 NVARCHAR(256)																		NOT	NULL,
--	[DatabaseId]		 INT																					NULL,
	[LoginId]			 INT																					NULL,
	[DefaultSchema]		 NVARCHAR(128)																			NULL,
	[IsActive]			 BIT														DEFAULT(1)				NOT NULL,

	[CreatedBy]			 NVARCHAR (128)		CONSTRAINT [conf_dfUser_CreatedBy]		DEFAULT (SUSER_SNAME())	NOT NULL,
	[CreatedOn]			 DATETIME2(3)		CONSTRAINT [conf_dfUser_CreatedOn]		DEFAULT (SYSDATETIME())	NOT NULL,
	[LastModifiedBy]	 NVARCHAR (128)		CONSTRAINT [conf_dfUser_LastModifiedBy]	DEFAULT (SUSER_SNAME())	NOT NULL,
	[LastModifiedOn]	 DATETIME2(3)		CONSTRAINT [conf_dfUser_LastModifiedOn]	DEFAULT (SYSDATETIME())	NOT NULL,
											CONSTRAINT [conf_pkUser]				PRIMARY KEY CLUSTERED ([UserId] ASC),
											CONSTRAINT [conf_fkUser_ToLogin]		FOREIGN KEY ([LoginId]) REFERENCES [conf].[tLogin] ([LoginId]),
)

GO 


CREATE UNIQUE NONCLUSTERED INDEX [uxUser_UserName]
	ON [conf].[tUser]([UserName] ASC);
GO
