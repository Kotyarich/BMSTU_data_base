-- XML Schemas типа как из Visual Studio
select table_to_xmlschema((select oid from pg_class where relname = 'airports'), true, true, ''::text);
select table_to_xmlschema((select oid from pg_class where relname = 'flights'), true, true, ''::text);
select table_to_xmlschema((select oid from pg_class where relname = 'passengers'), true, true, ''::text);
select table_to_xmlschema((select oid from pg_class where relname = 'tickets'), true, true, ''::text);
select table_to_xmlschema((select oid from pg_class where relname = 'plains'), true, true, ''::text);