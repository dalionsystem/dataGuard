  USE [master]
  GO

  EXEC master.sys.sp_configure @configname='clr enabled', @configvalue = 1;
  RECONFIGURE;

  USE [$DatabaseName]
  GO
