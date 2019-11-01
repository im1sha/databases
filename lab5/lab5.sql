-- a)
-- Создайте scalar-valued функцию, которая будет принимать 
-- в качестве входного параметра имя группы отделов 
-- (HumanResources.Department.GroupName) и возвращать 
-- количество отделов, входящих в эту группу.

DROP FUNCTION 
IF EXISTS [HumanResources].[fDepartmentCount]
GO

CREATE FUNCTION [HumanResources].[fDepartmentCount] (@GroupName NVARCHAR(50))
RETURNS INT AS
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

CREATE FUNCTION [HumanResources].[fGetThreeOldestPerson](@DepartmentID INT)
RETURNS TABLE AS
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
	ORDER BY h.[StartDate] DESC
)
GO

SELECT * 
FROM [HumanResources].[fGetThreeOldestPerson](3)
GO

-- c)
-- Вызовите функцию для каждого отдела, применив 
-- оператор CROSS APPLY. Вызовите функцию для 
-- каждого отдела, применив оператор OUTER APPLY.

-- d)
-- Измените созданную inline table-valued функцию, 
-- сделав ее multistatement table-valued 
-- (предварительно сохранив для проверки код 
-- создания inline table-valued функции).

