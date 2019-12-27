create database rk;
\connect rk;
create schema rk3;

drop table if exists rk3.students;
drop table if exists rk3.teachers;

create table rk3.teachers
(
  id           serial primary key,
  name         text,
  department   text,
  max_students smallint
);

create table rk3.students
(
  id         serial primary key,
  name       text,
  birthday   date,
  department text,
  tutor_id   int references teachers (id) null
);

-- Подбор научного руководителя не определившимся студентам,
-- с учетом уже имеющейся занятости преподователя
create or replace procedure tutors_for_students() as
$$
declare
  student record;
  teacher int;
begin
  for student in select * from rk3.students where tutor_id isnull
    loop
      select teachers.id into teacher
      from rk3.teachers
             join rk3.students s on teachers.id = s.tutor_id
      group by teachers.id
      having count(s.id) < max_students
      limit 1;

      update rk3.students set tutor_id = teacher where id = student.id;
    end loop;
end
$$ language plpgsql;

insert into rk3.teachers(name, department, max_students)
VALUES ('Рудаков Игорь Владимирович', 'ИУ7', 6),
       ('Строганов Юрий Владимирович', 'ИУ7', 5),
       ('Куров Андрей Владимирович', 'ИУ7', 6),
       ('Скориков Татьяна Петровна', 'Л', 1);

insert into rk3.students(name, birthday, department, tutor_id)
VALUES ('Иванов Иван Иванович', '1990-09-25', 'ИУ', 1),
       ('Петров Петр Петрович', '1987-11-12', 'Л', null);

call tutors_for_students();

select *
from rk3.students;
select teachers.id,
       (select count(*) from rk3.students where tutor_id = teachers.id)
from rk3.teachers;