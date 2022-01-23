SET search_path TO ro;
/*  1.Нужно получить количество записей в address, за вычетом служебных адресов.
    2.Нужно получить количество записей в orders.
    3.Сформировать заполнение таблицы delivery случайно генерируемыми данными в цикле согласно количества записей в orders.
    4.Заполнить delivery_id в orders согласно новых данных в delivery, при этом заполнение должно происходить рандомно, а не последовательно.*/

--1--
SELECT COUNT(*) 
FROM address
WHERE address_id NOT IN (
    SELECT address_id 
    FROM staff)
;
--2--
SELECT *, a.address
FROM orders AS o
JOIN customer AS c ON o.customer_id = c.customer_id
JOIN address AS a ON c.address_id = a.address_id
WHERE c.address_id IN (
    SELECT address_id 
    FROM staff)
;
--3--

DO
$do$
BEGIN
FOR i IN 1..(SELECT COUNT(*) FROM orders) LOOP
    INSERT INTO delivery (address_id, staff_id, delivery_date, delivery_time)	
    VALUES (FLOOR(RANDOM() * (SELECT COUNT(*) FROM address WHERE address_id NOT IN staff.address_id)) + 1,
			FLOOR(RANDOM() * (SELECT COUNT(*) FROM staff)) + 1,	
            (SELECT TIMESTAMP '2022-01-01' + random() * (TIMESTAMP '2022-01-31' - TIMESTAMP '2022-01-01')), 
            array[
            (SELECT TIMESTAMP '2022-01-01 09:00:00' + date_trunc('hour',('5 hours'::INTERVAL*random()))),
            (SELECT TIMESTAMP '2022-01-01 14:00:00' + date_trunc('hour',('5 hours'::INTERVAL*random())))]);

END LOOP;
END
$do$;
WITH rand_id AS (
    SELECT order_id FROM orders
    ORDER BY RANDOM()
)
UPDATE orders 
SET delivery_id = 1
WHERE order_id = (SELECT order_id FROM rand_id LIMIT 1);
DELETE FROM rand_id 
WHERE ctid IN (
    SELECT ctid
    FROM rand_id
    LIMIT 1);
