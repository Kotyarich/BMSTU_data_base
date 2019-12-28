# coding=utf-8
import re

from sqlalchemy import create_engine, MetaData, text
from sqlalchemy.orm import mapper, Session

db_string = 'postgresql://kotyarich:1234@localhost:5432/postgres'
engine = create_engine(db_string)
meta = MetaData()
meta.reflect(bind=engine, schema='bd_labs')


class Plane(object):
    def __init__(self, model, company, number, places):
        self.model = model
        self.company = company
        self.number = number
        self.places = places


class Airport(object):
    def __init__(self, name, country, city):
        self.name = name
        self.country = country
        self.city = city


class Passengers(object):
    def __init__(self, name, birthday, sex, passport_number):
        self.name = name
        self.birthday = birthday
        self.sex = sex
        self.passport_number = passport_number


class Flight(object):
    def __init__(self, departure_time, arrival_time):
        self.departure_time = departure_time
        self.arrival_time = arrival_time


class Ticket(object):
    def __init__(self, passenger, flight, value, place_class):
        self.passenger_id = passenger.id
        self.flight_id = flight.id
        self.value = value
        self.place_class = place_class

    def __repr__(self):
        return 'id: {}, value: {}, class: {}, passenger: {}, flight: {}'.format(
            self.id, self.value, self.place_class,
            self.passenger_id, self.flight_id
        )


mapper(Plane, meta.tables['bd_labs.planes'])
mapper(Airport, meta.tables['bd_labs.airports'])
mapper(Passengers, meta.tables['bd_labs.passengers'])
mapper(Flight, meta.tables['bd_labs.flights'])
mapper(Ticket, meta.tables['bd_labs.tickets'])


# Analogs of connected objects
def engine_info():
    print('name: {}, driver: {}, url: {}'.format(
        engine.name, engine.driver, engine.url
    ))


def count_passengers():
    conn = Session(bind=engine)
    count = conn.execute(
        text('select count(*) from bd_labs.passengers')
    ).fetchone()[0]
    conn.close()
    print(count)


def avg_company_tickets_value(company):
    conn = Session(bind=engine)
    query = text('select avg(value::numeric)::money '
                 'from bd_labs.tickets '
                 'join bd_labs.flights on tickets.flight_id = flights.id '
                 'join bd_labs.planes on flights.plane_id = planes.id '
                 'where company = :company').bindparams(company=company)

    avg_val = conn.execute(query).fetchone()[0]
    conn.close()
    print('{}'.format(avg_val))


def company_flights_with_function(company, lim):
    conn = Session(bind=engine)
    query = text('select * '
                 'from bd_labs.company_flights(:company, :lim)')
    query = query.bindparams(
        company=company, lim=lim
    )

    flights = conn.execute(query).fetchall()
    conn.close()
    for flight in flights:
        print('id: {}, plane: {}, dep time: {}, arr time: {}'.format(
            flight.id, flight.plane_id,
            flight.arrival_time, flight.departure_time,
        ))


def call_remove_duplicates_proc():
    conn = Session(bind=engine)
    query = text('call bd_labs.delete_duplicates()')
    conn.execute(query)
    conn.close()

    # Analogs of disconnected objects


def tickets_cheaper_than(value):
    """Билеты с ценой меньше value"""
    conn = Session(bind=engine)
    data = conn.query(Ticket).filter(text('value::numeric < :value')) \
        .params(value=value).all()
    conn.close()

    for ticket in data:
        print(ticket)


def cheapest_ticket():
    """Самый дешевый билет"""
    conn = Session(bind=engine)
    ticket = conn.query(Ticket).order_by(Ticket.value).first()
    conn.close()
    print(ticket)


def is_passenger_exist(name):
    """Существует ли пассажир с именем name"""
    conn = Session(bind=engine)
    passengers = conn.query(Passengers).filter(Passengers.name == name).all()
    conn.close()
    answer = 'Yes' if passengers else 'No'
    print(answer)


def add_passenger(name, sex, birthday, passport):
    """Добавление пассажира"""
    conn = Session(bind=engine)
    conn.add(Passengers(name, birthday, sex, passport))
    conn.commit()
    conn.close()


def update_passenger_name(passenger_id, name):
    """Изменить имя пассажира с id равным passenger_id на name"""
    conn = Session(bind=engine)
    passenger = conn.query(Passengers) \
        .filter(Passengers.id == passenger_id).first()
    passenger.name = name
    conn.commit()
    conn.close()


def show_menu():
    menu = 'Действия с отсоединенными объектами: \n' \
           '\t1. Информация о подключении к БД\n' \
           '\t2. Количество пассажиров в БД\n' \
           '\t3. Средняя цена билетов компании\n' \
           '\t4. Список первых k самых ранних полетов компании\n' \
           '\t5. Удалить дубликаты среди билетов\n' \
           'Действия с подсоединенными объектами: \n' \
           '\t6. Билеты, дешевле определенной цены\n' \
           '\t7. Самый дешевый билет\n' \
           '\t8. Существует ли пассажир с определенным именем\n' \
           '\t9. Добавить пассажира\n' \
           '\t10. Изменить имя пассажира\n' \
           '11. Выход'
    print(menu)

    try:
        act = int(input('Введите действие: '))
        while act < 1 or act > 11:
            print(menu)
            print('Неверное действие')
            act = int(input('Введите действие: '))
    except ValueError:
        print('Неверное действие')
        act = show_menu()

    return act


def get_int(prompt):
    try:
        val = int(input(prompt))
        while val < 0:
            print('Нужно ввести целое неотрицательное число')
            val = int(input(prompt))
    except ValueError:
        print('Нужно ввести целое положительно число')
        val = get_int(prompt)

    return val


def get_passenger_data():
    name = input('Введите имя: ')
    sex = input('Введите пол (m или f): ')
    while sex != 'm' or sex != 'f':
        sex = input('Введите пол (m или f): ')
    birthday = input('Введите дату в формате YYYY-MM-DD: ')
    while not re.match(r'^\d\d\d\d-\d\d-\d\d$', birthday):
        birthday = input('Введите дату в формате YYYY-MM-DD: ')
    passport = input('Введите номер паспорта (10 чисел): ')
    while (not len(passport) == 10) or (not passport.isdigit()):
        passport = input('Введите номер паспорта (10 чисел): ')

    return name, sex, birthday, passport


def action(act):
    if act == 1:
        engine_info()
    elif act == 2:
        count_passengers()
    elif act == 3:
        company = input('Введите название компании: ')
        avg_company_tickets_value(company)
    elif act == 4:
        company = input('Введите название компании: ')
        lim = get_int('Введите количество требуемых записей: ')
        company_flights_with_function(company, lim)
    elif act == 5:
        call_remove_duplicates_proc()
    elif act == 6:
        val = get_int('Введите цену: ')
        tickets_cheaper_than(val)
    elif act == 7:
        cheapest_ticket()
    elif act == 8:
        name = input('Введите имя: ')
        is_passenger_exist(name)
    elif act == 9:
        name, sex, birthday, passport = get_passenger_data()
        add_passenger(name, sex, birthday, passport)
    elif act == 10:
        passenger_id = get_int('Введите id пассажира: ')
        name = input('Введите новое имя пассажира: ')
        update_passenger_name(passenger_id, name)

    print()


if __name__ == '__main__':
    while True:
        inp = show_menu()
        if inp == 11:
            break
        action(inp)
