--добавить ссылку на свою схему--
SET search_path TO rodionov_v

--добавляем внешний ключ для orders.delivery_id ссылающийся на delivery.delivery_id
ALTER TABLE orders ADD CONSTRAINT orders_delivery_fkey
FOREIGN KEY (delivery_id) REFERENCES delivery(delivery_id)

--добавляем даннные в таблицу delivery
INSERT INTO delivery (address_id, staff_id, delivery_date, delivery_time)	
VALUES (FLOOR(300 * RANDOM()), CEILING(5 * RANDOM()), '07.01.2022', array['08:00:00', '13:00:00']::TIME[]),
		(FLOOR(200 * RANDOM()), CEILING(5 * RANDOM()), '30.01.2022', array['09:00:00', '12:00:00']::TIME[]),
		(FLOOR(100 * RANDOM()), CEILING(5 * RANDOM()), '09.01.2022', array['21:00:00', '23:00:00']::TIME[]),
		(FLOOR(500 * RANDOM()), CEILING(5 * RANDOM()), '19.01.2022', array['14:00:00', '18:00:00']::TIME[]),
		(FLOOR(400 * RANDOM()), CEILING(5 * RANDOM()), '17.01.2022', array['11:00:00', '14:00:00']::TIME[])

--очистка таблицы delivery
DELETE FROM delivery
ALTER SEQUENCE delivery_delivery_id_seq RESTART WITH 1
--
DROP TABLE delivery

--очистка delivery_id в orders
UPDATE orders 
SET delivery_id = NULL

--обновляем данные поля delivery_id в orders по записям из таблицы delivery
UPDATE orders
SET delivery_id = tab.delivery_id
FROM
		(SELECT delivery_id
		FROM delivery) AS tab
WHERE orders.order_id = tab.delivery_id * FLOOR(10 * RANDOM())

WITH test AS (
--JOIN--
SELECT d.delivery_id, order_id,
	CONCAT(c.first_name, ' ', c.last_name) AS name,
	amount,
	delivery_date,
	address,
	status
FROM orders AS o
JOIN delivery AS d ON o.delivery_id = d.delivery_id
JOIN address AS a ON a.address_id = d.address_id
JOIN customer AS c ON c.customer_id = o.customer_id
ORDER BY delivery_id ASC
)
--functions--
SELECT SUM(amount), AVG(amount), MIN(amount), MAX(amount) FROM test
GROUP BY name


