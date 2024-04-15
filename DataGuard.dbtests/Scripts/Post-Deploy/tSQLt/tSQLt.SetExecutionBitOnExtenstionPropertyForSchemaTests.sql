
IF NOT EXISTS (SELECT * FROM SYS.EXTENDED_PROPERTIES WHERE class_desc = 'SCHEMA' AND NAME = 'tSQLt.TestClass' AND value = 1)
BEGIN
EXEC sp_addextendedproperty @name = N'tSQLt.TestClass', 
                        @value = 1,
                        @level0type = 'SCHEMA',
                        @level0name = 'test';
END