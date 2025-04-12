--Создание оптимизированной таблицы orders_optimized с партициями по полю фильтрации запроса (order_date) 
-- и с индексом по полю соединения таблиц (user_id)
create table default.orders_optimized engine=MergeTree partition by toYYYYMM(order_date) order by (user_id, order_id) settings index_granularity = 8192 as 
select order_id, user_id, order_date, amount, status
from orders

select
	u.user_id, u.name, u.country
	,o.total_orders, o.total_amount
from users u
join (select user_id
		, count(order_id) as total_orders
		, sum(amount) as total_amount
	  from orders
	  where order_date >= today() - 30
	  and status != 'cancelled'
	  group by user_id) o
on u.user_id = o.user_id
order by o.total_orders desc, o.total_amount desc
limit 10;


-- смотрим потребление ресурсов
select query, read_rows, read_bytes, result_rows, result_bytes, memory_usage, query_duration_ms 
from system.query_log
where query ilike '%orders_optimized%'
	and query not ilike '%system%'
	and type = 2
;

-- результаты сравнения
--read_rows   read_bytes   result_bytes    memory_usage    query_duration_ms
--11000000    224888890    20992           148301486        3365              - initial query
--11000000    224888890    20992            81326491        1518              - reordering join and where
-- 2178466     57279744      508            65328756        1787              - optimized_order


EXPLAIN PLAN json = 1, indexes = 1, description = 1
select
	u.user_id, u.name, u.country
	,o.total_orders, o.total_amount
from users u
join (select user_id
		, count(order_id) as total_orders
		, sum(amount) as total_amount
	  from orders_optimized
	  where order_date >= today() - 30
	  and status != 'cancelled'
	  group by user_id) o
on u.user_id = o.user_id
order by o.total_orders desc, o.total_amount desc
limit 10;

/*
Из таблицы orders читается только 12% данных (145 из 1226 гранул)

*/