CREATE TABLE [def].[tTypeLogin]
(
	[TypeLoginId]		CHAR(1)		NOT NULL,
	[TypeDescription]	VARCHAR(30)	NOT NULL
	CONSTRAINT [def_pkTypeLogin]			PRIMARY KEY CLUSTERED ([TypeLoginId] ASC),
)
