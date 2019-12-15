-- "psql -a -f rk2.sql" to run
------------------------------- Task 1 ---------------------------------------------------------------------------------
drop database if exists RK2;
create database RK2;
\connect rk2

create table customers
(
    id           serial primary key,
    name         text,
    birthday     date,
    city         text,
    phone_number text
);

create table florists
(
    id              serial primary key,
    name            text,
    passport_number text,
    phone_number    text
);

create table florists_customers
(
    florist_id  serial references florists (id),
    customer_id serial references customers (id)
);

create table bouquets
(
    id        serial primary key,
    author_id serial references florists (id),
    name      text
);

insert into customers(name, birthday, city, phone_number)
values ('Ivanov Ivan Ivanovich', '1987-1-1', 'Moscow', '89123456789'),
       ('Ivanov Petr Ivanovich', '1967-5-11', 'Yaroslawl', '89523456789'),
       ('Ivanov Nikita Ivanovich', '1977-1-10', 'Moscow', '89123756789'),
       ('Ivanov Andrew Ivanovich', '1987-1-1', 'Moscow', '89123156789'),
       ('Ivanov Nikolay Ivanovich', '1987-2-1', 'Moscow', '89123256789'),
       ('Ivanov Dmitriy Ivanovich', '1987-3-1', 'Samara', '89123756789'),
       ('Ivanov Aleksey Ivanovich', '1987-4-1', 'Moscow', '89123459789'),
       ('Ivanov Aleksandr Ivanovich', '1987-5-1', 'Volgograd', '89123456789'),
       ('Ivanov Evgeniy Ivanovich', '1987-6-3', 'Orsk', '89123456189'),
       ('Ivanov Ivan Ivanovich', '1987-1-2', 'Moscow', '89123356789');

insert into florists(name, passport_number, phone_number)
VALUES ('Ivanov Ivan Ivanovich', '4613123123', '89123456789'),
       ('Ivanov Petr Ivanovich', '4613125123', '89123656789'),
       ('Ivanov Nikita Ivanovich', '4613123223', '89123556789'),
       ('Ivanov Andrew Ivanovich', '4613623123', '89123456789'),
       ('Ivanov Nikolay Ivanovich', '4617823123', '89223456789'),
       ('Ivanov Dmitriy Ivanovich', '4613121123', '89124456789'),
       ('Ivanov Aleksey Ivanovich', '4613134123', '89129956789'),
       ('Ivanov Ebgeniy Ivanovich', '4619923123', '89193456789'),
       ('Ivanov Ivan Ivanovich', '4613123553', '89123411789'),
       ('Ivanov Ivan Ivanovich', '4617773123', '89123226789');

insert into florists_customers
values (1, 3),
       (2, 4),
       (1, 5),
       (6, 3),
       (1, 8),
       (3, 6),
       (5, 5),
       (4, 3),
       (9, 9),
       (9, 1);

insert into bouquets(author_id, name)
values (1, 'name1'),
       (4, 'name2'),
       (1, 'name3'),
       (7, 'name4'),
       (2, 'name5'),
       (3, 'name6'),
       (9, 'name7'),
       (8, 'name8'),
       (6, 'name9'),
       (4, 'name10');

------------------------------- Task 2 ---------------------------------------------------------------------------------
-- Инструкция SELECT, использующая поисковое выражение CASE
-- Получает id, ФИО и количество букетов каждого флориста, если букетов нет,
-- то вместо количеста 'There aren't any bouquets'
select florists.id,
       florists.name,
       case
           when (select count(*) from bouquets where author_id = florists.id) = 0
               then 'There aren''t any bouquets'
           else (select count(*) from bouquets where author_id = florists.id)::text
           end bouquests
from florists
group by florists.id, florists.name;

-- Инструкция UPDATE со скалярным подзапросом в предложении SET
-- Заменяет florist_id на id флориста с номером паспорта '4619923123'
update florists_customers
set florist_id = (
    select florists.id
    from florists
    where florists.passport_number = '4619923123'
)
where florist_id = 1;

-- Инструкцию SELECT, консолидирующую данные с помощью предложения GROUP BY и предложения HAVING
-- Получает id флористов с количеством букетов большим 2
select florists.id
from florists
         join florists_customers fc on florists.id = fc.florist_id
group by florists.id
having count(*) > 2;

------------------------------- Task 3 ---------------------------------------------------------------------------------
-- Создать хранимую процедуру с входным параметром – имя базы данных,
-- которая выводит имена ограничений CHECK и выражения SQL, которыми
-- определяются эти ограничения CHECK, в тексте которых на языке SQL
-- встречается предикат 'LIKE'. Созданную хранимую процедуру
-- протестировать.
create extension dblink;
create or replace procedure get_like_constraints(in data_base_name text)
    language plpgsql
as
$$
declare
    constraint_rec record;
begin
    for constraint_rec in select *
                          from dblink(concat('dbname=', data_base_name, ' options=-csearch_path='),
                                      'select conname, consrc
                                      from pg_constraint
                                      where contype = ''c''
                                          and (lower(consrc) like ''% like %'' or consrc like ''% ~~ %'')')
                                   as t1(con_name varchar, con_src varchar)
        loop
            raise info 'Name: %, src: %', constraint_rec.con_name, constraint_rec.con_src;
        end loop;
end
$$;

-- Тестируем
-- Добавили ограничение с like
alter table customers
    add constraint a_in_name check ( name like '%a%');
-- Вызвали процедуру
DO
$$
    begin
        call get_like_constraints('rk2');
    end;
$$;