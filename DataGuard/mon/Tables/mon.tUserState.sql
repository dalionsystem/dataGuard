﻿CREATE TABLE [mon].[tUserState]
(
	[UserStateId]		INT			 NOT NULL PRIMARY KEY,
	[DatabaseName]		SYSNAME			 NULL,
	[User]				SYSNAME			 NULL,
	[PermissionType]	varchar(100)	 NULL

)
