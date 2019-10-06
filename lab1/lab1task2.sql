USE AdventureWorks2012;
GO

SELECT [BusinessEntityID]
	,[JobTitle]
	,[Gender]
	,[HireDate]
FROM [HumanResources].[Employee]
WHERE [JobTitle] IN (
		'Accounts Manager'
		,'Benefits Specialist'
		,'Engineering Manager'
		,'Finance Manager'
		,'Maintenance Supervisor'
		,'Master Scheduler'
		,'Network Manager'
		);

SELECT COUNT(*) AS [EmpCount]
FROM [HumanResources].[Employee]
WHERE [HireDate] >= '2004';

SELECT TOP (5) [BusinessEntityID]
	,[JobTitle]
	,[MaritalStatus]
	,[Gender]
	,[BirthDate]
	,[HireDate]
FROM [HumanResources].[Employee]
WHERE ([MaritalStatus] = 'M')
	AND ([HireDate] >= '2004')
	AND ([HireDate] < '2005');