--Работает в PostgreSQL 11 и выше.

--временная таблица хорошее решение, только первичный ключ не нужен.
drop table rand_id;
create temporary table rand_id (
	new_id serial,
    order_id int
);

--drop table rand_id;

--во временную таблицу вносим в случайном порядке значения order_id
insert into rand_id (order_id)
select order_id
from (
    select order_id from orders
    order by random()) t;

--создаем первую процедуру, в которой вносим данные в delivery
create or replace procedure delivery_insert() as $$
	--объявляем переменные под количество адресов, сотрудников и цикла
	declare 
		address_count int; 
		staff_count int; 
		i record;
	begin
		--получили количество адерсов
		select count(*) from address into address_count;
		--получили количество сотрудников
		select count(*) from staff into staff_count;
		-- в цикле вносим рандомные данные в delivery, каждый кортеж коммитим и запускаем процедуру на апдейт orders
		for i in 
			select * from rand_id
		loop 
			-- используем execute, что бы не хешировать действия на каждой итерации и выполнять их налету
			execute 
				'insert into delivery (address_id, staff_id, delivery_date, delivery_time)   
	    		values (floor(random() * ' || address_count || ') + 1,
	            floor(random() * ' || staff_count || ') + 1, 
	            (select ''2022-01-01''::timestamp + random() * interval ''1 month''), 
	            array[
	            (select date_trunc(''hour'', ''09:00:00''::time +  random() * interval ''5 hours'')),
	            (select date_trunc(''hour'', ''14:00:00''::time +  random() * interval ''5 hours''))])';
            --вызываем процедуру на апдейт orders
            call order_update(i.new_id, i.order_id);
			--закоммитили, дороги назад нет ;) так как в orders тоже закоммитилось
            -- здесь можно добавить проверки и в случае чего звать ролбэк
			commit;
		end loop;
	end;
$$ language plpgsql;

--drop procedure delivery_insert()

--создаем процедуру для апдейта orders
create or replace procedure order_update(d_id int, o_id int) as $$
	begin
		--апдейтим
	    update orders 
    	set delivery_id = d_id
    	where order_id = o_id;
    	--коммитим
    	commit;
	end;
$$ language plpgsql;

--drop procedure order_update(int, int)

--запускаем безобразие
call delivery_insert()

