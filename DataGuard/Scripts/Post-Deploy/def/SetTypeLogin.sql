

MERGE def.tTypeLogin d
	USING (
		VALUES ('S', 'SQL_LOGIN')
			  ,('R', 'SERVER_ROLE')
			  ,('C', 'CERTIFICATE_MAPPED_LOGIN')
			  ,('U', 'WINDOWS_LOGIN')
	) s ([TypeLoginId],[TypeDescription]) ON d.[TypeLoginId] =s.[TypeLoginId]
	WHEN MATCHED AND  s.[TypeDescription] <> d.[TypeDescription] THEN 
		UPDATE SET [TypeDescription] = s.[TypeDescription]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([TypeLoginId],[TypeDescription])
		VALUES (s.[TypeLoginId],s.[TypeDescription])
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;