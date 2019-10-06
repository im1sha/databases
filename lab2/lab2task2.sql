-- a) 
-- создайте таблицу dbo.Person с такой же структурой 
-- как Person.Person, кроме полей xml, uniqueidentifier, 
-- не включая индексы, ограничения и триггеры;
IF OBJECT_ID('[dbo].[Person]', 'U') IS NOT NULL
	DROP TABLE [dbo].[Person];

CREATE TABLE [dbo].[Person] (
	[BusinessEntityID] INT NOT NULL
	,[PersonType] NVARCHAR(2) NOT NULL
	,[NameStyle] NameStyle NOT NULL
	,[Title] NVARCHAR(8) NULL
	,[FirstName] Name NOT NULL
	,[MiddleName] Name NULL
	,[LastName] Name NOT NULL
	,[Suffix] NVARCHAR(10) NULL
	,[EmailPromotion] INT NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	);

------------------------------------------------
-- b) 
-- используя инструкцию ALTER TABLE, 
-- добавьте в таблицу dbo.Person новое поле ID, 
-- которое является первичным ключом типа bigint и 
-- имеет свойство identity.
-- Начальное значение для поля identity задайте 10 и 
-- приращение задайте 10;
ALTER TABLE [dbo].[Person] ADD [ID] BIGINT IDENTITY (
	10
	,10
	) PRIMARY KEY;

-------------------------------------------------
-- c) используя инструкцию ALTER TABLE, 
-- создайте для таблицы dbo.Person ограничение для поля Title, 
-- чтобы заполнить его можно было только значениями 'Mr.' или 'Ms.';
ALTER TABLE [dbo].[Person] ADD CONSTRAINT [CK_Title] CHECK (
	[Title] IN (
		'Mr.'
		,'Ms.'
		)
	);

-------------------------------------------------
-- d) 
-- используя инструкцию ALTER TABLE, 
-- создайте для таблицы dbo.Person ограничение DEFAULT 
-- для поля Suffix, задайте значение по умолчанию 'N/A';
ALTER TABLE [dbo].[Person] ADD CONSTRAINT [DF_Suffix] DEFAULT N'N/A'
FOR [Suffix];

-------------------------------------------------
-- e) заполните новую таблицу данными из Person.Person 
-- только для тех сотрудников, которые существуют 
-- в таблице HumanResources.Employee, 
-- исключив сотрудников из отдела 'Executive';
INSERT INTO [dbo].[Person] (
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
FROM [HumanResources].[Employee] [emp]
JOIN [HumanResources].[EmployeeDepartmentHistory] [hist]
	ON [emp].[BusinessEntityID] = [hist].[BusinessEntityID]
JOIN [HumanResources].[Department] [dept]
	ON [hist].[DepartmentID] = [dept].[DepartmentID]
JOIN [Person].[Person] [person]
	ON ([emp].[BusinessEntityID] = [person].[BusinessEntityID])
		AND ([dept].[Name] != N'Executive')
		AND (
			([hist].[EndDate] IS NULL)
			OR ([hist].[EndDate] > GETDATE())
			);

--SELECT * FROM [HumanResources].[Department] WHERE [Name]=N'Executive';
-------------------------------------------------
-- f) 
-- измените размерность поля Suffix, 
-- уменьшите размер поля до 5-ти символов.
ALTER TABLE [dbo].[Person]

ALTER COLUMN [Suffix] NVARCHAR(5) NULL;

SELECT *
FROM [dbo].[Person];