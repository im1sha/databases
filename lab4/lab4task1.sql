-- a) Создайте таблицу Production.ProductCategoryHst, 
-- которая будет хранить информацию об изменениях 
-- в таблице Production.ProductCategory.
-- 
-- Обязательные поля, которые должны присутствовать в таблице: 
-- ID — первичный ключ IDENTITY(1,1); 
-- Action — совершенное действие (insert, update или delete); 
-- ModifiedDate — дата и время, когда была совершена операция; 
-- SourceID — первичный ключ исходной таблицы; 
-- UserName — имя пользователя, совершившего операцию. 
-- Создайте другие поля, если считаете их нужными.
IF OBJECT_ID('[Production].[ProductCategoryHst]', 'U') IS NULL
	CREATE TABLE [Production].[ProductCategoryHst] (
		 [ID] INT IDENTITY(1, 1) PRIMARY KEY
		 ,[Action] NVARCHAR(10) NOT NULL
		 ,[ModifiedDate] DATETIME NOT NULL
		 ,[SourceID] NVARCHAR(10) NOT NULL
		 ,[UserName] NVARCHAR(120) NOT NULL
		 );
GO

-- b) Создайте один AFTER триггер для трех операций 
-- INSERT, UPDATE, DELETE для таблицы Production.ProductCategory. 
-- Триггер должен заполнять таблицу Production.ProductCategoryHst 
-- с указанием типа операции в поле Action 
-- в зависимости от оператора, вызвавшего триггер.
DROP TRIGGER [Production].[TRG_ProductCategoryHst];
GO

CREATE TRIGGER [TRG_ProductCategoryHst] ON [Production].[ProductCategory]
AFTER INSERT
	 ,UPDATE
	 ,DELETE
AS
IF (
	 	 EXISTS (
	 	 	 SELECT 1
	 	 	 FROM INSERTED
	 	 	 )
	 	 )
	 AND (
	 	 EXISTS (
	 	 	 SELECT 1
	 	 	 FROM DELETED
	 	 	 )
	 	 )
BEGIN
	 INSERT INTO [Production].[ProductCategoryHst] (
	 	 [Action]
	 	 ,[ModifiedDate]
	 	 ,[SourceID]
	 	 ,[UserName]
	 	 )
	 SELECT 'UPDATE'
	 	 ,GETDATE()
	 	 ,ProductCategoryID
	 	 ,SYSTEM_USER
	 FROM DELETED
END
ELSE IF (
	 	 EXISTS (
	 	 	 SELECT 1
	 	 	 FROM INSERTED
	 	 	 )
	 	 )
BEGIN
	 INSERT INTO [Production].[ProductCategoryHst] (
	 	 [Action]
	 	 ,[ModifiedDate]
	 	 ,[SourceID]
	 	 ,[UserName]
	 	 )
	 SELECT 'INSERT'
	 	 ,GETDATE()
	 	 ,ProductCategoryID
	 	 ,SYSTEM_USER
	 FROM INSERTED
END
ELSE IF (
	 	 EXISTS (
	 	 	 SELECT 1
	 	 	 FROM DELETED
	 	 	 )
	 	 )
BEGIN
	 INSERT INTO [Production].[ProductCategoryHst] (
	 	 [Action]
	 	 ,[ModifiedDate]
	 	 ,[SourceID]
	 	 ,[UserName]
	 	 )
	 SELECT 'DELETE'
	 	 ,GETDATE()
	 	 ,ProductCategoryID
	 	 ,SYSTEM_USER
	 FROM DELETED
END;
GO

-- c) Создайте представление VIEW, 
-- отображающее все поля таблицы Production.ProductCategory.
DROP VIEW IF EXISTS [Production].[vProductCategory]; 
GO

CREATE VIEW [Production].[vProductCategory]
AS
SELECT *
FROM [Production].[ProductCategory];
GO

SELECT *
FROM [Production].[vProductCategory];

-- d) Вставьте новую строку в Production.ProductCategory 
-- через представление. Обновите вставленную строку. 
-- Удалите вставленную строку. Убедитесь, что все три операции 
-- отображены в Production.ProductCategoryHst.
INSERT INTO [Production].[vProductCategory] (
	 [Name]
	 ,[rowguid]
	 ,[ModifiedDate]
	 )
VALUES (
	 'Cars'
	 ,NEWID()
	 ,GETDATE()
	 )

SELECT *
FROM [Production].[vProductCategory];

UPDATE [Production].[vProductCategory]
SET [Name] = 'Planes'
WHERE [Name] = 'Cars'

SELECT *
FROM [Production].[vProductCategory]

DELETE
FROM [Production].[vProductCategory]
WHERE [Name] = 'Planes'

SELECT *
FROM [Production].[vProductCategory]

SELECT *
FROM [Production].[ProductCategoryHst];