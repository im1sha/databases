-- a) Создайте представление VIEW, отображающее данные 
-- из таблиц Production.ProductCategory и 
-- Production.ProductSubcategory. Сделайте невозможным 
-- просмотр исходного кода представления. Создайте 
-- уникальный кластерный индекс в представлении по 
-- полям ProductCategoryID, ProductSubcategoryID.

-- b) Создайте три INSTEAD OF триггера для представления 
-- на операции INSERT, UPDATE, DELETE. Каждый триггер 
-- должен выполнять соответствующие операции в таблицах 
-- Production.ProductCategory и Production.ProductSubcategory.

-- c) Вставьте новую строку в представление, 
-- указав новые данные для ProductCategory и ProductSubcategory.
-- Триггер должен добавить новые строки в таблицы 
-- Production.ProductCategory и Production.ProductSubcategory. 
-- Обновите вставленные строки через представление. 
-- Удалите строки.

