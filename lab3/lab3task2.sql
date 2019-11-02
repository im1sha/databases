-- a) 
-- выполните код, созданный во втором задании 
-- второй лабораторной работы. 
-- Добавьте в таблицу 
-- dbo.Person поля SalesYTD MONEY, SalesLastYear MONEY и 
-- OrdersNum INT. Также создайте в таблице 
-- вычисляемое поле SalesDiff, 
-- считающее разницу значений в полях SalesYTD и SalesLastYear.
ALTER TABLE [dbo].[Person] ADD [SalesYTD] MONEY NULL
	 ,[SalesLastYear] MONEY NULL
	 ,[OrdersNum] INT NULL
	 ,[SalesDiff] AS ([SalesYTD] - [SalesLastYear]);
GO

CREATE NONCLUSTERED INDEX [IX_SalesDiff]
ON [dbo].[Person] ([SalesDiff])
GO
------------------------------------------------------------------
-- b) 
-- создайте временную таблицу #Person, 
-- с первичным ключом по полю BusinessEntityID. 
-- Временная таблица должна включать все поля 
-- таблицы dbo.Person за исключением поля SalesDiff.
IF OBJECT_ID('tempdb..#Person') IS NOT NULL
BEGIN
	 DROP TABLE #Person;

	 PRINT 'DROP';
END
GO

CREATE TABLE #Person (
	 [BusinessEntityID] INT NOT NULL PRIMARY KEY
	 ,[PersonType] NVARCHAR(2) NOT NULL
	 ,[NameStyle] BIT NOT NULL
	 ,[Title] NVARCHAR(8) NULL
	 ,[FirstName] NVARCHAR(50) NOT NULL
	 ,[MiddleName] NVARCHAR(50) NULL
	 ,[LastName] NVARCHAR(50) NOT NULL
	 ,[Suffix] NVARCHAR(5) NULL
	 ,[EmailPromotion] INT NOT NULL
	 ,[ModifiedDate] DATETIME NOT NULL
	 ,[SalesYTD] MONEY NULL
	 ,[SalesLastYear] MONEY NULL
	 ,[OrdersNum] INT NULL
	 );
GO

------------------------------------------------------------------
-- c)
-- заполните временную таблицу данными из dbo.Person. 
-- Поля SalesYTD и SalesLastYear заполните значениями 
-- из таблицы Sales.SalesPerson. Посчитайте количество заказов,
-- оформленных каждым продавцом (SalesPersonID) в таблице 
-- Sales.SalesOrderHeader и заполните этими значениями поле
-- OrdersNum. Подсчет количества заказов осуществите 
-- в Common Table Expression (CTE).
WITH CteOrdersNum
AS (
	 SELECT COUNT(*) AS [OrdersNum]
	 	 ,[SalesPersonID]
	 FROM [Sales].[SalesOrderHeader] soh
	 GROUP BY soh.[SalesPersonID]
	 )
INSERT INTO #Person (
	 [BusinessEntityID]
	 ,[PersonType]
	 ,[NameStyle]
	 ,[Title]
	 ,[FirstName]
	 ,[MiddleName]
	 ,[LastName]
	 ,[Suffix]
	 ,[EmailPromotion]
	 ,[ModifiedDate]
	 ,[SalesYTD]
	 ,[SalesLastYear]
	 ,[OrdersNum]
	 )
SELECT prs.[BusinessEntityID]
	 ,prs.[PersonType]
	 ,prs.[NameStyle]
	 ,prs.[Title]
	 ,prs.[FirstName]
	 ,prs.[MiddleName]
	 ,prs.[LastName]
	 ,prs.[Suffix]
	 ,prs.[EmailPromotion]
	 ,prs.[ModifiedDate]
	 ,sls.[SalesYTD]
	 ,sls.[SalesLastYear]
	 ,cte.[OrdersNum]
FROM [dbo].[Person] prs
LEFT JOIN [Sales].[SalesPerson] sls
	 ON prs.[BusinessEntityID] = sls.[BusinessEntityID]
LEFT JOIN CteOrdersNum cte
	 ON prs.[BusinessEntityID] = cte.[SalesPersonID];

--SELECT *
--FROM #Person
--WHERE [PersonType] = N'SP';

------------------------------------------------------------------
-- d) 
-- удалите из таблицы dbo.Person одну строку
-- (где BusinessEntityID = 290)
DELETE
FROM [dbo].[Person]
WHERE [BusinessEntityID] = 290;


--SELECT COUNT(*) FROM [dbo].[Person] WHERE [BusinessEntityID] = 290;

------------------------------------------------------------------
-- e)
-- напишите Merge выражение, использующее 
-- dbo.Person как target, а временную таблицу 
-- как source. Для связи target и source используйте 
-- BusinessEntityID. Обновите поля SalesYTD, 
-- SalesLastYear и OrdersNum таблицы dbo.Person, 
-- если запись присутствует и в source и в target. 
-- Если строка присутствует во временной таблице, 
-- но не существует в target, добавьте строку в dbo.Person. 
-- Если в dbo.Person присутствует такая строка, 
-- которой не существует во временной таблице, 
-- удалите строку из dbo.Person.

--SELECT COUNT(*) FROM #Person
--SELECT COUNT(*) FROM [dbo].[Person]

MERGE [dbo].[Person] AS trg
USING #Person AS src
	 ON (trg.[BusinessEntityID] = src.[BusinessEntityID])
WHEN MATCHED
	 THEN
	 	 UPDATE
	 	 SET trg.[SalesYTD] = src.[SalesYTD]
	 	 	 ,trg.[SalesLastYear] = src.[SalesLastYear]
	 	 	 ,trg.[OrdersNum] = src.[OrdersNum]
WHEN NOT MATCHED BY TARGET
	 THEN
	 	 INSERT (
	 	 	 [BusinessEntityID]
	 	 	 ,[PersonType]
	 	 	 ,[NameStyle]
	 	 	 ,[Title]
	 	 	 ,[FirstName]
	 	 	 ,[MiddleName]
	 	 	 ,[LastName]
	 	 	 ,[Suffix]
	 	 	 ,[EmailPromotion]
	 	 	 ,[ModifiedDate]
	 	 	 ,[SalesYTD]
	 	 	 ,[SalesLastYear]
	 	 	 ,[OrdersNum]
	 	 	 )
	 	 VALUES (
	 	 	 src.[BusinessEntityID]
	 	 	 ,src.[PersonType]
	 	 	 ,src.[NameStyle]
	 	 	 ,src.[Title]
	 	 	 ,src.[FirstName]
	 	 	 ,src.[MiddleName]
	 	 	 ,src.[LastName]
	 	 	 ,src.[Suffix]
	 	 	 ,src.[EmailPromotion]
	 	 	 ,src.[ModifiedDate]
	 	 	 ,src.[SalesYTD]
	 	 	 ,src.[SalesLastYear]
	 	 	 ,src.[OrdersNum]
	 	 	 )
WHEN NOT MATCHED BY SOURCE
	 THEN
	 	 DELETE;

--SELECT COUNT(*) FROM #Person
--SELECT COUNT(*) FROM [dbo].[Person]