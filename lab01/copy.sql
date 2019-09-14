truncate table bd_labs.passengers cascade;
truncate table bd_labs.airports cascade;
truncate table bd_labs.planes cascade;
truncate table bd_labs.tickets cascade;
truncate table bd_labs.flights cascade;

copy bd_labs.airports
    from '/home/kotyarich/Dev/bmstu/bd/lab01/airports.txt'   (delimiter '|');
copy bd_labs.passengers
    from '/home/kotyarich/Dev/bmstu/bd/lab01/passengers.txt' (delimiter '|');
copy bd_labs.planes
    from '/home/kotyarich/Dev/bmstu/bd/lab01/planes.txt'     (delimiter '|');
copy bd_labs.flights
    from '/home/kotyarich/Dev/bmstu/bd/lab01/flights.txt'    (delimiter '|');
copy bd_labs.tickets
    from '/home/kotyarich/Dev/bmstu/bd/lab01/tickets.txt'    (delimiter '|');
