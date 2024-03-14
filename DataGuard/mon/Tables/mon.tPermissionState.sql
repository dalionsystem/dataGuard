CREATE TABLE [mon].[tPermissionState]
(
--	[Id] INT NOT NULL PRIMARY KEY,
	[Database]		SYSNAME NULL,
	[User]			SYSNAME NULL,
	[Role]			SYSNAME NULL,
	[ObjectType]	SYSNAME NULL,
	[Schema]		SYSNAME NULL,
	[ObjectName]	SYSNAME NULL,
	[Permission]	SYSNAME NULL

)
