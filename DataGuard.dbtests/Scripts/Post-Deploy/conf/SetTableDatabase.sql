
;WITH sysDatabases AS ( 
	select 
			d.name COLLATE SQL_Latin1_General_CP1_CI_AS  AS [DatabaseName] 
		   ,case 
				when d.name not in ('tempdb', 'model')	THEN 1
				ELSE 0 
			END AS [IsPermissionActive]
			from sys.databases (nolock) d
)


MERGE conf.tDatabase d
	USING sysDatabases s
		ON d.[DatabaseName] =s.[DatabaseName]
	WHEN MATCHED AND  s.[IsPermissionActive] <> d.[IsPermissionActive] THEN 
		UPDATE SET [IsPermissionActive] = s.[IsPermissionActive]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([DatabaseName],[IsPermissionActive])
		VALUES (s.[DatabaseName],s.[IsPermissionActive])
--	WHEN NOT MATCHED BY SOURCE THEN
--		DELETE
	;