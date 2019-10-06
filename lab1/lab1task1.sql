BACKUP DATABASE [AdventureWorks2012] TO DISK = 'E:\backup.bak'
GO

USE [master];
GO

DECLARE @dbId INT;

SET @dbId = DB_ID(N'AdventureWorks2012');

IF @dbId IS NOT NULL
BEGIN;

	 ALTER DATABASE [AdventureWorks2012]
	 SET SINGLE_USER
	 WITH
	 ROLLBACK IMMEDIATE;

	 DROP DATABASE [AdventureWorks2012];

	 RESTORE DATABASE [AdventureWorks2012]
	 FROM DISK = 'E:\backup.bak'
END;
GO

