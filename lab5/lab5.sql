-- a)
-- Создайте scalar-valued функцию, которая будет принимать 
-- в качестве входного параметра имя группы отделов 
-- (HumanResources.Department.GroupName) и возвращать 
-- количество отделов, входящих в эту группу.

-- b)
-- Создайте inline table-valued функцию, которая будет 
-- принимать в качестве входного параметра id отдела 
-- (HumanResources.Department.DepartmentID), а 
-- возвращать 3 самых старших сотрудника,
-- которые начали работать в отделе с 2005 года.

-- c)
-- Вызовите функцию для каждого отдела, применив 
-- оператор CROSS APPLY. Вызовите функцию для 
-- каждого отдела, применив оператор OUTER APPLY.

-- d)
-- Измените созданную inline table-valued функцию, 
-- сделав ее multistatement table-valued 
-- (предварительно сохранив для проверки код 
-- создания inline table-valued функции).

