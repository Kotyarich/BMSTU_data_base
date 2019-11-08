-- Скалярная функция
drop function if exists bd_labs.avg_company_cost;

create function bd_labs.avg_company_cost(company_name text) returns money
as
$$
select sum(value) / count(*)
from bd_labs.tickets
         join bd_labs.flights on tickets.flight_id = flights.id
         join bd_labs.planes on flights.plane_id = planes.id
where company = company_name
$$
    language SQL
    stable
    returns null on null input;

select bd_labs.avg_company_cost('Pobeda');

-- Подставляемая табличная функция
drop function if exists bd_labs.company_flights;

create function bd_labs.company_flights(company_name text)
    returns table
            (
                id                integer,
                plane_id          integer,
                departure_airport integer,
                arrival_airport   integer,
                departure_time    timestamp,
                arrival_time      timestamp
            )
as
$$
select bd_labs.flights.*
from bd_labs.flights
         join bd_labs.planes on flights.plane_id = planes.id
where company = company_name
$$ language SQL
    stable
    returns null on null input;

-- Многооператорная табличная функция
drop function if exists bd_labs.p_company_flights;

create function bd_labs.p_company_flights(company_name text)
    returns table
            (
                id                integer,
                plane_id          integer,
                departure_airport integer,
                arrival_airport   integer,
                departure_time    timestamp,
                arrival_time      timestamp
            )
as
$$
begin
    return query select bd_labs.flights.*
                 from bd_labs.flights
                          join bd_labs.planes on flights.plane_id = planes.id
                 where company = company_name;
end;
$$ language plgpsql
    stable
    returns null on null input;

select *
from bd_labs.company_flights('Pobeda');

-- Рекурсивную функцию или функцию с рекурсивным ОТВ
drop function if exists bd_labs.flights_by_time(plane integer);

create function bd_labs.flights_by_time(plane integer)
    returns table
            (
                flight_id      integer,
                departure_time timestamp,
                flight_num     integer
            )
as
$$
with recursive all_airports_for_flight as (
    select flights.id, flights.departure_time as time, 1 as flight_num
    from bd_labs.flights
    where plane_id = plane
      and departure_time = (
        select max(departure_time)
        from bd_labs.flights
        where plane_id = plane)

    union all

    select flights.id, flights.departure_time, flight_num + 1
    from bd_labs.flights
             join all_airports_for_flight on flights.departure_time < all_airports_for_flight.time
    where plane_id = plane
      and departure_time in (
        select departure_time
        from bd_labs.flights
        where plane_id = plane
        order by departure_time desc
            offset flight_num
        limit 1
    )
)
select *
from all_airports_for_flight;
$$
    language SQL
    stable
    returns null on null input;

select *
from bd_labs.flights_by_time(107);

-------------------------------------------------------Процедуры--------------------------------------------------------

-- Хранимая процедура без параметров или с параметрами
drop procedure if exists bd_labs.delete_duplicates();

create procedure bd_labs.delete_duplicates()
    language sql
as
$$
delete
from bd_labs.tickets
where id in (
    select tickets.id
    from bd_labs.tickets
             join (select id, row_number() over (partition by flight_id, passenger_id, value, class) as rn
                   from bd_labs.tickets) as t on t.id = tickets.id
    where rn > 1
);
$$;

-- Рекурсивная хранимая процедура или хранимая процедура с рекурсивным ОТВ
create or replace procedure bd_labs.useless_recursive(n integer)
    language plpgsql as
$$
begin
    if (n < 10) then
        update bd_labs.tickets set value = value * 2 where id = n;
        call useless_recursive(n + 1);
    end if;
end;
$$;

-- Хранимая процедура с курсором
create or replace procedure bd_labs.up_tickets_cost(class char)
    language plpgsql
as
$$
declare
    curs cursor for select *
                    from bd_labs.tickets
                    where tickets.class = class;
begin
    update bd_labs.tickets set value = value * 2 where current of curs;
    close(curs);
end;
$$;

-- Хранимая процедура доступа к метаданным
create or replace procedure bd_labs.table_info(in name text)
    language plpgsql
as
$$
declare
    c record;
begin
    select table_catalog, table_schema into c from information_schema.columns where table_name = name;
    raise notice 'Catalog: %, schema: %', c.table_catalog, c.table_schema;
end
$$;

call bd_labs.table_info('tickets');

---------------------------------------------------Триггеры-------------------------------------------------------------

-- Триггер AFTER
create or replace function delete_empty_flight() returns trigger as
$delete_empty_flight$
declare
    tickets_number integer;
begin
    select count(*)
    into tickets_number
    from bd_labs.tickets
    where flight_id = OLD.flight_id;

    if (tickets_number = 0) then
        delete
        from bd_labs.flights
        where flights.id = old.flight_id;
    end if;

    return null;
end;
$delete_empty_flight$ language plpgsql;

create trigger check_number
    after delete
    on bd_labs.tickets
execute procedure delete_empty_flight();

-- Триггер INSTEAD OF
drop view if exists bd_labs.passengers_view;
create view bd_labs.passengers_view as
select passengers.*, count(t.id)
from bd_labs.passengers
         join bd_labs.tickets as t on t.passenger_id = passengers.id
group by passengers.id;

create or replace function update_pass_view() returns trigger as
$update_pass_view$
declare
    tickets_number integer;
begin
    insert into bd_labs.passengers(name, birthday, sex, passport_number)
    VALUES (initcap(name), new.birthday, new.sex, new.passport_number);

    select count(*)
    into tickets_number
    from bd_labs.passengers
             join bd_labs.tickets on tickets.passenger_id = passengers.id
    where passenger_id = new.id;

    insert into bd_labs.passengers_view
    values (new.id, tickets_number);

    return new;
end;
$update_pass_view$ language plpgsql;

create trigger check_number
    instead of insert
    on bd_labs.passengers_view
    for each row
execute procedure update_pass_view();


create or replace function show_old_and_new() returns trigger as
$show_old_and_new$
-- declare
--     t text;
begin
--     select old.id into t;
--     raise notice '%', t;
    raise notice 'Old: id: %, model: %, company: %s, number: %, places: %', old.id, old.model, old.company, old.number, old.places;
    raise notice 'New: id: %, model: %, company: %, number: %, places: %', new.id, new.model, new.company, new.number, new.places;

    return null;
end;
$show_old_and_new$ language plpgsql;

drop trigger show_old_and_new_trigger
    on bd_labs.planes;
create trigger show_old_and_new_trigger
    after update
    on bd_labs.planes for each row
execute procedure show_old_and_new();

update bd_labs.planes
set places = 10011
where id = 22;