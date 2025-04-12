# Оптимизация SQL-запроса в ClickHouse
## Цель проекта
Сравнение трех подходов к выполнению аналитического запроса:
  - Наивная реализация
  - Перенос фильтрации в подзапрос до объединения таблиц
  - Полная оптимизация с партициями и индексами
## Стек

![Clickhouse](https://img.shields.io/badge/-Clickhouse-151515?style=flat-square&logo=Clickhouse&logoColor=white)
![DBeaver](https://img.shields.io/badge/-DBeaver-D03E16?style=flat-square&logo=DBeaver&logoColor=white)
![Docker](https://img.shields.io/badge/-Docker-1D63ED?style=flat-square&logo=Docker&logoColor=white)

## Ключевые показатели:

| Метрика                       | Наивный       | Подзапрос     | Разница с наивным | Партиционирование | Разница с наивным |
|-------------------------------|---------------|---------------|-------------------|-------------------|-------------------|
| прочитано строк               |     11 000 000|     11 000 000|         -         |          2 178 466|      -80,20%      |
| Потребление памяти (MB)       |         148,30|          81,33|     -45,16%       |              65,33|      -55,95%      |
| Время выполнения запроса (мс) |          3 365|          1 518|     -54,89%       |              1 787|      -46,89%      |

## Выводы:
Перенос фильтрации WHERE в подзапрос до JOIN ускорил выполнение запроса в 2,2 раза и уменьшил используемую память в 1,82 раза. Но при этом также проводится полное сканирование данных.

Партиционирование таблицы orders по полю соединения таблиц (user_id) привело к снижению чтения данных с диска на 80,2%.

## Как воспроизвести:
Скрипт для генерации данных: 


<div id="badges" >
  <a href="initial_data.sql">
  initial_data
  </a> 
</div>

 Скрипты запросов: 

 
<div id="badges" >
  <a href="initial_query.sql">
  initial_query
  </a> 
  
</div><div id="badges" >
  <a href="reordering_query.sql">
  reordering_query
  </a> 
  
</div><div id="badges" >
  <a href="partitioned_query.sql">
  partitioned_query
  </a> 
</div>




