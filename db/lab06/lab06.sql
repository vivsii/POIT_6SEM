-- 1. ¬ычисление итогов работы продавцов помес€чно, за квартал, за полгода, за год
SELECT 
    e.name || ' ' || e.last_name AS employee_name,
    EXTRACT(YEAR FROM od.date_order) AS year,
    EXTRACT(MONTH FROM od.date_order) AS month,
    SUM(o.price) AS monthly_sales,
    SUM(SUM(o.price)) OVER (
        PARTITION BY e.id, EXTRACT(YEAR FROM od.date_order), 
        CEIL(EXTRACT(MONTH FROM od.date_order)/3)
        ORDER BY EXTRACT(MONTH FROM od.date_order)
    ) AS quarterly_sales,
    SUM(SUM(o.price)) OVER (
        PARTITION BY e.id, EXTRACT(YEAR FROM od.date_order), 
        CEIL(EXTRACT(MONTH FROM od.date_order)/6)
        ORDER BY EXTRACT(MONTH FROM od.date_order)
    ) AS semi_annual_sales,
    SUM(SUM(o.price)) OVER (
        PARTITION BY e.id, EXTRACT(YEAR FROM od.date_order)
        ORDER BY EXTRACT(MONTH FROM od.date_order)
    ) AS annual_sales
FROM Orders o
JOIN orderdetails od ON o.id_order = od.order_id
JOIN employee e ON o.employee_id = e.id
GROUP BY e.id, e.name, e.last_name, EXTRACT(YEAR FROM od.date_order), EXTRACT(MONTH FROM od.date_order)
ORDER BY e.name, year, month;

-- 2. ¬ычисление итогов работы продавцов за определенный период
SELECT 
    e.name || ' ' || e.last_name AS employee_name,
    SUM(o.price) AS total_sales,
    ROUND(SUM(o.price) / SUM(SUM(o.price)) OVER () * 100, 2) AS percentage_of_total,
    ROUND(SUM(o.price) / MAX(SUM(o.price)) OVER () * 100, 2) AS percentage_of_best
FROM Orders o
JOIN employee e ON o.employee_id = e.id
GROUP BY e.id, e.name, e.last_name
ORDER BY total_sales DESC;

-- 3. ѕоследние 6 заказов дл€ каждого клиента
WITH ranked_orders AS (
    SELECT 
        o.user_id,
        o.id_order,
        o.price,
        od.date_order,
        ROW_NUMBER() OVER (PARTITION BY o.user_id ORDER BY od.date_order DESC) AS rn
    FROM Orders o
    JOIN orderdetails od ON o.id_order = od.order_id
)
SELECT 
    u.name || ' ' || u.last_name AS customer_name,
    ro.id_order,
    ro.price,
    ro.date_order
FROM ranked_orders ro
JOIN Users u ON ro.user_id = u.id
WHERE ro.rn <= 6
ORDER BY u.name, ro.rn;

-- 4. —отрудник, обслуживший наибольшее число заказов определенного клиента
WITH employee_order_counts AS (
    SELECT 
        o.user_id,
        o.employee_id,
        COUNT(*) AS order_count
    FROM Orders o
    GROUP BY o.user_id, o.employee_id
),
max_orders AS (
    SELECT 
        user_id,
        MAX(order_count) AS max_count
    FROM employee_order_counts
    GROUP BY user_id
)
SELECT 
    u.name || ' ' || u.last_name AS customer_name,
    e.name || ' ' || e.last_name AS employee_name,
    eoc.order_count
FROM employee_order_counts eoc
JOIN max_orders mo ON eoc.user_id = mo.user_id AND eoc.order_count = mo.max_count
JOIN Users u ON eoc.user_id = u.id
JOIN employee e ON eoc.employee_id = e.id
ORDER BY u.name, eoc.order_count DESC;
