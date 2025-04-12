--Генерация данных

-- Создание таблицы пользователей
create table default.users (
	user_id UInt32
	, name String
	, age Int8
	, registration_date Date
	, country String
	, last_activity_date DateTime
)
engine=MergeTree order by user_id 

-- Создание таблицы заказов
create table default.orders (
	order_id UInt64
	, user_id UInt32
	, order_date Date
	, amount Float32
	, status Enum('pending', 'completed', 'cancelled')
)
engine=MergeTree order by order_id 


-- Генерация данных о пользователях
insert into default.users
select
	number as user_id
	, concat('User_', toString(number)) as name
	, rand() % 80 + 18 as age
	, today() - rand() % 3650 as registration_date
	, ['US', 'UK', 'DE', 'FR', 'RU'][rand() % 5 +1] as country
	, now() - rand() % (365*86400) as last_activity_date
from numbers(1000000)

-- Генерация данных о заказах
insert into default.orders
select
	number as order_id
	, rand() % 1000000 as user_id
	, today() - rand() % 365 as order_date
	, round(rand() % 1000 + 10, 2) as amount
	, ['pending', 'completed', 'cancelled'][rand() %3 + 1] as status
from numbers(10000000)
