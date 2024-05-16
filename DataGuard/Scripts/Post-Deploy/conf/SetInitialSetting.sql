
MERGE conf.tSetting d
	USING (
			VALUES ('IsDemo', '1')
		   ) s (SettingName, Value)
		ON d.[SettingName] =s.[SettingName]
	WHEN NOT MATCHED BY TARGET THEN
		INSERT ([SettingName],[Value])
		VALUES (s.[SettingName],s.[Value])
	;