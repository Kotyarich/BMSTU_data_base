-- 1)
drop database if exists RK2;
create database RK2;
\connect rk2

drop table if exists teacher_subject;
drop table if exists teacher;
drop table if exists department;
drop table if exists subject;
create table department
(
    id          serial primary key,
    name        text,
    description text
);

create table teacher
(
    id     serial primary key,
    dep_id int references department (id),
    name   text,
    grade  text,
    job    text
);

create table subject
(
    id       serial primary key,
    name     text,
    hours    int,
    semester int,
    rating   int
);

create table teacher_subject
(
    teacher_id serial references teacher (id),
    subject_id serial references subject (id)
);

insert into department(name, description)
values ('iu1', 'description1'),
       ('iu2', 'description2'),
       ('iu3', 'description3'),
       ('iu4', 'description4'),
       ('iu5', 'description5'),
       ('iu6', 'description6'),
       ('iu7', 'description7'),
       ('iu8', 'description8'),
       ('iu9', 'description9'),
       ('iu0', 'description0');

insert into teacher(dep_id, name, grade, job)
values (5, 'Ivanov Ivan Ivanovich', '1', 'teacher1'),
       (2, 'Ivanov Petr Ivanovich', '2', 'teacher1'),
       (3, 'Ivanov Nikita Ivanovich', '3', 'teacher1'),
       (4, 'Ivanov Andrew Ivanovich', '2', 'teacher2'),
       (1, 'Ivanov Nikolay Ivanovich', '1', 'teacher2'),
       (5, 'Ivanov Dmitriy Ivanovich', '4', 'teacher3'),
       (7, 'Ivanov Aleksey Ivanovich', '1', 'teacher3'),
       (6, 'Ivanov Aleksandr Ivanovich', '3', 'teacher2'),
       (8, 'Ivanov Evgeniy Ivanovich', '4', 'teacher1'),
       (9, 'Ivanov Ivan Ivanovich', '2', 'teacher3');

insert into subject(name, hours, semester, rating)
values ('s1', 120, 3, 99),
       ('s2', 100, 6, 99),
       ('s3', 100, 1, 39),
       ('s4', 80, 4, 99),
       ('s5', 100, 2, 69),
       ('s6', 100, 4, 59),
       ('s7', 90, 5, 99),
       ('s8', 100, 4, 49),
       ('s9', 60, 7, 79),
       ('s0', 50, 8, 99);

insert into teacher_subject
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

-- 2)
-- Инструкция SELECT, использующая предикат сравнения с квантором
-- Получает предмет (предметы, если их несколько с одинаковым рейтингом) с самым большим рейтингом
select *
from subject
where subject.rating >= ALL (
    select rating
    from subject
);

-- Инструкция SELECT, использующая аггрегатные функции в выражениях столбцов
-- Получает максимальный рейтинг предметов
select max(rating)
from subject;

-- Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT
-- Создает временную локальную таблицу с преподавателями, не ведущими предметы
select teacher.*
into temp free_teachers
from teacher
where 0 = (
    select count(*)
    from teacher_subject
    where teacher_id = id
);

select * from free_teachers;

-- 3)
-- Создать хранимую процедуру с входным параметром – "имя таблицы",
-- которая удаляет дубликаты записей из указанной таблицы в текущей
-- базе данных. Созданную процедуру протестировать.

create or replace procedure rem_duplicates(in t_name text)
    language plpgsql
as
$$
declare
    query text;
    col text;
    column_names text[];
begin
    query = 'delete from ' || t_name || ' where id in (' ||
                'select ' || t_name || '.id ' ||
                'from ' || t_name ||
                ' join (select id, row_number() over (partition by ';
    for col in select column_name from information_schema.columns where information_schema.columns.table_name=t_name loop
        query = query || col || ',';
    end loop;
    query = trim(trailing ',' from query);
    query = query || ') as rn from ' || t_name || ') as t on t.id = ' || t_name || '.id' ||
            ' where rn > 1)';
    raise notice '%', query;
    execute query;
end
$$;

-- Тестируем
-- Добавили дубликаты
insert into teacher(id, dep_id, name, grade, job)
select *
    from teacher
    where id < 5;

-- Вызвали процедуру
DO
$$
    begin
        call rem_duplicates('teacher');
    end;
$$;

-- "psql -a -f rk2_2.sql" в консоли чтобы запустить скрипт
