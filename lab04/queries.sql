CREATE EXTENSION plpythonu;

-- Определяемую пользователем скалярную функцию
create or replace function bd_labs.avg_company_cost(company_name text) returns money as
$$
query = 'select value::numeric from bd_labs.tickets'
'join bd_labs.flights on tickets.flight_id = flights.id'
'join bd_labs.planes on flights.plane_id = planes.id'
'where company = ' + company_name
cursor = plpy.cursor(query)
sum = 0
number = 0
while True:
    rows = cursor.fetch(100)
    if not rows:
        break
    for row in rows:
        number += 1
        print(row['value'])
        sum += int(row['value'])
return sum / number
$$ language plpythonu;

select bd_labs.avg_company_cost('Pobeda');

-- Пользовательскую агрегатную функцию
create or replace function avg_state(prev numeric[2], next numeric) returns numeric[2] as
$$
return prev if next == 0 or next == None else [0 if prev[0] == None else prev[0] + next, prev[1] + 1]
$$ language plpythonu;

create or replace function avg_final(num numeric[2]) returns numeric as
$$
return 0 if num[1] == 0 else num[0] / num[1]
$$ language plpythonu;

drop aggregate if exists my_avg(numeric);
create aggregate my_avg(numeric) (
    sfunc = avg_state,
    stype =numeric[],
    finalfunc =avg_final,
    initcond = '{0,0}'
    );

select my_avg(value::numeric)::money
from bd_labs.tickets
         join bd_labs.flights on tickets.flight_id = flights.id
         join bd_labs.planes on flights.plane_id = planes.id
where company = 'S7';

-- Определяемую пользователем табличную функцию
drop function bd_labs.company_flights(company_name text, lim integer);
create or replace function bd_labs.company_flights(company_name text, lim int)
    returns table
            (
                id             integer,
                plane_id       integer,
                departure_time timestamp,
                arrival_time   timestamp
            )
as
$$
query = 'select bd_labs.flights.* from bd_labs.flights '
'join bd_labs.planes on flights.plane_id = planes.id '
'where company = {} order by departure_time'
result = plpy.execute(query.format(company_name), lim)
return [(r['id'], r['plane_id'], r['departure_time'], r['arrival_time']) for r in result]
$$ language plpythonu;

select bd_labs.company_flights('Pobeda', 10);

-- Хранимую процедуру
create or replace procedure bd_labs.triple(inout a int, inout b int) as
$$ return [a * 3, b * 3]
$$ language plpythonu;

do
$$
    declare
        a int;
        b int;
    begin
        a = 1;
        b = 2;
        call bd_labs.triple(a, b);
        raise notice '%, %', a, b;
    end;
$$;

-- Триггер
create or replace function delete_empty_flight() returns trigger as
$delete_empty_flight$
query = 'select count(*) from bd_labs.tickets where flight_id = {}'
old_flight_id = TD["new"]["flight_id"]
count = plpy.execute(query.format(old_flight_id), 1)
if count == 0:
    del_query = 'delete from bd_labs.flights where flights.id = {}'
    plpy.execute(del_query, 0)
return None;
$delete_empty_flight$
    language plpythonu;

drop trigger check_number on bd_labs.tickets;
create trigger check_number
    after delete
    on bd_labs.tickets
    for each row
execute procedure delete_empty_flight();

delete
from bd_labs.tickets
where id = 3;

-- Определяемый пользователем тип
create type plane; -- "(model, places)"

create or replace function plane_in(cstring) returns plane
as
'plane.so',
'plane_in'
    language C immutable
               strict;

create or replace function plane_out(plane) returns cstring
as
'$libdir/plane',
'plane_out'
    language C immutable
               strict;

drop type plane cascade;
create type plane (
    internallength = 34,
    input = plane_in,
    output = plane_out
    );

select '(Superjet, 2300)'::plane;