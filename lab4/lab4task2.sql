-- a) Создайте представление VIEW, отображающее данные 
-- из таблиц Production.ProductCategory и 
-- Production.ProductSubcategory. Сделайте невозможным 
-- просмотр исходного кода представления. Создайте 
-- уникальный кластерный индекс в представлении по 
-- полям ProductCategoryID, ProductSubcategoryID.
DROP VIEW IF EXISTS [Production].[vCategory]; 
GO

CREATE VIEW [Production].[vCategory]
WITH ENCRYPTION, SCHEMABINDING AS
SELECT 
    ct.[ProductCategoryID] AS [ProductCategoryID]
	, ct.[Name] AS [CategoryName]
	, subct.[ProductSubcategoryID] AS [ProductSubcategoryID]
	, subct.[Name] AS [SubcategoryName]
FROM [Production].[ProductCategory] AS ct
JOIN [Production].[ProductSubcategory] AS subct
    ON (ct.[ProductCategoryID] = subct.[ProductSubcategoryID])
GO

CREATE UNIQUE CLUSTERED INDEX IX_vCategory
	ON [Production].[vCategory] ([ProductCategoryID], [ProductSubcategoryID]);
GO


-- b) Создайте три INSTEAD OF триггера для представления 
-- на операции INSERT, UPDATE, DELETE. Каждый триггер 
-- должен выполнять СООТВЕТСТВУЮЩИЕ операции в таблицах 
-- Production.ProductCategory и Production.ProductSubcategory.
DROP TRIGGER IF EXISTS [Production].[TRG_vCategoryUpdate];
GO

CREATE TRIGGER TRG_vCategoryUpdate
ON [Production].[vCategory]
INSTEAD OF UPDATE
AS
IF EXISTS(SELECT 1 FROM INSERTED) AND EXISTS (SELECT 1 FROM DELETED)
BEGIN
	PRINT 'UPDATE CALLED'
	DECLARE @date DATETIME = GETDATE();

    UPDATE [Production].[ProductSubcategory]
    SET 
    [Name] = ins.[SubcategoryName],
    ModifiedDate = @date
    FROM INSERTED ins
	
	UPDATE [Production].[ProductCategory]
    SET 
    [Name] = ins.[CategoryName],
    ModifiedDate = @date
    FROM INSERTED ins
END
 
DROP TRIGGER IF EXISTS [Production].[TRG_vCategoryDelete];
GO

CREATE TRIGGER TRG_vCategoryDelete
ON [Production].[vCategory]
INSTEAD OF DELETE
AS
IF NOT EXISTS(SELECT 1 FROM INSERTED) AND EXISTS (SELECT 1 FROM DELETED)
BEGIN
    DELETE FROM [Production].[ProductSubcategory]
	WHERE [ProductSubcategoryID] IN (SELECT [ProductSubcategoryID] FROM DELETED)

	DELETE FROM [Production].[ProductCategory]
	WHERE [ProductCategoryID] IN (SELECT [ProductCategoryID] FROM DELETED)
END

DROP TRIGGER IF EXISTS [Production].[TRG_vCategoryInsert];
GO

CREATE TRIGGER TRG_vCategoryInsert
ON [Production].[vCategory]
INSTEAD OF INSERT
AS
IF EXISTS(SELECT 1 FROM INSERTED) AND NOT EXISTS (SELECT 1 FROM DELETED)
BEGIN
	DECLARE @date DATETIME = GETDATE();

	INSERT INTO [Production].[ProductCategory] ([Name], [ModifiedDate], [rowguid])
    SELECT [CategoryName], @date, NEWID()
    FROM INSERTED
    
    INSERT INTO [Production].[ProductSubcategory] ([ProductCategoryID], [Name], [ModifiedDate], [rowguid])
    SELECT @@IDENTITY, [SubcategoryName], @date, NEWID()
    FROM INSERTED;
END
GO

   
-- c) Вставьте новую строку в представление, 
-- указав новые данные для ProductCategory и ProductSubcategory.
-- Триггер должен добавить новые строки в таблицы 
-- Production.ProductCategory и Production.ProductSubcategory. 
-- Обновите вставленные строки через представление. 
-- Удалите строки.

DECLARE @cat NVARCHAR(50) = CONVERT(NVARCHAR(50), SYSDATETIME());
DECLARE @subc NVARCHAR(50) = CONVERT(NVARCHAR(50), SYSDATETIME());

INSERT INTO [Production].[vCategory]( 
    [CategoryName]
,	[SubcategoryName]) 
VALUES
(
	@cat,
	@subc
)

SELECT * FROM [Production].[ProductCategory] 
SELECT * FROM [Production].[ProductSubcategory]

UPDATE [Production].[vCategory]
SET [CategoryName] = N'1',
	[SubcategoryName] = N'2'
WHERE [CategoryName] = @cat AND [SubcategoryName] = @subc


SELECT * FROM [Production].[ProductCategory] 
SELECT * FROM [Production].[ProductSubcategory]

DELETE FROM [Production].[ProductSubcategory]  WHERE [ProductSubcategoryID] > 37 
DELETE FROM [Production].[ProductCategory]  WHERE [ProductCategoryID] > 4 

SELECT * FROM [Production].[ProductCategory] 
SELECT * FROM [Production].[ProductSubcategory]


