
SET search_path TO ro;


SELECT amount,
       discount,
       CONCAT(c.first_name, ' ', c.last_name) AS name,
       delivery_date,
       address,
       status
FROM orders AS o
JOIN delivery AS d ON o.delivery_id = d.delivery_id
JOIN address AS a ON a.address_id = d.address_id
JOIN customer AS c ON c.customer_id = o.customer_id
ORDER BY order_id ASC