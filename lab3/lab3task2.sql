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
WITH CTE
AS (
	SELECT poh.[EmployeeID]
		,SUM(poh.[SubTotal]) AS [SumSubTotal]
	FROM [Purchasing].[PurchaseOrderHeader] poh
	GROUP BY poh.[EmployeeID]
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
SELECT [person].[BusinessEntityID]
	,[person].[PersonType]
	,[person].[NameStyle]
	,[person].[Title]
	,[person].[FirstName]
	,[person].[MiddleName]
	,[person].[LastName]
	,[person].[Suffix]
	,[person].[EmailPromotion]
	,[person].[ModifiedDate]
	,[sales].[SalesYTD]
	,[sales].[SalesLastYear]
	,[person].[OrdersNum]
FROM [dbo].[Person] [person]
LEFT JOIN [Sales].[SalesPerson] [sales]
	ON [person].[BusinessEntityID] = [sales].[BusinessEntityID]
LEFT JOIN CTE_Calc_Sum cte
	ON [person].[BusinessEntityID] = cte.[Bus];

------------------------------------------------------------------
-- d) 
-- удалите из таблицы dbo.Person одну строку
-- (где BusinessEntityID = 290)
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