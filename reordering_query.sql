-- Перенос фильтрации до джоина
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

-- Потребление ресурсов
select query, read_rows, read_bytes, result_bytes, memory_usage, query_duration_ms 
from system.query_log
where query ilike '%from orders%'
	and query not ilike '%system%'
	and type = 2
;

--Результаты сравнения
--read_rows   read_bytes   result_bytes    memory_usage    query_duration_ms
--11000000    224888890    20992           148301486        3365              - initial query
--11000000    224888890    20992            81326491        1518              - reordering join and where

EXPLAIN PLAN json = 1, indexes = 1, description = 1
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


/*Перенос фильтрации where в подзапрос до джоина ускорил выполнение запроса в 2,2 раза 
и уменьшил используемую память в 1,82 раза .
При этом
2. Обе таблицы читаются полностью (для users: 123 из 123 гранул, для orders: 1222 из 1222 гранул) - 
	решается партиционированием таблиц по полю фильтрации - дате заказа (месяц+год)
 */
