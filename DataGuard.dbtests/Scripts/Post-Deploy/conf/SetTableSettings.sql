

MERGE conf.tSettings d
	USING (
			'IsDemo', '1'
		   ) s (Setting, Value)
		ON d.[Setting] =s.[Setting]
	WHEN MATCHED AND  s.[Value] <> d.[Value] THEN 
		UPDATE SET [Value] = s.[Value]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([Setting],[Value])
		VALUES (s.[Setting],s.[Value])
--	WHEN NOT MATCHED BY SOURCE THEN
--		DELETE
	;