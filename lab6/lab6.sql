-- Создайте хранимую процедуру, 
-- которая будет возвращать сводную таблицу (оператор PIVOT), 
-- отображающую данные о суммарном количестве проданных продуктов 
-- (Sales.SalesOrderDetail.OrderQty) за определенный год 
-- (Sales.SalesOrderHeader.OrderDate). 
-- 
-- Список лет передайте в процедуру через входной параметр.

DROP PROCEDURE
IF EXISTS [dbo].[pOrdersByYearList]
GO

CREATE PROCEDURE [dbo].[pOrdersByYearList] (@Years NVARCHAR(100))
AS
BEGIN
	 DECLARE @query AS NVARCHAR(500)

	 SET @query =  'SELECT [Name]
							,' + @Years + '
					FROM (
							SELECT [Name]
	 							,YEAR([OrderDate]) AS y
	 							,[OrderQty]
							FROM [Sales].[SalesOrderHeader]
							JOIN [Sales].[SalesOrderDetail]
	 							ON [SalesOrderDetail].[SalesOrderID] = [SalesOrderHeader].[SalesOrderID]
							JOIN [Production].[Product]
	 							ON [Product].[ProductID] = [SalesOrderDetail].[ProductID]
							) AS selected
					PIVOT(SUM([OrderQty]) FOR y IN (' + @Years + ')) AS pvt'

	 EXEC (@query)
END
GO

EXECUTE [dbo].[pOrdersByYearList] '[2008], [2007], [2006]'
GO