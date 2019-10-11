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
	, ct.[rowguid] AS [CategoryRowGuid]
	, ct.[ModifiedDate] AS [CategoryModifiedDate]
	, subct.[ProductSubcategoryID] AS [ProductSubcategoryID]
	, subct.[Name] AS [SubcategoryName]
	, subct.[rowguid] AS [SubcategoryRowGuid]
	, subct.[ModifiedDate] AS [SubcategoryModifiedDate]
FROM [Production].[ProductCategory] AS ct
JOIN [Production].[ProductSubcategory] AS subct
    ON (ct.[ProductCategoryID] = subct.[ProductSubcategoryID])
GO

CREATE UNIQUE CLUSTERED INDEX IX_vCategory
	ON [Production].[vCategory] ([ProductCategoryID], [ProductSubcategoryID]);
GO


-- b) Создайте три INSTEAD OF триггера для представления 
-- на операции INSERT, UPDATE, DELETE. Каждый триггер 
-- должен выполнять соответствующие операции в таблицах 
-- Production.ProductCategory и Production.ProductSubcategory.
DROP TRIGGER IF EXISTS [Production].[TRG_vCategoryUpdate];
GO

CREATE TRIGGER TRG_vCategoryUpdate
ON [Production].[vCategory]
INSTEAD OF UPDATE
AS
IF EXISTS(SELECT 1 FROM INSERTED) AND EXISTS (SELECT 1 FROM DELETED)
BEGIN
	DECLARE @date DATETIME = GETDATE();

    UPDATE [Production].[ProductSubcategory]
    SET 
    [Name] = ins.[SubcategoryName],
    [rowguid] = ins.[SubcategoryRowGuid],
    ModifiedDate = @date
    FROM INSERTED ins
	
	--DECLARE @insCategoryName Name = ins.[CategoryName];

	--IF NOT EXISTS (SELECT 1 FROM [Production].[ProductCategory] WHERE )
	--BEGIN
	--	UPDATE [Production].[ProductCategory]
	--	SET 
	--	[Name] = ins.[CategoryName],
	--	[rowguid] = ins.[CategoryRowGuid],
	--	ModifiedDate = @date
	--	FROM INSERTED ins
	--END
END

DROP TRIGGER IF EXISTS [Production].[TRG_vCategoryDelete];
GO

CREATE TRIGGER TRG_vCategoryDelete
ON [Production].[vCategory]
INSTEAD OF DELETE
AS
IF NOT EXISTS(SELECT 1 FROM INSERTED) AND EXISTS (SELECT 1 FROM DELETED)
BEGIN
	DELETE FROM [Production].[ProductCategory]
	WHERE [ProductCategoryID] IN (SELECT [ProductCategoryID] FROM DELETED)

    DELETE FROM [Production].[ProductSubcategory]
	WHERE [ProductSubcategoryID] IN (SELECT [ProductSubcategoryID] FROM DELETED)
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
    SELECT Name, ReasonType, GETDATE()
    FROM inserted
    
    INSERT INTO Sales.SalesOrderHeaderSalesReason (SalesOrderId, SalesReasonID, ModifiedDate)
    SELECT I.SalesOrderID, I.SalesReasonID, GETDATE()
    FROM inserted I;
END


    

-- c) Вставьте новую строку в представление, 
-- указав новые данные для ProductCategory и ProductSubcategory.
-- Триггер должен добавить новые строки в таблицы 
-- Production.ProductCategory и Production.ProductSubcategory. 
-- Обновите вставленные строки через представление. 
-- Удалите строки.

