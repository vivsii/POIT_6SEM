-- 1. Добавляем столбец для иерархии
ALTER TABLE employee
ADD category VARCHAR(255);

-- 2. Процедура для отображения подчиненных узлов
CREATE OR ALTER PROCEDURE GetEmployeeHierarchy
    @RootCategory VARCHAR(255)
AS
BEGIN
    WITH EmployeeHierarchy AS (
        -- Базовый случай: выбираем корневые узлы (уровень 1)
        SELECT
            id,
            name,
            last_name,
            job,
            category,
            1 AS Level,
            CAST('\' + CAST(ROW_NUMBER() OVER (ORDER BY id) AS VARCHAR) AS VARCHAR(MAX)) AS Path
        FROM employee
        WHERE category = @RootCategory
           OR (category LIKE @RootCategory + '/%'
               AND NOT EXISTS (
                   SELECT 1
                   FROM employee e2
                   WHERE e2.category LIKE @RootCategory + '%'
                     AND e2.category <> employee.category
                     AND employee.category LIKE e2.category + '/%'
               ))

        UNION ALL

        -- Рекурсивно добавляем подчинённые узлы
        SELECT
            e.id,
            e.name,
            e.last_name,
            e.job,
            e.category,
            eh.Level + 1,
            CAST(eh.Path + '/' + CAST(ROW_NUMBER() OVER (PARTITION BY eh.category ORDER BY e.id) AS VARCHAR) AS VARCHAR(MAX))
        FROM employee e
        INNER JOIN EmployeeHierarchy eh
            ON e.category LIKE eh.category + '/%'
            AND e.category <> eh.category -- Исключаем саму корневую запись
    )
    SELECT * FROM EmployeeHierarchy
    ORDER BY Path;
END
GO

-- 3. Процедура для добавления подчиненного узла
CREATE OR ALTER PROCEDURE AddSubCategory
    @NewSubCategory VARCHAR(255),
    @ParentCategory VARCHAR(255)
AS
BEGIN
    -- Проверяем существование родительской категории
    IF NOT EXISTS (SELECT 1 FROM employee WHERE category = @ParentCategory)
    BEGIN
        PRINT N'Родительская категория не найдена: ' + @ParentCategory;
        RETURN;
    END

    -- Добавляем нового сотрудника с новой категорией
    INSERT INTO employee (name, last_name, job, category)
    VALUES ('New', 'Employee', 'Position', @ParentCategory + '/' + @NewSubCategory);
END
GO

-- 4. Процедура для перемещения подчиненных
CREATE OR ALTER PROCEDURE MoveSubCategories
    @SourceParentCategory VARCHAR(255),
    @TargetParentCategory VARCHAR(255)
AS
BEGIN
    BEGIN TRANSACTION;

    -- Проверяем существование исходной и целевой категорий
    IF NOT EXISTS (SELECT 1 FROM employee WHERE category = @SourceParentCategory)
    BEGIN
        PRINT N'Исходная родительская категория не найдена: ' + @SourceParentCategory;
        ROLLBACK;
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM employee WHERE category = @TargetParentCategory)
    BEGIN
        PRINT N'Новая родительская категория не найдена: ' + @TargetParentCategory;
        ROLLBACK;
        RETURN;
    END

    -- Обновляем все подчинённые узлы
    UPDATE employee
    SET category = @TargetParentCategory + '/' +
                   SUBSTRING(category, LEN(@SourceParentCategory) + 2, LEN(category))
    WHERE category LIKE @SourceParentCategory + '/%';

    IF @@ROWCOUNT > 0
    BEGIN
        PRINT N'Подкатегории успешно перемещены из ' + @SourceParentCategory + N' в ' + @TargetParentCategory;
    END
    ELSE
    BEGIN
        PRINT N'Подкатегорий для перемещения не найдено под ' + @SourceParentCategory;
    END

    COMMIT;
END
GO

-- Примеры использования:

-- Добавляем начальные данные
INSERT INTO employee (name, last_name, job, category)
VALUES 
('John', 'Doe', 'CEO', 'IT'),
('Jane', 'Smith', 'Developer', 'IT/developer'),
('Mike', 'Johnson', 'Manager', 'IT/project_manager');
select * from employee
-- Получаем иерархию
EXEC GetEmployeeHierarchy @RootCategory = 'IT';

-- Добавляем подкатегории
EXEC AddSubCategory @NewSubCategory = 'backend', @ParentCategory = 'IT/developer';
EXEC AddSubCategory @NewSubCategory = 'frontend', @ParentCategory = 'IT/developer';

-- Перемещаем подкатегории
EXEC MoveSubCategories @SourceParentCategory = 'IT/developer', @TargetParentCategory = 'IT/project_manager';
