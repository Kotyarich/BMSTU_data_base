drop table if exists t1;
drop table if exists t2;

create table t1
(
    id              integer,
    var1            char,
    valid_from_dttm date,
    valid_to_dttm   date
);

create table t2
(
    id              integer,
    var2            char,
    valid_from_dttm date,
    valid_to_dttm   date
);

insert into t1
values (1, 'A', '2018-09-01', '2018-09-15'),
       (1, 'B', '2018-09-16', '5999-12-31');
insert into t2
values (1, 'A', '2018-09-01', '2018-09-18'),
       (1, 'B', '2018-09-19', '5999-12-31');

select * from t1;
select * from t2;

select t1.id, t1.var1, t2.var2, t1.valid_from_dttm, t1.valid_to_dttm
    from t1
    join t2 on t1.id = t2.id
    where t1.valid_from_dttm >= t2.valid_from_dttm
      and t1.valid_to_dttm <= t2.valid_to_dttm
union
select t1.id, t1.var1, t2.var2, t1.valid_from_dttm, t2.valid_to_dttm
    from t1
    join t2 on t1.id = t2.id
    where t1.valid_from_dttm >= t2.valid_from_dttm
      and t1.valid_to_dttm >= t2.valid_to_dttm
      and t1.valid_from_dttm < t2.valid_to_dttm
union
select t1.id, t1.var1, t2.var2, t2.valid_from_dttm, t1.valid_to_dttm
    from t1
    join t2 on t1.id = t2.id
    where t1.valid_from_dttm <= t2.valid_from_dttm
      and t1.valid_to_dttm <= t2.valid_to_dttm
      and t2.valid_from_dttm < t1.valid_to_dttm
union
select t1.id, t1.var1, t2.var2, t2.valid_from_dttm, t2.valid_to_dttm
    from t1
    join t2 on t1.id = t2.id
    where t1.valid_from_dttm <= t2.valid_from_dttm
      and t1.valid_to_dttm >= t2.valid_to_dttm
order by id, valid_from_dttm;
