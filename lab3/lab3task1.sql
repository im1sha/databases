-- a) добавьте в таблицу dbo.Person поле FullName
-- типа nvarchar размерностью 100 символов;
IF (
		EXISTS (
			SELECT 1
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = N'Person'
				AND COLUMN_NAME = N'FullName'
				AND TABLE_SCHEMA = N'dbo'
			)
		)
BEGIN
	ALTER TABLE [dbo].[Person]

	DROP COLUMN [FullName];
END

ALTER TABLE [dbo].[Person] ADD [FullName] NVARCHAR(100);
GO

--------------------------------------------------
-- b) объявите табличную переменную с такой же 
-- структурой как dbo.Person и заполните ее данными 
-- из dbo.Person. Поле Title заполните 
-- на основании данных из поля Gender таблицы 
-- HumanResources.Employee, если gender=M 
-- тогда Title=’Mr.’, если gender=F тогда Title=’Ms.’;
DECLARE @Person TABLE (
	[BusinessEntityID] INT NOT NULL
	,[PersonType] NVARCHAR(2) NOT NULL
	,[NameStyle] NameStyle NOT NULL
	,[FirstName] Name NOT NULL
	,[MiddleName] Name NULL
	,[LastName] Name NOT NULL
	,[Suffix] NVARCHAR(5) NULL
	,[EmailPromotion] INT NOT NULL
	,[ModifiedDate] DATETIME NOT NULL
	,[ID] BIGINT PRIMARY KEY
	,[FullName] NVARCHAR(100)
	,[Title] NVARCHAR(8) NULL
	);

INSERT INTO @Person
SELECT per.[BusinessEntityID]
	,per.[PersonType]
	,per.[NameStyle]
	,per.[FirstName]
	,per.[MiddleName]
	,per.[LastName]
	,per.[Suffix]
	,per.[EmailPromotion]
	,per.[ModifiedDate]
	,per.[ID]
	,per.[FullName]
	,CASE 
		WHEN emp.[Gender] = N'M'
			THEN N'Mr.'
		ELSE N'Ms.'
		END AS [Title]
FROM [dbo].[Person] per
JOIN [HumanResources].[Employee] emp
	ON per.[BusinessEntityID] = emp.[BusinessEntityID]

--SELECT * FROM @Person;
--SELECT * FROM [HumanResources].[Employee];
--------------------------------------------------
-- c) обновите поле FullName в dbo.Person данными 
-- из табличной переменной, объединив информацию 
-- из полей Title, FirstName, LastName 
-- (например ‘Mr. Jossef Goldberg’);
UPDATE [dbo].[Person]
SET [dbo].[Person].[FullName] = variable.[Title] + ' ' + variable.[FirstName] + ' ' + variable.[LastName]
FROM [dbo].[Person] tbl
INNER JOIN @Person variable
	ON tbl.[ID] = variable.[ID]

GO
--SELECT * FROM @Person;
--SELECT * FROM [dbo].[Person];
--------------------------------------------------
-- d) удалите данные из dbo.Person, 
-- где количество символов в поле FullName
-- превысило 20 символов;
SELECT COUNT(*)
FROM [dbo].[Person];

DELETE
FROM [dbo].[Person]
WHERE LEN([FullName]) > 20
GO

SELECT COUNT(*)
FROM [dbo].[Person];

--------------------------------------------------
-- e) удалите все созданные ограничения 
-- и значения по умолчанию. После этого, удалите поле ID.
-- Имена ограничений вы можете найти в метаданных. Например:
ALTER TABLE
    [dbo].[Person]
DROP CONSTRAINT
    [PK_PersonId]
    ,[CK_Title]
    ,[DF_Suffix]
GO

ALTER TABLE [dbo].[Person]
DROP COLUMN [ID]
GO

--------------------------------------------------
-- f) удалите таблицу dbo.Person.
DROP TABLE [dbo].[Person]