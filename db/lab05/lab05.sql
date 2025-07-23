-- Очистка существующих данных
DELETE FROM orderdetails;
DELETE FROM payments;
DELETE FROM Orders;
DELETE FROM book;
DELETE FROM authors;
DELETE FROM genres;
DELETE FROM employee;
DELETE FROM Users;

-- Заполнение таблицы Users
INSERT INTO Users (name, last_name, email, hash, role) VALUES 
('Иван', 'Иванов', 'ivanov@example.com', 'hash1', 'user'),
('Петр', 'Петров', 'petrov@example.com', 'hash2', 'admin'),
('Сергей', 'Сергеев', 'sergeev@example.com', 'hash3', 'employee'),
('Анна', 'Сидорова', 'sidorova@example.com', 'hash4', 'user'),
('Мария', 'Козлова', 'kozlova@example.com', 'hash5', 'user'),
('Алексей', 'Смирнов', 'smirnov@example.com', 'hash6', 'user'),
('Елена', 'Попова', 'popova@example.com', 'hash7', 'user'),
('Дмитрий', 'Васильев', 'vasiliev@example.com', 'hash8', 'user'),
('Ольга', 'Новикова', 'novikova@example.com', 'hash9', 'user'),
('Андрей', 'Морозов', 'morozov@example.com', 'hash10', 'user');

-- Заполнение таблицы genres
INSERT INTO genres (name) VALUES 
('Фантастика'),
('Детектив'),
('Роман'),
('Научная литература'),
('Исторический'),
('Биография'),
('Поэзия'),
('Детская литература'),
('Бизнес'),
('Психология');

-- Заполнение таблицы authors
INSERT INTO authors (name, biography) VALUES 
('Артур Конан Дойл', 'Британский писатель, создатель Шерлока Холмса.'),
('Агата Кристи', 'Королева детектива, автор романов о Пуаро и мисс Марпл.'),
('Лев Толстой', 'Русский писатель, автор "Войны и мира" и "Анны Карениной".'),
('Фёдор Достоевский', 'Русский писатель, автор "Преступления и наказания".'),
('Джоан Роулинг', 'Британская писательница, автор серии о Гарри Поттере.'),
('Стивен Кинг', 'Американский писатель, мастер ужасов.'),
('Дэн Браун', 'Американский писатель, автор "Кода да Винчи".'),
('Джордж Мартин', 'Американский писатель, автор "Игры престолов".'),
('Джон Грин', 'Американский писатель, автор "Виноваты звёзды".'),
('Пауло Коэльо', 'Бразильский писатель, автор "Алхимика".');

-- Заполнение таблицы book (с правильными ID жанров)
INSERT INTO book (title, price, stock, genre_id, description, publication_date, author_id) VALUES 
('Шерлок Холмс: Собака Баскервилей', 450.00, 15, 2, 'Классический детектив о расследовании загадочной смерти.', '1902-01-01', 1),
('Убийство в Восточном экспрессе', 500.00, 10, 2, 'Знаменитый детектив Агаты Кристи.', '1934-01-01', 2),
('Война и мир', 1200.00, 8, 3, 'Великий роман Льва Толстого.', '1869-01-01', 3),
('Преступление и наказание', 600.00, 12, 3, 'Классика русской литературы.', '1866-01-01', 4),
('Гарри Поттер и философский камень', 700.00, 20, 1, 'Первая книга о юном волшебнике.', '1997-06-26', 5),
('Оно', 550.00, 10, 1, 'Классический роман ужасов.', '1986-09-15', 6),
('Код да Винчи', 650.00, 15, 2, 'Захватывающий детектив о тайнах истории.', '2003-03-18', 7),
('Игра престолов', 800.00, 10, 1, 'Первая книга цикла "Песнь Льда и Пламени".', '1996-08-01', 8),
('Виноваты звёзды', 500.00, 12, 3, 'Трогательная история о любви и жизни.', '2012-01-10', 9),
('Алхимик', 450.00, 15, 3, 'Философская притча о поиске своего пути.', '1988-01-01', 10);

-- Заполнение таблицы employee
INSERT INTO employee (name, last_name, job, manager_id) VALUES 
('Александр', 'Петров', 'Менеджер', NULL),
('Екатерина', 'Иванова', 'Продавец', 1),
('Михаил', 'Сидоров', 'Продавец', 1),
('Анна', 'Козлова', 'Продавец', 1),
('Дмитрий', 'Смирнов', 'Продавец', 1),
('Ольга', 'Попова', 'Продавец', 1),
('Сергей', 'Васильев', 'Продавец', 1),
('Мария', 'Новикова', 'Продавец', 1),
('Андрей', 'Морозов', 'Продавец', 1),
('Елена', 'Захарова', 'Продавец', 1);

-- Заполнение таблицы Orders и orderdetails
DECLARE @i INT = 1;
DECLARE @user_id INT;
DECLARE @employee_id INT;
DECLARE @book_id INT;
DECLARE @price DECIMAL(10,2);
DECLARE @count INT;
DECLARE @order_id INT;

WHILE @i <= 100
BEGIN
    -- Случайный пользователь
    SELECT @user_id = id FROM Users WHERE role = 'user' ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;
    
    -- Случайный сотрудник
    SELECT @employee_id = id FROM employee ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;
    
    -- Случайная книга
    SELECT @book_id = id_book, @price = price FROM book ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;
    
    -- Случайное количество
    SET @count = FLOOR(RAND() * 5) + 1;
    
    -- Вставка заказа
    INSERT INTO Orders (user_id, price, count, employee_id)
    VALUES (@user_id, @price * @count, @count, @employee_id);
    
    SET @order_id = SCOPE_IDENTITY();
    
    -- Вставка деталей заказа
    INSERT INTO orderdetails (order_id, product_id, count, date_order)
    VALUES (@order_id, @book_id, @count, DATEADD(DAY, -FLOOR(RAND() * 365), GETDATE()));
    
    -- Вставка платежа
    INSERT INTO payments (order_id, sum)
    VALUES (@order_id, @price * @count);
    
    SET @i = @i + 1;
END;

-- 3. Вычисление итогов работы продавцов помесячно, за квартал, за полгода, за год
SELECT 
    e.name + ' ' + e.last_name AS employee_name,
    YEAR(od.date_order) AS year,
    MONTH(od.date_order) AS month,
    DATEPART(QUARTER, od.date_order) AS quarter,
    CASE 
        WHEN MONTH(od.date_order) <= 6 THEN 1
        ELSE 2
    END AS half_year,
    SUM(o.price) AS total_sales,
    SUM(SUM(o.price)) OVER (PARTITION BY e.id, YEAR(od.date_order)) AS yearly_total,
    SUM(SUM(o.price)) OVER (PARTITION BY e.id, YEAR(od.date_order), DATEPART(QUARTER, od.date_order)) AS quarterly_total,
    SUM(SUM(o.price)) OVER (PARTITION BY e.id, YEAR(od.date_order), 
        CASE 
            WHEN MONTH(od.date_order) <= 6 THEN 1
            ELSE 2
        END) AS half_yearly_total
FROM employee e
JOIN Orders o ON e.id = o.employee_id
JOIN orderdetails od ON o.id_order = od.order_id
GROUP BY e.id, e.name, e.last_name, YEAR(od.date_order), MONTH(od.date_order), DATEPART(QUARTER, od.date_order)
ORDER BY e.name, e.last_name, YEAR(od.date_order), MONTH(od.date_order);

-- 4. Вычисление итогов работы продавцов за определенный период
WITH SalesTotals AS (
    SELECT 
        e.id AS employee_id,
        e.name + ' ' + e.last_name AS employee_name,
        SUM(o.price) AS total_sales
    FROM employee e
    JOIN Orders o ON e.id = o.employee_id
    GROUP BY e.id, e.name, e.last_name
)
SELECT 
    st.employee_name,
    st.total_sales,
    (st.total_sales * 100.0 / SUM(st.total_sales) OVER ()) AS percentage_of_total,
    (st.total_sales * 100.0 / MAX(st.total_sales) OVER ()) AS percentage_of_best
FROM SalesTotals st
ORDER BY st.total_sales DESC;

-- 5. Применение ROW_NUMBER() для разбиения на страницы
SELECT *
FROM (
    SELECT 
        o.id_order,
        u.name + ' ' + u.last_name AS customer_name,
        e.name + ' ' + e.last_name AS employee_name,
        o.price,
        o.count,
        ROW_NUMBER() OVER (ORDER BY o.id_order) AS row_num
    FROM Orders o
    JOIN Users u ON o.user_id = u.id
    JOIN employee e ON o.employee_id = e.id
) AS numbered_rows
WHERE row_num BETWEEN 10 AND 40; -- Первая страница (20 строк)

-- 6. Применение ROW_NUMBER() для удаления дубликатов
WITH DuplicateOrders AS (
    SELECT 
        o.*,
        ROW_NUMBER() OVER (
            PARTITION BY o.user_id, o.price, o.count, o.employee_id
            ORDER BY o.id_order
        ) AS rn
    FROM Orders o
)
DELETE FROM DuplicateOrders
WHERE rn > 1;

-- 7. Суммы последних 6 заказов для каждого клиента
WITH LastOrders AS (
    SELECT 
        o.user_id,
        o.price,
        ROW_NUMBER() OVER (PARTITION BY o.user_id ORDER BY o.id_order DESC) AS rn
    FROM Orders o
)
SELECT 
    u.name + ' ' + u.last_name AS customer_name,
    SUM(lo.price) AS total_last_6_orders
FROM LastOrders lo
JOIN Users u ON lo.user_id = u.id
WHERE lo.rn <= 6
GROUP BY u.id, u.name, u.last_name;

-- 8. Сотрудник, обслуживший наибольшее число заказов определенного клиента
WITH OrderCounts AS (
    SELECT 
        o.user_id,
        o.employee_id,
        COUNT(*) AS order_count,
        ROW_NUMBER() OVER (
            PARTITION BY o.user_id
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM Orders o
    WHERE o.employee_id IS NOT NULL
    GROUP BY o.user_id, o.employee_id
)
SELECT 
    u.name + ' ' + u.last_name AS customer_name,
    e.name + ' ' + e.last_name AS employee_name,
    oc.order_count
FROM OrderCounts oc
JOIN Users u ON oc.user_id = u.id
JOIN employee e ON oc.employee_id = e.id
WHERE oc.rn = 1
ORDER BY oc.order_count DESC;

