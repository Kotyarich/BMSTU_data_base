---------------------------------------------------------------------------
-------------------------------- SELECT -----------------------------------

-- 1. Инструкция SELECT, использующая предикат сравнения.
-- Все аэропорты, из которых были вылеты после 2019-01-01
select distinct bd_labs.airports.name
    from bd_labs.airports
    join bd_labs.flights on departure_airport_id = airports.id
    where departure_time > '2019-01-01'
    order by name;

-- 2. Инструкция select, использующая предикат between.
-- Все вылеты между 2019-01-01 и 2019-10-02
select *
    from bd_labs.flights
    where departure_time between '2019-01-01' and '2019-10-02';

-- 3. Инструкция select, использующая предикат like.
-- Все пассажиры, чьe имя начинается на "Аn"
select *
    from bd_labs.passengers
    where name like 'An%';

-- 4. Инструкция select, использующая предикат IN с вложенным подзапросом.
-- Все самолеты, на которых летала Anna Hammond
select *
    from bd_labs.planes
    where planes.id in (
            select plane_id
                from bd_labs.flights
                join bd_labs.tickets on tickets.flight_id = flights.id
                join bd_labs.passengers on tickets.passenger_id = passengers.id
                where passengers.name = 'Anna Hammond'
        );

-- 5. Инструкция select, использующая предикат exists с вложенным подзапросом
-- Все компании, которые летают в польшу
select company
    from bd_labs.planes as p
    where exists(select planes.id
        from bd_labs.planes
        join bd_labs.flights on p.id = flights.plane_id
        join bd_labs.airports on flights.departure_airport_id = airports.id
        where airports.country = 'Poland' and planes.id = p.id);

-- 6. Инструкция select, использующая предикат сравнения с квантором
-- Самый дорогой билет на самолет Аэрофлота
select distinct *
    from bd_labs.tickets
    where tickets.value >= ALL (
            select value
                from bd_labs.tickets
                join bd_labs.flights on tickets.flight_id = flights.id
                join bd_labs.planes on plane_id = planes.id
                where company = 'Aeroflot'
        );

-- 7. Инструкция select, использующая агрегатные функции в выражениях столбцов
-- Стоимость всех проданных Аэрофлотом билетов
select sum(value)
    from bd_labs.tickets
    join bd_labs.flights on tickets.flight_id = flights.id
    join bd_labs.planes on flights.plane_id = planes.id
    where company = 'Aeroflot';

-- 8. Инструкция select, использующая скалярные подзапросы в выражениях столбцов
-- Средняя стоимость билета каждой комании
select company, (select sum(value) / count(*)
            from bd_labs.tickets
            join bd_labs.flights on tickets.flight_id = flights.id
            join bd_labs.planes on flights.plane_id = planes.id
            where planes.company = p.company) as avg
    from bd_labs.planes as p
    group by  company;

-- 9. Инструкция select, использующая простое выражение case
--
select flights.id,
       case extract(hours from arrival_time - departure_time)
           when 0 then 'Less than 1 hour'
           when 1 then 'Less then 2 hour'
           else 'More than 2 hour'
       end as duration
    from bd_labs.flights;

-- 10. Инструкция select, использующая поисковое выражение case
--
select id,
       case
           when value < 1000::money then 'cheep'
           when value < 3000::money then 'normal'
           else 'expensive'
       end as duration
    from bd_labs.tickets;

-- 11. Создание новой временной локальной таблицы из результирующего набора
--     данных инструкции SELECT.
select company, (select sum(value) / count(*)
            from bd_labs.tickets
            join bd_labs.flights on tickets.flight_id = flights.id
            join bd_labs.planes on flights.plane_id = planes.id
            where planes.company = p.company) as avg
    into temp avg_prices
    from bd_labs.planes as p
    group by  company;

select * from avg_prices;

-- 12. Инструкция SELECT, использующая вложенные коррелированные подзапросы
--     в качестве производных таблиц в предложении FROM.
-- Все полеты в Россию
select *
    from bd_labs.flights
    join (select id from bd_labs.airports
            where country = 'Russian Federation'
    ) as ra on ra.id = departure_airport_id;

-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем
--     вложенности 3.
-- Компании, минимальная цена билетов которых больше средней цены билетов компаний,
-- максимальная цена билетов которых меньше 3000
select distinct company
    from bd_labs.planes
    where company in (
        select distinct company
            from bd_labs.planes
            join bd_labs.flights on planes.id = flights.plane_id
            join bd_labs.tickets on flights.id = tickets.flight_id
            group by company
            having min(value::numeric) > ALL (
                    select avg(value::numeric)
                        from bd_labs.planes
                        join bd_labs.flights on planes.id = flights.plane_id
                        join bd_labs.tickets on flights.id = tickets.flight_id
                        where company in (
                                select company
                                    from bd_labs.planes
                                    join bd_labs.flights on planes.id = flights.plane_id
                                    join bd_labs.tickets on flights.id = tickets.flight_id
                                    group by company
                                    having max(value) < 3000::money
                                    notnull
                            )
                        group by company
                )
        );

-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения
--     GROUP BY, но без предложения HAVING.
-- Средняя стоимость билета каждой комании
select company, (select sum(value) / count(*)
            from bd_labs.tickets
            join bd_labs.flights on tickets.flight_id = flights.id
            join bd_labs.planes on flights.plane_id = planes.id
            where planes.company = p.company) as avg
    from bd_labs.planes as p
    group by  company;

-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения
-- GROUP BY и предложения HAVING.
-- Компания, средняя цена билетов которых меньше 2500
select company
    from bd_labs.planes
    join bd_labs.flights on planes.id = flights.plane_id
    join bd_labs.tickets on flights.id = tickets.flight_id
    group by company
    having avg(value::numeric) < 2500;

---------------------------------------------------------------------------
-------------------------------- INSERT -----------------------------------

-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной
--     строки значений.
SELECT setval('bd_labs.passengers_id_seq', max(id))
FROM   bd_labs.passengers;
insert into bd_labs.passengers(name, birthday, sex, passport_number)
VALUES ('Name Secondname', '1985-01-01', 'm', '1234567890');

-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу
--     результирующего набора данных вложенного подзапроса.
insert into bd_labs.tickets(flight_id, passenger_id, value, class)
select (select id
        from bd_labs.flights
        limit 1),
       (select id
           from bd_labs.passengers
           where name = 'Name Secondname'),
       1000::money, 'b';

---------------------------------------------------------------------------
-------------------------------- UPDATE -----------------------------------

-- 18. Простая инструкция UPDATE.
update bd_labs.tickets
set value = value * 1.2
where id = 200;

-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.
update bd_labs.tickets
set value = (
        select avg(value)
        from bd_labs.tickets
        where tickets.passenger_id = 20
    )
where id = 20;

---------------------------------------------------------------------------
-------------------------------- DELETE -----------------------------------

-- 20. Простая инструкция DELETE.
delete from bd_labs.tickets
where passenger_id = 30;

-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в
--     предложении WHERE.
delete from bd_labs.tickets
where id in (
    select tickets.id
        from bd_labs.tickets
        join bd_labs.flights on tickets.flight_id = flights.id
        join bd_labs.planes on flights.plane_id = planes.id
        where company = 'Red Wings'
);

---------------------------------------------------------------------------

-- 22. Инструкция SELECT, использующая простое обобщенное табличное
--     выражение
-- Все полеты в Россию
with russian_airports as (
    select id
        from bd_labs.airports
        where country = 'Russian Federation'
)
select flights.*
    from bd_labs.flights
    join russian_airports on russian_airports.id = arrival_airport_id;

-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное
--     выражение.
-- Полеты самолета 102 по убыванию времени
with recursive all_airports_for_flight as (
    select flights.id, flights.departure_time as time, 1 as flight_num
        from bd_labs.flights
        where plane_id = 102 and departure_time = (
            select max(departure_time)
                from bd_labs.flights
                where plane_id = 102)

    union all

    select flights.id, flights.departure_time, flight_num + 1
        from bd_labs.flights
        join all_airports_for_flight on flights.departure_time < all_airports_for_flight.time
        where plane_id = 102 and departure_time in (
                select departure_time
                    from bd_labs.flights
                    where plane_id = 102
                    order by departure_time desc
                    offset flight_num
                    limit 1
            )
)
select * from all_airports_for_flight;

select plane_id, count(*) as c
    from bd_labs.flights
    group by plane_id
    order by c desc;

-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
select tickets.*,
       (avg(value::numeric) over(partition by company, tickets.class))::money as avg_price
    from bd_labs.tickets
    join bd_labs.flights on tickets.flight_id = flights.id
    join bd_labs.planes on flights.plane_id = planes.id;


-- 25. Оконные фнкции для устранения дублей
SELECT setval('bd_labs.tickets_id_seq', max(id))
FROM   bd_labs.tickets;
insert into bd_labs.tickets(flight_id, passenger_id, value, class)
select flight_id, passenger_id, value, class
    from bd_labs.tickets
    where id < 10;

delete from bd_labs.tickets
where id in (
    select tickets.id
    from bd_labs.tickets
    join (select id, row_number() over (partition by flight_id, passenger_id, value, class) as rn
            from bd_labs.tickets) as t on t.id = tickets.id
    where rn > 1
);
