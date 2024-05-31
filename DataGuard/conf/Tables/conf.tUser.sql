CREATE TABLE [conf].[tUser]
(
	[UserId]			 INT				IDENTITY (1, 1)													NOT NULL,
	[UserName]			 NVARCHAR(256)																		NOT	NULL,
	[DatabaseId]		 INT																					NULL,
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


CREATE UNIQUE NONCLUSTERED INDEX [uxUser_UserName_LoginId]
	ON [conf].[tUser]([UserName] ASC, [LoginId]);
GO


CREATE TRIGGER [conf].[trg_tUser_ModyficationMeta]
	ON [conf].[tUser]
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
	INNER JOIN [conf].[tUser] u ON i.UserId = u.UserId
	LEFT JOIN deleted d				ON i.UserId = d.UserId
	WHERE d.UserId IS NULL



	IF EXISTS (
		SELECT LastModifiedBy, LastModifiedOn FROM deleted
		EXCEPT 
		SELECT LastModifiedBy, LastModifiedOn FROM inserted
	)
	AND NOT EXISTS (
		SELECT UserName, LoginId, DefaultSchema, IsActive FROM deleted
		EXCEPT 
		SELECT UserName, LoginId, DefaultSchema, IsActive FROM inserted
	)
	BEGIN 
		UPDATE u 
			SET LastModifiedBy	= @SuserSname
		FROM inserted i
		INNER JOIN [conf].[tUser] u ON i.UserId = u.UserId
		LEFT JOIN deleted d				ON i.UserId = d.UserId
		WHERE	i.LastModifiedBy	<> @SuserSname

		UPDATE u 
			SET LastModifiedOn	= d.LastModifiedOn
		FROM inserted i
		INNER JOIN [conf].[tUser] u ON i.UserId = u.UserId
		LEFT JOIN deleted d				ON i.UserId = d.UserId
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
	INNER JOIN [conf].[tUser] u ON i.UserId = u.UserId
	LEFT JOIN deleted d				ON i.UserId = d.UserId
	WHERE	i.LastModifiedBy		<> @SuserSname
		OR  i.LastModifiedOn		<> @Datetime
	--	OR  i.[LoginId]				<> d.[LoginId]
	--  OR  i.[DefaultSchema]	<> d.[DefaultSchema]
	--	OR	i.[IsActive]			<> d.[IsActive]

	END 

END 