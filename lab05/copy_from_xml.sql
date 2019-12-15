-- Insert from json
truncate table bd_labs.passengers cascade;
truncate table bd_labs.airports cascade;
truncate table bd_labs.planes cascade;
truncate table bd_labs.tickets cascade;
truncate table bd_labs.flights cascade;

drop table if exists temp_json;
create or replace function fill_json(in t_name varchar, in f_path varchar) returns void
    language plpgsql
as
$$
declare
    create_tmp_table text;
    copy_query       text;
    insert_query     text;
begin
    create_tmp_table = 'create temporary table temp_json (values json) on commit drop;';
    execute create_tmp_table;
    copy_query = 'copy temp_json from ''' || f_path || ''';';
    execute copy_query;
    insert_query = 'insert into ' || t_name || ' (select p.* from temp_json cross join json_populate_record(null::' ||
                   t_name || ', values) as p);';
    execute insert_query;
end
$$;

select fill_json('bd_labs.passengers', '/home/kotyarich/Dev/bmstu/bd/lab05/passengers.json');
select fill_json('bd_labs.airports', '/home/kotyarich/Dev/bmstu/bd/lab05/airports.json');
select fill_json('bd_labs.planes', '/home/kotyarich/Dev/bmstu/bd/lab05/planes.json');
select fill_json('bd_labs.flights', '/home/kotyarich/Dev/bmstu/bd/lab05/flights.json');
select fill_json('bd_labs.tickets', '/home/kotyarich/Dev/bmstu/bd/lab05/tickets.json');

-- Insert from XML
truncate table bd_labs.passengers cascade;
truncate table bd_labs.airports cascade;
truncate table bd_labs.planes cascade;
truncate table bd_labs.tickets cascade;
truncate table bd_labs.flights cascade;

INSERT INTO bd_labs.airports
  SELECT (xpath('//row/id/text()', x))[1]::text::int AS id,
         (xpath('//row/name/text()', x))[1]::text AS name,
         (xpath('//row/country/text()', x))[1]::text AS country,
         (xpath('//row/city/text()', x))[1]::text AS city
  FROM unnest(xpath('//row', pg_read_file('/home/kotyarich/Dev/bmstu/bd/lab05/airports.xml'::text, 0,
      (select size from pg_stat_file('/home/kotyarich/Dev/bmstu/bd/lab05/airports.xml'))-3)::xml)) x;

INSERT INTO bd_labs.planes
  SELECT (xpath('//row/id/text()', x))[1]::text::int AS id,
         (xpath('//row/model/text()', x))[1]::text AS model,
         (xpath('//row/company/text()', x))[1]::text AS company,
         (xpath('//row/number/text()', x))[1]::text AS number,
         (xpath('//row/places/text()', x))[1]::text::int AS places
  FROM unnest(xpath('//row', pg_read_file('/home/kotyarich/Dev/bmstu/bd/lab05/planes.xml'::text, 0,
      (select size from pg_stat_file('/home/kotyarich/Dev/bmstu/bd/lab05/planes.xml'))-3)::xml)) x;

INSERT INTO bd_labs.passengers
  SELECT (xpath('//row/id/text()', x))[1]::text::int AS id,
         (xpath('//row/name/text()', x))[1]::text AS name,
         (xpath('//row/birthday/text()', x))[1]::text::date AS birthday,
         (xpath('//row/sex/text()', x))[1]::text AS sex,
         (xpath('//row/passport_number/text()', x))[1]::text AS passport_number
  FROM unnest(xpath('//row', pg_read_file('/home/kotyarich/Dev/bmstu/bd/lab05/passengers.xml'::text, 0,
      (select size from pg_stat_file('/home/kotyarich/Dev/bmstu/bd/lab05/passengers.xml'))-3)::xml)) x;

INSERT INTO bd_labs.flights
  SELECT (xpath('//row/id/text()', x))[1]::text::int AS id,
         (xpath('//row/plane_id/text()', x))[1]::text::int AS plane_id,
         (xpath('//row/departure_airport_id/text()', x))[1]::text::int AS dai,
         (xpath('//row/arrival_airport_id/text()', x))[1]::text::int AS aai,
         (xpath('//row/departure_time/text()', x))[1]::text::timestamp AS at,
         (xpath('//row/arrival_time/text()', x))[1]::text::timestamp AS dt
  FROM unnest(xpath('//row', pg_read_file('/home/kotyarich/Dev/bmstu/bd/lab05/flights.xml'::text, 0,
      (select size from pg_stat_file('/home/kotyarich/Dev/bmstu/bd/lab05/flights.xml'))-3)::xml)) x;

INSERT INTO bd_labs.tickets
  SELECT (xpath('//row/id/text()', x))[1]::text::int AS id,
         (xpath('//row/flight_id/text()', x))[1]::text::int AS fl,
         (xpath('//row/passenger_id/text()', x))[1]::text::int AS pass,
         (xpath('//row/value/text()', x))[1]::text::money AS val,
         (xpath('//row/class/text()', x))[1]::text::char AS cl
  FROM unnest(xpath('//row', pg_read_file('/home/kotyarich/Dev/bmstu/bd/lab05/tickets.xml'::text, 0,
      (select size from pg_stat_file('/home/kotyarich/Dev/bmstu/bd/lab05/tickets.xml'))-3)::xml)) x;