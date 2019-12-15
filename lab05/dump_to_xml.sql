COPY (SELECT table_to_xml('bd_labs.airports', false, false, '')) to '/home/kotyarich/Dev/bmstu/bd/lab05/airports.xml';
COPY (SELECT table_to_xml('bd_labs.flights', true, false, '')) to '/home/kotyarich/Dev/bmstu/bd/lab05/flights.xml';
COPY (SELECT table_to_xml('bd_labs.passengers', true, false, '')) to '/home/kotyarich/Dev/bmstu/bd/lab05/passengers.xml';
COPY (SELECT table_to_xml('bd_labs.planes', true, false, '')) to '/home/kotyarich/Dev/bmstu/bd/lab05/planes.xml';
COPY (SELECT table_to_xml('bd_labs.tickets', true, false, '')) to '/home/kotyarich/Dev/bmstu/bd/lab05/tickets.xml';

COPY (SELECT ROW_TO_JSON(t) FROM (SELECT * FROM bd_labs.airports) t)  to '/home/kotyarich/Dev/bmstu/bd/lab05/airports.json';
COPY (SELECT ROW_TO_JSON(t) FROM (SELECT * FROM bd_labs.flights) t) to '/home/kotyarich/Dev/bmstu/bd/lab05/flights.json';
COPY (SELECT ROW_TO_JSON(t) FROM (SELECT * FROM bd_labs.passengers) t) to '/home/kotyarich/Dev/bmstu/bd/lab05/passengers.json';
COPY (SELECT ROW_TO_JSON(t) FROM (SELECT * FROM bd_labs.planes) t) to '/home/kotyarich/Dev/bmstu/bd/lab05/planes.json';
COPY (SELECT ROW_TO_JSON(t) FROM (SELECT * FROM bd_labs.tickets) t) to '/home/kotyarich/Dev/bmstu/bd/lab05/tickets.json';