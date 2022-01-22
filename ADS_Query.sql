
SET search_path TO ro;


SELECT amount,
       discount,
       customer_id,
       delivery_date,
       address,
       status
FROM orders o
JOIN delivery d ON o.delivery_id = d.delivery_id
JOIN ro.address a ON a.address_id = d.address_id
ORDER BY order_id ASC