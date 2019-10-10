-- a) Создайте таблицу Production.ProductCategoryHst, 
-- которая будет хранить информацию об изменениях 
-- в таблице Production.ProductCategory.
-- 
-- Обязательные поля, которые должны присутствовать в таблице: 
-- ID — первичный ключ IDENTITY(1,1); 
-- Action — совершенное действие (insert, update или delete); 
-- ModifiedDate — дата и время, когда была совершена операция; 
-- SourceID — первичный ключ исходной таблицы; 
-- UserName — имя пользователя, совершившего операцию. 
-- Создайте другие поля, если считаете их нужными.

-- b) Создайте один AFTER триггер для трех операций 
-- INSERT, UPDATE, DELETE для таблицы Production.ProductCategory. 
-- Триггер должен заполнять таблицу Production.ProductCategoryHst 
-- с указанием типа операции в поле Action 
-- в зависимости от оператора, вызвавшего триггер.

-- c) Создайте представление VIEW, 
-- отображающее все поля таблицы Production.ProductCategory.

-- d) Вставьте новую строку в Production.ProductCategory 
-- через представление. Обновите вставленную строку. 
-- Удалите вставленную строку. Убедитесь, что все три операции 
-- отображены в Production.ProductCategoryHst.