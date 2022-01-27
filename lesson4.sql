SET search_path TO ro;

SELECT customer_id, DATE_TRUNC('MONTH', last_update), COUNT(order_id), SUM(amount), AVG(amount), MAX(amount), MIN(amount)
FROM orders
GROUP BY customer_id, DATE_TRUNC('MONTH', last_update)
ORDER BY customer_id;
;
/*
//  ОКОННЫЕ ФУНКЦИИ
*/
EXPLAIN ANALYZE
SELECT CONCAT(c.first_name, ' ', c.last_name) AS name, SUM(o.amount) OVER(PARTITION BY o.customer_id) AS sum_orders
FROM orders AS o
JOIN customer AS c ON c.customer_id = o.customer_id
ORDER BY sum_orders DESC
;
EXPLAIN ANALYZE
SELECT CONCAT(c.first_name, ' ', c.last_name) AS name, SUM(o.amount) AS sum_orders
FROM orders AS o
JOIN customer AS c ON c.customer_id = o.customer_id
GROUP BY name
ORDER BY sum_orders DESC
;
EXPLAIN ANALYZE
SELECT customer_id, SUM(amount), SUM(SUM(amount)) OVER()
FROM orders
GROUP BY customer_id
ORDER BY 1
;
EXPLAIN ANALYZE
SELECT DISTINCT
    customer_id, 
    SUM(amount) OVER(PARTITION BY customer_id),
    SUM(amount) OVER()
FROM orders
ORDER BY 1
;
-- накопительная сумма заказов по customer_id (order by в оконной функции накапливает данные)
SELECT customer_id, order_id, amount,
    sum(amount) OVER (PARTITION BY customer_id ORDER BY order_id)
FROM orders
;
-- rank() dense_rank()
SELECT customer_id, order_id, amount,
    rank() OVER (ORDER BY amount DESC),
    dense_rank() OVER (ORDER BY amount DESC)
FROM orders
;
-- ТЕСТ 7
-- Найдите категорию товара, у которой наибольшее процентное отношение количества товаров от общего количества товаров (18.659)
SELECT c.category, SUM(opl.amount) AS amount
FROM orders o
JOIN order_product_list opl ON opl.order_id = o.order_id
JOIN product p ON p.product_id = opl.product_id
JOIN category c ON c.category_id = p.category_id
GROUP BY c.category
ORDER BY amount DESC
;
SELECT SUM(opl.amount) OVER() AS sum
FROM order_product_list opl
LIMIT 1
;


/*
//  ПРЕДСТАВЛЕНИЯ
*/
CREATE VIEW customer_sum_avg AS
    SELECT CONCAT(c.last_name, ' ', c.first_name) AS name, c2.category, SUM(o.amount), COUNT(o.order_id) AS orders, SUM(opl.amount) AS amount
    FROM orders o
    JOIN order_product_list opl ON opl.order_id = o.order_id
    JOIN product p ON p.product_id = opl.product_id
    JOIN customer c ON c.customer_id = o.customer_id
    JOIN category c2 ON c2.category_id = p.category_id
    GROUP BY name, name, c2.category
    ORDER BY name
;
--DROP VIEW customer_sum_avg

SELECT * FROM customer_sum_avg






