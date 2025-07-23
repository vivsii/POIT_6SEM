-- 1. Добавляем столбец для иерархии
ALTER TABLE employee
ADD category VARCHAR2(255);

-- 2. Процедура для отображения подчиненных узлов
CREATE OR REPLACE PROCEDURE GetEmployeeHierarchy(
    p_root_category IN VARCHAR2
) AS
    v_sql VARCHAR2(4000);
BEGIN
    v_sql := 'WITH EmployeeHierarchy AS (
        -- Базовый случай: выбираем корневые узлы (уровень 1)
        SELECT
            id,
            name,
            last_name,
            job,
            category,
            1 AS Level,
            CAST(''\'' || ROW_NUMBER() OVER (ORDER BY id) AS VARCHAR2(4000)) AS Path
        FROM employee
        WHERE category = :1
           OR (category LIKE :1 || ''/%''
               AND NOT EXISTS (
                   SELECT 1
                   FROM employee e2
                   WHERE e2.category LIKE :1 || ''%''
                     AND e2.category <> employee.category
                     AND employee.category LIKE e2.category || ''/%''
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
            CAST(eh.Path || ''/'' || ROW_NUMBER() OVER (PARTITION BY eh.category ORDER BY e.id) AS VARCHAR2(4000))
        FROM employee e
        INNER JOIN EmployeeHierarchy eh
            ON e.category LIKE eh.category || ''/%''
            AND e.category <> eh.category
    )
    SELECT * FROM EmployeeHierarchy
    ORDER BY Path';
    
    EXECUTE IMMEDIATE v_sql USING p_root_category;
END;
/

-- 3. Процедура для добавления подчиненного узла
CREATE OR REPLACE PROCEDURE AddSubCategory(
    p_new_sub_category IN VARCHAR2,
    p_parent_category IN VARCHAR2
) AS
BEGIN
    -- Проверяем существование родительской категории
    IF NOT EXISTS (SELECT 1 FROM employee WHERE category = p_parent_category) THEN
        DBMS_OUTPUT.PUT_LINE('Родительская категория не найдена: ' || p_parent_category);
        RETURN;
    END IF;

    -- Добавляем нового сотрудника с новой категорией
    INSERT INTO employee (name, last_name, job, category)
    VALUES ('New', 'Employee', 'Position', p_parent_category || '/' || p_new_sub_category);
END;
/

-- 4. Процедура для перемещения подчиненных
CREATE OR REPLACE PROCEDURE MoveSubCategories(
    p_source_parent_category IN VARCHAR2,
    p_target_parent_category IN VARCHAR2
) AS
BEGIN
    -- Проверяем существование исходной и целевой категорий
    IF NOT EXISTS (SELECT 1 FROM employee WHERE category = p_source_parent_category) THEN
        DBMS_OUTPUT.PUT_LINE('Исходная родительская категория не найдена: ' || p_source_parent_category);
        RETURN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM employee WHERE category = p_target_parent_category) THEN
        DBMS_OUTPUT.PUT_LINE('Новая родительская категория не найдена: ' || p_target_parent_category);
        RETURN;
    END IF;

    -- Обновляем все подчинённые узлы
    UPDATE employee
    SET category = p_target_parent_category || '/' ||
                   SUBSTR(category, LENGTH(p_source_parent_category) + 2)
    WHERE category LIKE p_source_parent_category || '/%';

    IF SQL%ROWCOUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Подкатегории успешно перемещены из ' || p_source_parent_category || ' в ' || p_target_parent_category);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Подкатегорий для перемещения не найдено под ' || p_source_parent_category);
    END IF;

    COMMIT;
END;
/

-- Примеры использования:

-- Добавляем начальные данные
INSERT INTO employee (name, last_name, job, category)
VALUES 
('John', 'Doe', 'CEO', 'IT'),
('Jane', 'Smith', 'Developer', 'IT/developer'),
('Mike', 'Johnson', 'Manager', 'IT/project_manager');

-- Получаем иерархию
EXEC GetEmployeeHierarchy('IT');

-- Добавляем подкатегории
EXEC AddSubCategory('backend', 'IT/developer');
EXEC AddSubCategory('frontend', 'IT/developer');

-- Перемещаем подкатегории
EXEC MoveSubCategories('IT/developer', 'IT/project_manager');
