drop table if exists numbers;

create table numbers (
    num int
);

insert into numbers VALUES (-1), (2), (3), (4);

with recursive r as (
    select
        0 as i,
        1 as product

    union all

    select
        i+1 as i,
        product * (select num
                    from numbers
                    offset i limit 1)
    from r
    where i < (select count(*) from numbers)
)

select product from r order by i desc limit 1;
