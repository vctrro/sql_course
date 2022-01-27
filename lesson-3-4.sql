SET search_path TO ro;

explain analyze
select opl.product_id, 
	sum(o.amount) * 100 / (select sum(amount) from orders)
from orders o 
join order_product_list opl on opl.order_id = o.order_id
group by opl.product_id

select opl.product_id, 
	sum(o.amount) * 100 / sum(sum(o.amount)) over ()
from orders o 
join order_product_list opl on opl.order_id = o.order_id
group by opl.product_id

-- ТАК ДЕЛАТЬ НЕЛЬЗЯ
explain analyze --3377.14 
select opl.product_id, 
	sum(o.amount) / (select price from product p where p.product_id = opl.product_id)
from orders o 
join order_product_list opl on opl.order_id = o.order_id
group by opl.product_id
order by 1

explain analyze --592.60
select t1.product_id, sa / price
from (
	select opl.product_id, sum(o.amount) sa
	from orders o 
	join order_product_list opl on opl.order_id = o.order_id
	group by opl.product_id) t1
join (
	select price, product_id
	from product) t2 on t2.product_id = t1.product_id
order by 1

select order_id, customer_id, row_number
from (
	select order_id, customer_id,
		row_number() over (order by created_date)
	from orders) t
where row_number % 1000 = 0

select customer_id, sum(amount), sum(sum(amount)) over ()
from orders
group by customer_id
order by 1

select customer_id, sum(amount) over (), 
	sum(amount) over (partition by customer_id),
	row_number() over (partition by customer_id order by order_id),
	amount,
	sum(amount) over (partition by customer_id order by order_id)
from orders
order by 1

explain analyze
select customer_id, order_id, amount,
	sum(amount) over (partition by customer_id order by order_id),
	avg(amount) over (partition by customer_id order by order_id)
from orders
order by 1

select *
from (
	select order_id, amount, dense_rank() over (order by amount desc)
	from orders) t 
where dense_rank = 2

select order_id, amount, rank() over (order by amount desc)
	from orders
	
explain analyze --1197
select customer_id, order_id, amount,
	sum(amount) over (partition by customer_id order by order_id),
	avg(amount) over (partition by customer_id order by order_id)
from orders
order by 1

create view task_1 as 
	select customer_id, order_id, amount,
		sum(amount) over (partition by customer_id order by order_id),
		avg(amount) over (partition by customer_id order by order_id)
	from orders
	order by 1

explain analyze --1197
select * from task_1

create materialized view task_2 as 
	select customer_id, order_id, amount,
		sum(amount) over (partition by customer_id order by order_id),
		avg(amount) over (partition by customer_id order by order_id)
	from orders
	order by 1
with no data

select * from task_2

REFRESH MATERIALIZED VIEW task_2

explain analyze --121.5
select * from task_2

select t.*, c.last_name 
from task_2 t
join customer c on t.customer_id = c.customer_id

alter role postgres password 'новый пароль'

select *
from information_schema.tables
where table_type = 'VIEW' and table_schema = 'sqlfree'

group by 
group by grouping sets
group by cube 
group by rollup

select *
from sqlfree.customer 

'2022-01-25'