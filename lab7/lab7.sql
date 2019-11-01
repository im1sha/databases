IF OBJECT_ID('tempdb..#Employees') IS NOT NULL
BEGIN
	 DROP TABLE #Employees
END
GO
-- Вывести значения полей [BusinessEntityID], [NationalIDNumber] 
-- и [JobTitle] из таблицы [HumanResources].[Employee] 
-- в виде xml, сохраненного в переменную. 
DECLARE @xmlVar XML;

SET @xmlVar = (
	 	 SELECT [BusinessEntityID] AS '@ID'
	 	 	 ,[NationalIDNumber] AS 'NationalIDNumber'
	 	 	 ,[JobTitle] AS 'JobTitle'
	 	 FROM [HumanResources].[Employee]
	 	 FOR XML PATH('Employee')
	 	 	 ,ROOT('Employees')
	 	 )

SELECT @xmlVar

-- Создать временную таблицу и заполнить её данными из переменной, 
-- содержащей xml.
CREATE TABLE #Employees (
	 [BusinessEntityID] INT NOT NULL
	 ,[NationalIDNumber] NVARCHAR(15) NOT NULL
	 ,[JobTitle] NVARCHAR(50) NOT NULL
	 )

INSERT INTO #Employees (
	 [BusinessEntityID]
	 ,[NationalIDNumber]
	 ,[JobTitle]
	 )
SELECT [BusinessEntityID] = node.value('@ID', 'INT')
	 ,[NationalIDNumber] = node.value('NationalIDNumber[1]', 'NVARCHAR(15)')
	 ,[JobTitle] = node.value('JobTitle[1]', 'NVARCHAR(50)')
FROM @xmlVar.nodes('/Employees/Employee') AS XML(node)

SELECT *
FROM #Employees
