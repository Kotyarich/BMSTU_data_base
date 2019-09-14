create schema if not exists bd_labs;

drop table if exists bd_labs.Airports cascade;
drop table if exists bd_labs.Planes cascade;
drop table if exists bd_labs.Flights cascade;
drop table if exists bd_labs.Passengers cascade;
drop table if exists bd_labs.Tickets cascade;

create table bd_labs.Airports (
    id      serial primary key,
    name    varchar(50) not null,
    country varchar(100) not null,
    city    varchar(50) not null
);

create table bd_labs.Planes (
    id      serial primary key,
    model   varchar(50) not null,
    company varchar(50),
    number  varchar(30) not null,
    places  int not null
);

create table bd_labs.Flights (
    id                   serial primary key,
    plane_id             serial not null references bd_labs.Planes(id),
    departure_airport_id serial not null references bd_labs.Airports(id),
    arrival_airport_id   serial not null references bd_labs.Airports(id),
    departure_time       timestamp not null,
    arrival_time         timestamp not null
);

create table bd_labs.Passengers (
    id              serial primary key,
    name            varchar(50) not null,
    birthday        date not null,
    sex             char not null,
    passport_number varchar(10) not null
);

create table bd_labs.Tickets (
    id              serial primary key,
    flight_id       serial not null references bd_labs.Flights(id),
    passenger_id    serial not null references bd_labs.Passengers(id),
    value           money not null,
    class           char not null
)