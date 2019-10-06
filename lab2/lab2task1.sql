-- 1 
-- Вывести на экран список сотрудников 
-- с указанием максимальной ставки, 
-- по которой им выплачивали денежные средства.

SELECT [emp].[BusinessEntityID]
	,[emp].[JobTitle]
	,MAX([payhist].[Rate]) AS [MaxRate]
FROM [HumanResources].[Employee] [emp]
INNER JOIN [HumanResources].[EmployeePayHistory] [payhist]
	ON [emp].[BusinessEntityID] = [payhist].[BusinessEntityID]
GROUP BY [emp].[BusinessEntityID]
	,[emp].[JobTitle]

-------------------------------------



-- 2
-- Разбить все почасовые ставки на группы таким образом, 
-- чтобы одинаковые ставки входили в одну группу. 
-- Номера групп должны быть распределены по возрастанию ставок. 
-- Назовите столбец [RankRate].

SELECT [emp].[BusinessEntityID]
	,[emp].[JobTitle]
	,[payhist].[Rate]
	,DENSE_RANK() OVER (
		ORDER BY [payhist].[Rate] ASC
		) AS [RankRate]
FROM [HumanResources].[Employee] [emp]
JOIN [HumanResources].[EmployeePayHistory] [payhist]
	ON [emp].[BusinessEntityID] = [payhist].[BusinessEntityID]

------------------------------------------


-- 3
-- Вывести на экран информацию об отделах и 
-- работающих в них сотрудниках, отсортированную по полю ShiftID 
-- в отделе ‘Document Control’ и по полю BusinessEntityID 
-- во всех остальных отделах


SELECT [dept].[Name] AS [DepName]
	,[emp].[BusinessEntityID]
	,[emp].[JobTitle]
	,[edh].[ShiftID]
FROM [HumanResources].[Department] [dept]
JOIN [HumanResources].[EmployeeDepartmentHistory] [edh]
	ON [dept].[DepartmentID] = [edh].[DepartmentID]
JOIN [HumanResources].[Employee] [emp]
	ON [edh].[BusinessEntityID] = [emp].[BusinessEntityID]
WHERE ([edh].[EndDate] IS NULL)
	OR ([edh].[EndDate] > GETDATE())			
ORDER BY [dept].[Name] ASC
	,CASE 
		WHEN [dept].[Name] = N'Document Control'
			THEN [edh].[ShiftID]
		ELSE [emp].[BusinessEntityID]
		END ASC


