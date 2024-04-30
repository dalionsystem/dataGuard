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

		CONSTRAINT [conf_pkLogin]					PRIMARY KEY CLUSTERED ([LoginId] ASC),
		CONSTRAINT [conf_fkLogin_ToTypeLogin]		FOREIGN KEY ([TypeLoginId])				REFERENCES [def].[tTypeLogin] ([TypeLoginId]),
)

GO



CREATE UNIQUE NONCLUSTERED INDEX [uxLogin_LoginName]
	ON [conf].[tLogin]([LoginName] ASC);
GO




CREATE TRIGGER [conf].[trg_tLogin_ModyficationMeta]
	ON [conf].[tLogin]
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
	INNER JOIN [conf].[tLogin] u ON i.LoginId = u.LoginId
	LEFT JOIN deleted d				ON i.LoginId = d.LoginId
	WHERE d.LoginId IS NULL



	IF EXISTS (
		SELECT LastModifiedBy, LastModifiedOn FROM deleted
		EXCEPT 
		SELECT LastModifiedBy, LastModifiedOn FROM inserted
	)
	AND NOT EXISTS (
		SELECT LoginName, TypeLoginId, DefaultDatabaseName, IsActive FROM deleted
		EXCEPT 
		SELECT LoginName, TypeLoginId, DefaultDatabaseName, IsActive FROM inserted
	)
	BEGIN 
		UPDATE u 
			SET LastModifiedBy	= @SuserSname
		FROM inserted i
		INNER JOIN [conf].[tLogin] u ON i.LoginId = u.LoginId
		LEFT JOIN deleted d				ON i.LoginId = d.LoginId
		WHERE	i.LastModifiedBy	<> @SuserSname

		UPDATE u 
			SET LastModifiedOn	= d.LastModifiedOn
		FROM inserted i
		INNER JOIN [conf].[tLogin] u ON i.LoginId = u.LoginId
		LEFT JOIN deleted d				ON i.LoginId = d.LoginId
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
	INNER JOIN [conf].[tLogin] u ON i.LoginId = u.LoginId
	LEFT JOIN deleted d				ON i.LoginId = d.LoginId
	WHERE	i.LastModifiedBy		<> @SuserSname
		OR  i.LastModifiedOn		<> @Datetime
	--	OR  i.[TypeLoginId]			<> d.[TypeLoginId]
	--  OR  i.[DefaultDatabaseName]	<> d.[DefaultDatabaseName]
	--	OR	i.[IsActive]			<> d.[IsActive]

	END 

END 