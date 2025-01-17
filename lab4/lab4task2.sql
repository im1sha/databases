-- a) Создайте представление VIEW, отображающее данные 
-- из таблиц Production.ProductCategory и 
-- Production.ProductSubcategory. Сделайте невозможным 
-- просмотр исходного кода представления. Создайте 
-- уникальный кластерный индекс в представлении по 
-- полям ProductCategoryID, ProductSubcategoryID.
DROP VIEW
IF EXISTS [Production].[vCategory];
GO

CREATE VIEW [Production].[vCategory] (
	[ProductCategoryID]
	,[CategoryName]
	,[ProductSubcategoryID]
	,[SubcategoryName]
	)
	WITH ENCRYPTION
	 	,SCHEMABINDING
AS
SELECT ct.[ProductCategoryID]
	,ct.[Name]
	,subct.[ProductSubcategoryID]
	,subct.[Name]
FROM [Production].[ProductCategory] AS ct
JOIN [Production].[ProductSubcategory] AS subct
	ON (ct.[ProductCategoryID] = subct.[ProductCategoryID])
GO

CREATE UNIQUE CLUSTERED INDEX IX_vCategory ON [Production].[vCategory] (
	 [ProductCategoryID]
	 ,[ProductSubcategoryID]
	 );
GO

-- b) Создайте три INSTEAD OF триггера для представления 
-- на операции INSERT, UPDATE, DELETE. Каждый триггер 
-- должен выполнять СООТВЕТСТВУЮЩИЕ операции в таблицах 
-- Production.ProductCategory и Production.ProductSubcategory.
DROP TRIGGER
IF EXISTS [Production].[TRG_vCategoryUpdate];
GO

CREATE TRIGGER [Production].[TRG_vCategoryUpdate] ON [Production].[vCategory]
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @date DATETIME = GETDATE();

	UPDATE [Production].[ProductCategory]
	SET [Name] = ins.[CategoryName]
	 	,[ModifiedDate] = @date
	FROM INSERTED AS ins
	WHERE ins.[ProductCategoryID] = [Production].[ProductCategory].[ProductCategoryID];

	UPDATE [Production].[ProductSubcategory]
	SET [Name] = ins.[SubcategoryName]
	 	,[ModifiedDate] = @date
	FROM INSERTED AS ins
	WHERE ins.[ProductSubCategoryID] = [Production].[ProductSubcategory].[ProductSubcategoryID];

END
GO

DROP TRIGGER
IF EXISTS [Production].[TRG_vCategoryDelete];
GO

CREATE TRIGGER [Production].[TRG_vCategoryDelete] ON [Production].[vCategory]
INSTEAD OF DELETE
AS
BEGIN
	DELETE
	FROM [Production].[ProductSubcategory]
	WHERE [ProductSubcategoryID] IN (
	 	 	SELECT [ProductSubCategoryID]
	 	 	FROM DELETED
	 	 	);

	DELETE
	FROM [Production].[ProductCategory]
	WHERE [ProductCategoryID] IN (
	 	 	SELECT [ProductCategoryID]
	 	 	FROM DELETED
	 	 	)
	 	AND [ProductCategoryID] NOT IN (
	 	 	SELECT [ProductCategoryID]
	 	 	FROM [Production].[ProductSubcategory]
	 	 	);
END;
GO

DROP TRIGGER
IF EXISTS [Production].[TRG_vCategoryInsert];
GO

CREATE TRIGGER [Production].[TRG_vCategoryInsert] ON [Production].[vCategory]
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @date DATETIME = GETDATE()

	INSERT INTO [Production].[ProductCategory] (
		 [Name]
		 ,[ModifiedDate]
		 ,[rowguid]
		 )
	SELECT [CategoryName]
		 ,@date
		 ,NEWID()
	FROM INSERTED ins
	WHERE ins.[CategoryName] NOT IN (
	 		 SELECT [Name]
	 		 FROM [Production].[ProductCategory]
	 		 )
	GROUP BY [CategoryName]

	--
	INSERT INTO [Production].[ProductSubcategory] (
		 [ProductCategoryID]
		 ,[Name]
		 ,[ModifiedDate]
		 ,[rowguid]
		 )
	SELECT (
	 		 SELECT TOP 1 [ProductCategoryID]
	 		 FROM [ProductCategory]
	 		 WHERE [ProductCategoryID] = (
	 	 	 		 SELECT TOP 1 [ProductCategoryID]
	 	 	 		 FROM [Production].[ProductCategory] ct
	 	 	 		 WHERE ct.[Name] = INSERTED.[CategoryName]
	 	 	 		 )
	 		 )
		 ,[SubcategoryName]
		 ,@date
		 ,NEWID()
	FROM INSERTED
END
GO

-- c) Вставьте новую строку в представление, 
-- указав новые данные для ProductCategory и ProductSubcategory.
-- Триггер должен добавить новые строки в таблицы 
-- Production.ProductCategory и Production.ProductSubcategory. 
-- Обновите вставленные строки через представление. 
-- Удалите строки.
DECLARE @cat NVARCHAR(50) = N'qwerty1';
DECLARE @subc NVARCHAR(50) = N'qwerty2';
DECLARE @newCat NVARCHAR(50) = N'string1';
DECLARE @newSubc NVARCHAR(50) = N'string2';

INSERT INTO [Production].[vCategory] (
	 [CategoryName]
	 ,[SubcategoryName]
	 )
VALUES
	 (@cat
	 ,@subc
	 )	 
	 ,
	 (@cat
	 ,@newSubc
	 )
	 ,
	 (@subc
	 ,@cat
	 )	 
	 ,
	 (@cat
	 ,@newCat
	 )	 
	 ,
	 (N'Components'
	 ,N'Brakes22'
	 )

SELECT *
FROM [Production].[ProductCategory]

SELECT *
FROM [Production].[ProductSubcategory]

--UPDATE [Production].[vCategory]
--SET [SubcategoryName] = @newSubc
--	 ,[CategoryName] = @newCat
--WHERE [CategoryName] = @cat
--	 AND [SubcategoryName] = @subc

--SELECT *
--FROM [Production].[ProductCategory]

--SELECT *
--FROM [Production].[ProductSubcategory]

--DELETE [Production].[vCategory]
--WHERE ([SubcategoryName] = @newSubc)
--GO

--SELECT *
--FROM [Production].[ProductCategory]

--SELECT *
--FROM [Production].[ProductSubcategory]