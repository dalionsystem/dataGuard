CREATE TABLE [conf].[tSetting]
(
	 [SettingId]				INT					IDENTITY (1, 1)														NOT NULL,
	 [SettingName]				VARCHAR(50)																				NOT NULL,
	 [Value]					VARCHAR(50)																				NOT NULL,
	 [CreatedBy]				NVARCHAR (128)		CONSTRAINT [conf_dfSetting_CreatedBy]		DEFAULT (SYSTEM_USER)	NOT NULL,
	 [CreatedOn]			    DATETIME2(3)		CONSTRAINT [conf_dfSetting_CreatedOn]		DEFAULT (GETDATE())		NOT NULL,
	 [LastModifiedBy]			NVARCHAR (128)		CONSTRAINT [conf_dfSetting_LastModifiedBy]	DEFAULT (SYSTEM_USER)	NOT NULL,
	 [LastModifiedOn]			DATETIME2(3)		CONSTRAINT [conf_dfSetting_LastModifiedOn]	DEFAULT (GETDATE())		NOT NULL,
													CONSTRAINT [conf_pkSetting]					PRIMARY KEY NONCLUSTERED ([SettingName] ASC),
)

GO

CREATE CLUSTERED INDEX [uix_conf_Setting_SettingId] ON [conf].[tSetting]([SettingId])

GO


CREATE TRIGGER [conf].[trg_tSetting_ModyficationMeta]
	ON [conf].[tSetting]
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
	INNER JOIN [conf].[tSetting] u ON i.SettingId = u.SettingId
	LEFT JOIN deleted d				ON i.SettingId = d.SettingId
	WHERE d.SettingId IS NULL



	IF EXISTS (
		SELECT LastModifiedBy, LastModifiedOn FROM deleted
		EXCEPT 
		SELECT LastModifiedBy, LastModifiedOn FROM inserted
	)
	AND NOT EXISTS (
		SELECT SettingName, Value FROM deleted
		EXCEPT 
		SELECT SettingName, Value FROM inserted
	)
	BEGIN 
		UPDATE u 
			SET LastModifiedBy	= @SuserSname
		FROM inserted i
		INNER JOIN [conf].[tSetting] u	ON i.SettingId = u.SettingId
		LEFT JOIN deleted d				ON i.SettingId = d.SettingId
		WHERE	i.LastModifiedBy	<> @SuserSname

		UPDATE u 
			SET LastModifiedOn	= d.LastModifiedOn
		FROM inserted i
		INNER JOIN [conf].[tSetting] u ON i.SettingId = u.SettingId
		LEFT JOIN deleted d			   ON i.SettingId = d.SettingId
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
	INNER JOIN [conf].[tSetting] u ON i.SettingId = u.SettingId
	LEFT JOIN deleted d				ON i.SettingId = d.SettingId
	WHERE	i.LastModifiedBy		<> @SuserSname
		OR  i.LastModifiedOn		<> @Datetime
	--	OR  i.[LoginId]				<> d.[LoginId]
	--  OR  i.[DefaultSchema]	<> d.[DefaultSchema]
	--	OR	i.[IsActive]			<> d.[IsActive]

	END 

END 