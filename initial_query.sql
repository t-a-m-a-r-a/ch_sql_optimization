-- Задача
-- Из таблиц orders и users вычислить 10 самых активных пользователей (по количеству неотмененных заказов) 
-- за последний месяцю. Вывести их данные + сумму покупок.


-- Изначальный запрос
select
	u.user_id, u.name, u.country
	, count(o.order_id) as total_orders
	, sum(o.amount) as total_amount
from users u
join orders o
on u.user_id = o.user_id
where o.order_date >= today() - 30
	and o.status != 'cancelled'
group by u.user_id, u.name, u.country
order by total_orders desc, total_amount desc
limit 10;

-- Потребление ресурсов
select query, read_rows, read_bytes, result_bytes, memory_usage, query_duration_ms 
from system.query_log
where query ilike '%from users%'
	and query not ilike '%system%'
	and type = 2
;

-- Результаты для сравнения
--read_rows   read_bytes   result_bytes    memory_usage    query_duration_ms
--11000000    224888890    20992           148301486       3365              - initial query

EXPLAIN PLAN json = 1, indexes = 1, description = 1
select
	u.user_id, u.name, u.country
	, count(o.order_id) as total_orders
	, sum(o.amount) as total_amount
from users u
join orders o
on u.user_id = o.user_id
where o.order_date >= today() - 30
	and o.status != 'cancelled'
group by u.user_id, u.name, u.country
order by total_orders desc, total_amount desc
limit 10;

/*
По плану запроса есть несколько неэффективных пунктов:
1. Join выполняется до фильтрации
2. Обе таблицы читаются полностью (для users: 123 из 123 гранул, для orders: 1222 из 1222 гранул)
*/



