IF SCHEMA_ID('test') IS NULL
	EXEC tSQLt.NewTestClass 'test';
GO