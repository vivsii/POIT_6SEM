CREATE DATABASE book;

-- Таблица пользователей
CREATE TABLE Users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    hash NVARCHAR(255) NOT NULL,
    role NVARCHAR(20) NOT NULL CHECK (role IN ('admin', 'user', 'employee'))
);

-- Таблица жанров книг
CREATE TABLE genres (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(50) NOT NULL UNIQUE
);

-- Таблица авторов
CREATE TABLE authors (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    biography NVARCHAR(MAX)
);

-- Таблица книг
CREATE TABLE book (
    id_book INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    genre_id INT NULL,
    description NVARCHAR(MAX),
    publication_date DATE NULL,
    author_id INT NULL,
    FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE SET NULL,
    FOREIGN KEY (author_id) REFERENCES authors(id) ON DELETE SET NULL
);

-- Таблица сотрудников
CREATE TABLE employee (
    id INT IDENTITY PRIMARY KEY,
    name VARCHAR(255),
    last_name VARCHAR(255),
    job VARCHAR(255),
    manager_id INT,
);

-- Таблица заказов
CREATE TABLE Orders (
    id_order INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NULL,
    price DECIMAL(10,2) NOT NULL,
    count INT NOT NULL,
    employee_id INT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employee(id) ON DELETE SET NULL
);

-- Таблица деталей заказа
CREATE TABLE orderdetails (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    count INT NOT NULL,
    date_order DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (order_id) REFERENCES Orders(id_order) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES book(id_book) ON DELETE CASCADE
);

-- Таблица платежей
CREATE TABLE payments (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    sum DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(id_order) ON DELETE CASCADE
);

CREATE INDEX idx_book_title ON book(title);
CREATE INDEX idx_orders_user ON Orders(user_id);

-- Создание представлений
CREATE VIEW vw_books AS
SELECT b.id_book, b.title, b.price, b.stock, g.name AS genre, a.name AS author, b.publication_date
FROM book b
LEFT JOIN genres g ON b.genre_id = g.id
LEFT JOIN authors a ON b.author_id = a.id;

CREATE VIEW vw_orders AS
SELECT o.id_order, u.name + ' ' + u.last_name AS customer, o.price, o.count, e.name + ' ' + e.last_name AS employee
FROM Orders o
LEFT JOIN Users u ON o.user_id = u.id
LEFT JOIN employee e ON o.employee_id = e.id;

INSERT INTO Users (name, last_name, email, hash, role) VALUES 
('Иван', 'Иванов', 'ivanov@example.com', 'hash1', 'user'),
('Петр', 'Петров', 'petrov@example.com', 'hash2', 'admin'),
('Сергей', 'Сергеев', 'sergeev@example.com', 'hash3', 'employee'),
('Анна', 'Сидорова', 'sidorova@example.com', 'hash4', 'user'),
('Мария', 'Козлова', 'kozlova@example.com', 'hash5', 'user');

INSERT INTO genres (name) VALUES 
('Фантастика'),
('Детектив'),
('Роман'),
('Научная литература'),
('Фэнтези');

INSERT INTO authors (name, biography) VALUES 
('Артур Кларк', 'Английский писатель-фантаст.'),
('Агата Кристи', 'Королева детективов.'),
('Лев Толстой', 'Русский писатель, автор "Войны и мира".'),
('Айзек Азимов', 'Американский писатель-фантаст.'),
('Джоан Роулинг', 'Британская писательница, автор "Гарри Поттера".');

INSERT INTO book (title, price, stock, genre_id, description, publication_date, author_id) VALUES 
('2001: Космическая Одиссея', 500.00, 10, 1, 'Научная фантастика о космосе.', CAST('1968-01-01' AS DATE), 1),
('Убийство в Восточном экспрессе', 450.00, 5, 2, 'Детективный роман Агаты Кристи.', CAST('1934-01-01' AS DATE), 2),
('Война и мир', 1200.00, 7, 3, 'Эпопея о России во времена Наполеона.', CAST('1869-01-01' AS DATE), 3),
('Я, Робот', 600.00, 15, 1, 'Сборник рассказов об искусственном интеллекте.', CAST('1950-01-01' AS DATE), 4),
('Гарри Поттер и философский камень', 700.00, 20, 5, 'Начало приключений Гарри Поттера.', CAST('1997-06-26' AS DATE), 5);

INSERT INTO employee (name, last_name, job, manager_id)
VALUES 
    ('Алексей', 'Иванов', 'Директор', NULL), -- корневой элемент
    ('Мария', 'Петрова', 'Менеджер', 1), -- подчиненный Алексею
    ('Иван', 'Сидоров', 'Разработчик', 2), -- подчиненный Марии
    ('Анна', 'Козлова', 'Тестировщик', 2), -- подчиненный Марии
    ('Дмитрий', 'Смирнов', 'Разработчик', 1); -- подчиненный Алексею

INSERT INTO Orders (user_id, price, count, employee_id) VALUES 
(1, 500.00, 1, 1),
(2, 450.00, 2, 2),
(3, 1200.00, 1, NULL),
(4, 600.00, 1, 3),
(5, 700.00, 2, 1);

INSERT INTO orderdetails (order_id, product_id, count, date_order) VALUES 
(1, 1, 1, GETDATE()),
(2, 2, 2, GETDATE()),
(3, 3, 1, GETDATE()),
(4, 4, 1, GETDATE()),
(5, 5, 2, GETDATE());


INSERT INTO payments (order_id, sum) VALUES 
(1, 500.00),
(2, 900.00),
(3, 1200.00),
(4, 600.00),
(5, 1400.00);

-- Процедура 1: Добавление нового пользователя
CREATE PROCEDURE add_user(
    @p_name NVARCHAR(50), 
    @p_last_name NVARCHAR(50), 
    @p_email NVARCHAR(100), 
    @p_hash NVARCHAR(255), 
    @p_role NVARCHAR(20)
)
AS
BEGIN
    INSERT INTO Users (name, last_name, email, hash, role)
    VALUES (@p_name, @p_last_name, @p_email, @p_hash, @p_role);
END;
GO

-- Процедура 2: Создание нового заказа
CREATE PROCEDURE create_order(
    @p_user_id INT, 
    @p_employee_id INT, 
    @p_price DECIMAL(10, 2), 
    @p_count INT
)
AS
BEGIN
    INSERT INTO Orders (user_id, price, count, employee_id)
    VALUES (@p_user_id, @p_price, @p_count, @p_employee_id);
END;
GO

-- Процедура 3: Удаление заказа
CREATE PROCEDURE delete_order(
    @p_id_order INT
)
AS
BEGIN
    DELETE FROM orderdetails WHERE order_id = @p_id_order;
    DELETE FROM Orders WHERE id_order = @p_id_order;
END;
GO

-- Процедура 4: Получение информации о заказе
CREATE PROCEDURE get_order_info(
    @p_id_order INT
)
AS
BEGIN
    DECLARE @v_user_id INT;
    DECLARE @v_price DECIMAL(10,2);
    DECLARE @v_count INT;
    DECLARE @v_employee_id INT;
    BEGIN TRY
        SELECT @v_user_id = user_id, 
               @v_price = price, 
               @v_count = count, 
               @v_employee_id = employee_id
        FROM Orders
        WHERE id_order = @p_id_order;
        PRINT 'Order ID: ' + CAST(@p_id_order AS NVARCHAR);
        PRINT 'User ID: ' + CAST(@v_user_id AS NVARCHAR);
        PRINT 'Price: ' + CAST(@v_price AS NVARCHAR);
        PRINT 'Count: ' + CAST(@v_count AS NVARCHAR);
        PRINT 'Employee ID: ' + CAST(@v_employee_id AS NVARCHAR);
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Процедура 5: Добавление нового жанра
CREATE PROCEDURE add_genre(
    @p_genre_name NVARCHAR(50)
)
AS
BEGIN
    INSERT INTO genres (name) VALUES (@p_genre_name);
END;
GO

-- Функция 1: Получение полной стоимости заказа
CREATE FUNCTION get_order_total(
    @p_order_id INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @v_total DECIMAL(10, 2);
    SELECT @v_total = SUM(b.price * od.count)
    FROM orderdetails od
    JOIN book b ON od.product_id = b.id_book
    WHERE od.order_id = @p_order_id;
    RETURN @v_total;
END;
GO

-- Функция 2: Получение количества книг по жанру
CREATE FUNCTION get_books_count_by_genre(
    @p_genre_name NVARCHAR(50)
)
RETURNS INT
AS
BEGIN
    DECLARE @v_count INT;
    SELECT @v_count = COUNT(*)
    FROM book b
    JOIN genres g ON b.genre_id = g.id
    WHERE g.name = @p_genre_name;
    RETURN @v_count;
END;
GO

-- Функция 3: Проверка наличия книги в наличии
CREATE FUNCTION get_full_book_name(
    @p_book_id INT
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @v_full_name NVARCHAR(255);
    SELECT @v_full_name = b.title + ' by ' + a.name
    FROM book b
    JOIN authors a ON b.author_id = a.id
    WHERE b.id_book = @p_book_id;
    RETURN @v_full_name;
END;
GO

-- Функция 4: Получение полного имени пользователя
CREATE FUNCTION get_full_user_name(
    @p_user_id INT
)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @v_full_name NVARCHAR(100);
    SELECT @v_full_name = name + ' ' + last_name 
    FROM Users
    WHERE id = @p_user_id;
    RETURN @v_full_name;
END;
GO

-- Функция 5: Получение общего количества заказанных товаров
CREATE FUNCTION get_total_items_in_order(
    @p_order_id INT
)
RETURNS INT
AS
BEGIN
    DECLARE @v_total_items INT;
    SELECT @v_total_items = SUM(count)
    FROM orderdetails
    WHERE order_id = @p_order_id;
    RETURN @v_total_items;
END;
GO

-- Добавление нового пользователя
EXEC add_user @p_name = 'Олег', @p_last_name = 'Лебедев', @p_email = 'oleglebedev@example.com', @p_hash = 'hash6', @p_role = 'user';
-- Создание нового заказа с id_user = 2, id_employee = 1, price = 1000, count = 2
EXEC create_order @p_user_id = 2, @p_employee_id = 1, @p_price = 1000, @p_count = 2;
-- Удаление заказа с id_order = 1
EXEC delete_order @p_id_order = 1;
-- Получение информации о заказе с id_order = 1
EXEC get_order_info @p_id_order = 1;
-- Добавление нового жанра
EXEC add_genre @p_genre_name = 'Мистика';
-- Получение полной стоимости заказа с id_order = 2
SELECT dbo.get_order_total(2) AS total_price;
-- Получение количества книг в жанре 'Фантастика'
SELECT dbo.get_books_count_by_genre('Фантастика') AS book_count;
-- Получение полного имени книги с id_book = 1
SELECT dbo.get_full_book_name(1) AS full_book_name;
-- Получение полного имени пользователя с id = 1
SELECT dbo.get_full_user_name(1) AS full_name;
-- Получение общего количества товаров в заказе с id_order = 1
SELECT dbo.get_total_items_in_order(2) AS total_items;


