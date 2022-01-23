SET search_path TO ro;
-- Какое количество платежей было совершено?
SELECT COUNT(customer_id) 
FROM orders
;
-- Какое количество товаров находится в категории "Игрушки"?
SELECT c.category, COUNT(product)
FROM product AS p
JOIN category AS c ON p.category_id = c.category_id
GROUP BY category
HAVING category = 'Игрушки'
;
--В какой категории находится больше всего товаров?
WITH prod_count AS (
    SELECT COUNT(product) AS p_count, c.category
    FROM product AS p
    JOIN category AS c ON p.category_id = c.category_id
    GROUP BY c.category)
SELECT category 
FROM prod_count
WHERE p_count = (SELECT MAX(p_count) FROM prod_count)
;
-- Сколько "Черепах" купила Williams Linda?
SELECT p.product, op.amount  FROM orders AS o
JOIN customer AS c ON o.customer_id = c.customer_id
JOIN order_product_list AS op ON o.order_id = op.order_id
JOIN product AS p ON op.product_id = p.product_id
WHERE c.last_name = 'Williams' AND c.first_name = 'Linda' AND p.product = 'Черепаха'
;
-- С кем живет Williams Linda?
SELECT first_name, last_name
FROM customer 
WHERE address_id = (SELECT address_id FROM customer WHERE first_name = 'Linda' AND last_name = 'Williams')
;
SELECT first_name, last_name
FROM staff
WHERE address_id = (SELECT address_id FROM customer WHERE first_name = 'Linda' AND last_name = 'Williams')
;
