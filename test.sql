SET search_path TO ro;
--Какое количество платежей было совершено?
SELECT COUNT(customer_id) 
FROM orders
;
--Какое количество товаров находится в категории "Игрушки"?
SELECT COUNT(product), c.category
FROM product AS p
JOIN category AS c ON p.category_id = c.category_id
--WHERE с.category = 'Игрушки'
GROUP BY c.category
ORDER BY count DESC
;
--В какой категории находится больше всего товаров?
WITH prod_count AS (
    SELECT COUNT(product) AS p_count, c.category
    FROM product AS p
    JOIN category AS c ON p.category_id = c.category_id
    GROUP BY c.category)
SELECT MAX(p_count), category 
FROM prod_count
;