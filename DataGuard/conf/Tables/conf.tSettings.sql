CREATE TABLE [conf].[tSettings]
(
	 [SettingId]				INT					IDENTITY (1, 1)														NOT NULL,
	 [SettingName]				VARCHAR(50)																				NOT NULL,
	 [Value]					VARCHAR(50)																				NOT NULL,
	 [CreatedBy]				NVARCHAR (128)		CONSTRAINT [conf_dfSettings_CreatedBy]		DEFAULT (SYSTEM_USER)	NOT NULL,
	 [CreatedOn]			    DATETIME2(3)		CONSTRAINT [conf_dfSettings_CreatedOn]		DEFAULT (GETDATE())		NOT NULL,
	 [LastModifiedBy]			NVARCHAR (128)		CONSTRAINT [conf_dfSettings_LastModifiedBy]	DEFAULT (SYSTEM_USER)	NOT NULL,
	 [LastModifiedOn]			DATETIME2(3)		CONSTRAINT [conf_dfSettings_LastModifiedOn]	DEFAULT (GETDATE())		NOT NULL,
													CONSTRAINT [conf_pkSettings]				PRIMARY KEY CLUSTERED ([SettingId] ASC),
)
