-- a)
-- Создайте scalar-valued функцию, которая будет принимать 
-- в качестве входного параметра имя группы отделов 
-- (HumanResources.Department.GroupName) и возвращать 
-- количество отделов, входящих в эту группу.
DROP FUNCTION
IF EXISTS [HumanResources].[fDepartmentCount] 
GO

CREATE FUNCTION [HumanResources].[fDepartmentCount] (@GroupName NVARCHAR(50))
RETURNS INT
AS
BEGIN
	DECLARE @Count INT

	SELECT @Count = COUNT(DepartmentID)
	FROM [HumanResources].[Department]
	WHERE GroupName = @GroupName

	RETURN @Count
END
GO

SELECT [HumanResources].[fDepartmentCount](N'Research and Development') AS researchAndDevelopmentCount
GO

SELECT [HumanResources].[fDepartmentCount](N'Manufacturing') AS manufacturingCount
GO

-- b)
-- Создайте inline table-valued функцию, которая будет 
-- принимать в качестве входного параметра id отдела 
-- (HumanResources.Department.DepartmentID), а 
-- возвращать 3 самых старших сотрудника,
-- которые начали работать в отделе с 2005 года.
DROP FUNCTION
IF EXISTS [HumanResources].[fGetThreeOldestPerson] 
GO

CREATE FUNCTION [HumanResources].[fGetThreeOldestPerson] (@DepartmentID INT)
RETURNS TABLE
AS
RETURN (
	 	SELECT TOP 3 p.[BusinessEntityID]
	 	 	,p.[PersonType]
	 	 	,p.[NameStyle]
	 	 	,p.[Title]
	 	 	,p.[FirstName]
	 	 	,p.[MiddleName]
	 	 	,p.[LastName]
	 	 	,p.[Suffix]
	 	 	,p.[EmailPromotion]
	 	 	,p.[AdditionalContactInfo]
	 	 	,p.[Demographics]
	 	 	,p.[rowguid]
	 	 	,p.[ModifiedDate]
	 	FROM [Person].[Person] p
	 	JOIN [HumanResources].[EmployeeDepartmentHistory] h
	 	 	ON p.[BusinessEntityID] = h.[BusinessEntityID]
	 	WHERE h.[DepartmentID] = @DepartmentID
	 	 	AND h.[StartDate] >= '2005'
	 	 	AND h.[EndDate] IS NULL
	 	ORDER BY h.[StartDate] ASC
	 	)
GO

SELECT *
FROM [HumanResources].[fGetThreeOldestPerson](3)
GO

-- c)
-- Вызовите функцию для каждого отдела, применив 
-- оператор CROSS APPLY. Вызовите функцию для 
-- каждого отдела, применив оператор OUTER APPLY.
SELECT *
FROM [HumanResources].[Department]
CROSS APPLY [HumanResources].[fGetThreeOldestPerson]([DepartmentID]);

SELECT *
FROM [HumanResources].[Department]
OUTER APPLY [HumanResources].[fGetThreeOldestPerson]([DepartmentID]);
GO

-- d)
-- Измените созданную inline table-valued функцию, 
-- сделав ее multistatement table-valued 
-- (предварительно сохранив для проверки код 
-- создания inline table-valued функции).
DROP FUNCTION
IF EXISTS [HumanResources].[fGetThreeOldestPerson] 
GO

CREATE FUNCTION [HumanResources].[fGetThreeOldestPerson] (@DepartmentID INT)
RETURNS @table TABLE (
	[BusinessEntityID] INT NOT NULL
	,[PersonType] NCHAR(2) NOT NULL
	,[NameStyle] BIT NOT NULL
	,[Title] NVARCHAR(8)
	,[FirstName] NVARCHAR(50) NOT NULL
	,[MiddleName] NVARCHAR(50)
	,[LastName] NVARCHAR(50) NOT NULL
	,[Suffix] NVARCHAR(10)
	,[EmailPromotion] INT NOT NULL
	,[AdditionalContactInfo] XML
	,[Demographics] XML
	,[rowguid] UNIQUEIDENTIFIER NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	)
AS
BEGIN
	INSERT INTO @table
	SELECT TOP 3 p.[BusinessEntityID]
	 	,p.[PersonType]
	 	,p.[NameStyle]
	 	,p.[Title]
	 	,p.[FirstName]
	 	,p.[MiddleName]
	 	,p.[LastName]
	 	,p.[Suffix]
	 	,p.[EmailPromotion]
	 	,p.[AdditionalContactInfo]
	 	,p.[Demographics]
	 	,p.[rowguid]
	 	,p.[ModifiedDate]
	FROM [Person].[Person] p
	JOIN [HumanResources].[EmployeeDepartmentHistory] h
	 	ON p.[BusinessEntityID] = h.[BusinessEntityID]
	WHERE h.[DepartmentID] = @DepartmentID
	 	AND h.[StartDate] >= '2005'
	 	AND h.[EndDate] IS NULL
	ORDER BY h.[StartDate] ASC

	RETURN
END
GO

SELECT *
FROM [HumanResources].[fGetThreeOldestPerson](3);
GO

