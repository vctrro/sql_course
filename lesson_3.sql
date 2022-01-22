--добавить ссылку на свою схему--
set search_path to rodionov_v

--добавляем внешний ключ для orders.delivery_id ссылающийся на delivery.delivery_id
alter table orders add constraint orders_delivery_fkey foreign key (delivery_id) references delivery(delivery_id)

--добавляем даннные в таблицу delivery
insert into delivery (address_id, staff_id, delivery_date, delivery_time)
	values (100, 2, '22.01.2022', array['15:00:00', '16:00:00']::time[]),
	(112, 2, '22.01.2022', array['14:00:00', '15:00:00']::time[]),
	(118, 2, '22.01.2022', array['13:00:00', '14:00:00']::time[])

--обновляем данные поля delivery_id в orders по записям из таблицы delivery
update orders
set delivery_id = tab.delivery_id
from (select delivery_id 
	 from delivery) as tab
where orders.order_id = tab.delivery_id

--