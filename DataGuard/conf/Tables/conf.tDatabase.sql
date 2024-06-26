﻿CREATE TABLE [conf].[tDatabase]
(
	[DatabaseId]			 INT				IDENTITY (1, 1)														NOT NULL,
	[DatabaseName]			 NVARCHAR(256)																			NOT	NULL,
	[IsPermissionActive]		 BIT															DEFAULT(1)				NOT NULL,
	[CreatedBy]				 NVARCHAR (128)		CONSTRAINT [conf_dfDatabase_CreatedBy]		DEFAULT (SUSER_SNAME())	NOT NULL,
	[CreatedOn]			     DATETIME2(3)		CONSTRAINT [conf_dfDatabase_CreatedOn]		DEFAULT (SYSDATETIME())	NOT NULL,
	[LastModifiedBy]		 NVARCHAR (128)		CONSTRAINT [conf_dfDatabase_LastModifiedBy]	DEFAULT (SUSER_SNAME())	NOT NULL,
	[LastModifiedOn]		 DATETIME2(3)		CONSTRAINT [conf_dfDatabase_LastModifiedOn]	DEFAULT (SYSDATETIME())	NOT NULL,
												CONSTRAINT [conf_pkDatabase]					PRIMARY KEY CLUSTERED ([DatabaseId] ASC)
);

GO

CREATE UNIQUE NONCLUSTERED INDEX [uxDatabase_DatabaseName]
	ON [conf].[tDatabase]([DatabaseName] ASC);
GO



CREATE TRIGGER [conf].[trg_Database_ModyficationMeta]
	ON [conf].[tDatabase]
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
	INNER JOIN [conf].[tDatabase] u ON i.DatabaseId = u.DatabaseId
	LEFT JOIN deleted d				ON i.DatabaseId = d.DatabaseId
	WHERE d.DatabaseId IS NULL
/*
		(	    u.CreatedBy			<> IIF(d.DatabaseId IS NULL, @SuserSname, u.CreatedBy) 
			OR	u.CreatedOn			<> IIF(d.DatabaseId IS NULL, @Datetime, u.CreatedOn)
			OR  u.LastModifiedBy	<> IIF(		i.[DatabaseName]		<> d.[DatabaseName]
											OR	i.[IsPermissionActive]	<> d.[IsPermissionActive]
											OR	i.[LastModifiedOn]		<> d.[LastModifiedOn]
											OR	i.[LastModifiedBy]		<> d.[LastModifiedBy]		, @SuserSname,	u.LastModifiedBy)
			OR  u.LastModifiedOn	<> IIF(		i.[DatabaseName]		<> d.[DatabaseName]
											OR	i.[IsPermissionActive]	<> d.[IsPermissionActive]
											OR	i.[LastModifiedOn]		<> d.[LastModifiedOn]
											OR	i.[LastModifiedBy]		<> d.[LastModifiedBy] 		, @Datetime,	u.LastModifiedOn)								
		)
*/

	IF EXISTS (
		SELECT LastModifiedBy, LastModifiedOn FROM deleted
		EXCEPT 
		SELECT LastModifiedBy, LastModifiedOn FROM inserted
	)
	AND NOT EXISTS (
		SELECT DatabaseName, IsPermissionActive FROM deleted
		EXCEPT 
		SELECT DatabaseName, IsPermissionActive FROM inserted
	)
	BEGIN 
		UPDATE u 
			SET LastModifiedBy	= @SuserSname
		FROM inserted i
		INNER JOIN [conf].[tDatabase] u ON i.DatabaseId = u.DatabaseId
		LEFT JOIN deleted d				ON i.DatabaseId = d.DatabaseId
		WHERE	i.LastModifiedBy	<> @SuserSname

		UPDATE u 
			SET LastModifiedOn	= d.LastModifiedOn
		FROM inserted i
		INNER JOIN [conf].[tDatabase] u ON i.DatabaseId = u.DatabaseId
		LEFT JOIN deleted d				ON i.DatabaseId = d.DatabaseId
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
	INNER JOIN [conf].[tDatabase] u ON i.DatabaseId = u.DatabaseId
	LEFT JOIN deleted d				ON i.DatabaseId = d.DatabaseId
	WHERE	i.LastModifiedBy	<> @SuserSname
		OR  i.LastModifiedOn	<> @Datetime
	--	OR  i.[DatabaseName]	<> d.[DatabaseName]
	--	OR	i.[IsPermissionActive]	<> d.[IsPermissionActive]
	END 

END 