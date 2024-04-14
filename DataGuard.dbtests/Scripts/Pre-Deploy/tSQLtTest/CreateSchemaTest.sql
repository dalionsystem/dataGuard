IF SCHEMA_ID('test') IS NULL
	EXEC tSQLt.NewTestClass 'test';
GO

EXEC sp_addextendedproperty @name = N'tSQLt.TestClass', 
                        @value = 1,
                        @level0type = 'SCHEMA',
                        @level0name = 'test';