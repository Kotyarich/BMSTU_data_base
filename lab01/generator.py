import datetime
import random
import faker as f

faker = f.Faker()


def generate_airports(number):
    airports = []
    for i in range(number):
        name = faker.city()
        city = faker.city()
        country = faker.country()
        airports.append((i, name, country, city))
    return airports


def generate_planes(number):
    planes = []
    for i in range(number):
        model = random.choice(
            ('Boeing 777-300ER',
             'Boeing 737-800',
             'Airbus А330-200',
             'Airbus А330-300',
             'Airbus А321',
             'Airbus A320',
             'Sukhoi SuperJet 100')
        )
        company = random.choice(
            ('Red WIngs',
             'Aeroflot',
             'Ural Airlines',
             'Pobeda',
             'S7')
        )
        places = random.randint(5, 300)
        number = ''.join([chr(random.randint(98, 122)) for i in range(7)])
        planes.append((i, model, company, number, places))
    return planes


def generate_passengers(number):
    passengers = []
    for i in range(number):
        name = faker.name()
        birthday = faker.date_of_birth().strftime('%Y-%m-%d')
        sex = random.choice(('m', 'f'))
        passport_number = ''.join([str(random.randint(0, 9)) for i in range(10)])
        passengers.append((i, name, birthday, sex, passport_number))
    return passengers


def generate_flights(number, planes_number, airports_number):
    flights = []
    for i in range(number):
        plane_id = random.randint(0, planes_number - 1)
        dep_airport_id = random.randint(0, airports_number - 1)
        arr_airport_id = random.randint(0, airports_number - 1)
        while dep_airport_id == arr_airport_id:
            arr_airport_id = random.randint(0, airports_number - 1)
        departure = faker.date_time()
        duration = datetime.timedelta(hours=random.randint(1, 10))
        arrival = departure + duration
        flights.append(
            (i, plane_id, dep_airport_id, arr_airport_id, departure, arrival)
        )
    return flights


def generate_tickets(number, flights_number, passengers_number):
    tickets = []
    for i in range(number):
        flight_id = random.randint(0, flights_number - 1)
        pass_id = random.randint(0, passengers_number - 1)
        value = '{},00'.format(random.randint(50, 5000))
        place_class = chr(random.randint(98, 122))
        tickets.append((i, flight_id, pass_id, value, place_class))
    return tickets


if __name__ == '__main__':
    number = 1000
    with open('airports.txt', 'w') as f:
        airports = generate_airports(number)
        for i in range(number):
            f.write('{}|{}|{}|{}\n'.format(*airports[i]))

    with open('planes.txt', 'w') as f:
        planes = generate_planes(number)
        for i in range(number):
            f.write('{}|{}|{}|{}|{}\n'.format(*planes[i]))

    with open('passengers.txt', 'w') as f:
        passengers = generate_passengers(number)
        for i in range(number):
            f.write('{}|{}|{}|{}|{}\n'.format(*passengers[i]))

    with open('flights.txt', 'w') as f:
        flights = generate_flights(number, number, number)
        for i in range(number):
            f.write('{}|{}|{}|{}|{}|{}\n'.format(*flights[i]))

    with open('tickets.txt', 'w') as f:
        tickets = generate_tickets(number, number, number)
        for i in range(number):
            f.write('{}|{}|{}|{}|{}\n'.format(*tickets[i]))
