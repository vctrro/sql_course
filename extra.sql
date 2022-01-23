SET search_path TO ro;
/*  1.Нужно получить количество записей в address, за вычетом служебных адресов.
    2.Нужно получить количество записей в orders.
    3.Сформировать заполнение таблицы delivery случайно генерируемыми данными в цикле согласно количества записей в orders.
    4.Заполнить delivery_id в orders согласно новых данных в delivery, при этом заполнение должно происходить рандомно, а не последовательно.*/

/*
/   Количество записей в address, за вычетом служебных адресов
*/
SELECT COUNT(*) 
FROM address
WHERE address_id NOT IN (
    SELECT address_id 
    FROM staff)
;

/*
/   Заказы по служебным адресам
*/
SELECT *, a.address
FROM orders AS o
JOIN customer AS c ON o.customer_id = c.customer_id
JOIN address AS a ON c.address_id = a.address_id
WHERE c.address_id IN (
    SELECT address_id 
    FROM staff)
;


/*
/   Создаем временную таблицу с рандомно перемешанными order_id
/   В первом цикле заполняем таблицу delivery рандомными данными
/   Во втором цикле заполняем orders.delivery_id данными из временной таблицы
/   Удаляем временную таблицу
*/
CREATE TEMPORARY TABLE rand_id (
    new_id serial primary key,
    order_id INTEGER
);

INSERT INTO rand_id (order_id)
SELECT order_id
FROM (
    SELECT order_id FROM orders
    ORDER BY RANDOM()) AS r;

DO
$do$
DECLARE
    TABLE_RECORD RECORD;
BEGIN
FOR TABLE_RECORD IN SELECT * FROM rand_id
LOOP
    INSERT INTO delivery (address_id, staff_id, delivery_date, delivery_time)	
    VALUES (FLOOR(RANDOM() * (SELECT COUNT(*) FROM address)) + 1,
			FLOOR(RANDOM() * (SELECT COUNT(*) FROM staff)) + 1,	
            (SELECT TIMESTAMP '2022-01-01' + random() * (TIMESTAMP '2022-01-31' - TIMESTAMP '2022-01-01')), 
            array[
            (SELECT TIMESTAMP '2022-01-01 09:00:00' + date_trunc('hour',('5 hours'::INTERVAL*random()))),
            (SELECT TIMESTAMP '2022-01-01 14:00:00' + date_trunc('hour',('5 hours'::INTERVAL*random())))]);   
END LOOP;
FOR TABLE_RECORD IN SELECT * FROM rand_id
LOOP
    UPDATE orders 
    SET delivery_id = TABLE_RECORD.new_id
    WHERE order_id = TABLE_RECORD.order_id;
END LOOP;
END
$do$;

DROP TABLE rand_id;

--3-- not work
DO
$do$
BEGIN
FOR i IN 1..(SELECT COUNT(*) FROM orders) LOOP
    INSERT INTO delivery (address_id, staff_id, delivery_date, delivery_time)	
    VALUES (FLOOR(RANDOM() * (SELECT COUNT(*) FROM address)) + 1,
			FLOOR(RANDOM() * (SELECT COUNT(*) FROM staff)) + 1,	
            (SELECT TIMESTAMP '2022-01-01' + random() * (TIMESTAMP '2022-01-31' - TIMESTAMP '2022-01-01')), 
            array[
            (SELECT TIMESTAMP '2022-01-01 09:00:00' + date_trunc('hour',('5 hours'::INTERVAL*random()))),
            (SELECT TIMESTAMP '2022-01-01 14:00:00' + date_trunc('hour',('5 hours'::INTERVAL*random())))]);
    UPDATE orders 
    SET delivery_id = i
    WHERE order_id = (
        SELECT order_id 
        FROM radn_id 
        WHERE rand_id.new_id = i);
END LOOP;
END
$do$;

--create from table------------- //not work
CREATE TEMPORARY TABLE rand_id (
    new_id serial primary key,
    order_id INTEGER
)
ON COMMIT DROP
AS SELECT * FROM (
    SELECT o.order_id, r.order_id
    FROM orders AS o
    JOIN (
        SELECT order_id FROM orders
        ORDER BY RANDOM()) AS r);

SELECT * FROM rand_id;
--end block---------------------

--create, then isert-----------
CREATE TEMPORARY TABLE rand_id (
    new_id serial primary key,
    order_id INTEGER
);

INSERT INTO rand_id (order_id)
SELECT order_id
FROM (
    SELECT order_id FROM orders
    ORDER BY RANDOM()) AS r;

SELECT * FROM rand_id;
DROP TABLE rand_id;
--end block---------------------

----not work--------------------
WITH temp AS (
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
--end block---------------------
