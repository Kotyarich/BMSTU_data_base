from datetime import datetime
from pony.orm import *

db = Database()


class Airports(db.Entity):
    _table_ = ("bd_labs", "airports")
    id = PrimaryKey(int, auto=True)
    name = Required(str)
    country = Required(str)
    city = Required(str)
    departure_flights = Set(lambda: Flights, reverse='departure_airport_id')
    arrival_flights = Set(lambda: Flights, reverse='arrival_airport_id')


class Plains(db.Entity):
    _table_ = ("bd_labs", "planes")
    id = PrimaryKey(int, auto=True)
    model = Required(str)
    company = Required(str)
    number = Required(str)
    places = Required(int)
    flights = Set(lambda: Flights)


class Passengers(db.Entity):
    _table_ = ("bd_labs", "passengers")
    id = PrimaryKey(int, auto=True)
    name = Required(str)
    birthday = Required(str)
    sex = Required(str)
    passport_number = Required(str)
    tickets = Set(lambda: Tickets)


class Flights(db.Entity):
    _table_ = ("bd_labs", "flights")
    id = PrimaryKey(int, auto=True)
    plane_id = Required(Plains)
    departure_airport_id = Required(Airports, reverse='departure_flights')
    arrival_airport_id = Required(Airports, reverse='arrival_flights')
    departure_time = Required(datetime)
    arrival_time = Required(datetime)
    tickets = Set(lambda: Tickets)


class Tickets(db.Entity):
    _table_ = ("bd_labs", "tickets")
    id = PrimaryKey(int, auto=True)
    flight_id = Required(Flights)
    passenger_id = Required(Passengers)
    value = Required(str)
    place_class = Required(str)


db.bind(
    provider='postgres',
    user='kotyarich',
    password='1234',
    host='localhost',
    database='postgres'
)
db.generate_mapping()


@db_session
def get_passenger(name):
    """
    Однотабличный запрос
    :param name: имя пассажиров
    :return: все пассажиры с именем name
    """
    # noinspection PyTypeChecker
    return select((p.name, p.birthday, p.sex) for p in Passengers if
                  name in p.name).fetch()


@db_session
def get_passenger_tickets(passenger_id):
    """
    Многотабличный запрос
    :param passenger_id: id пассажира
    :return: все билеты пассажира
    """
    return select(t for t in Passengers[passenger_id].tickets).fetch()


@db_session
def insert_passenger(name, birthday, sex, passport):
    """
    Добавление пассажира
    :param name: имя пассажира
    :param birthday: день рождения пассажира в формате 'YYYY-DD-MM'
    :param sex: пол пассажира (m или f)
    :param passport: паспорт пассажира (строка из 10 цифр)
    :return: id созданного пассажира
    """
    p = Passengers(name=name, birthday=birthday, sex=sex,
                   passport_number=passport)
    commit()
    return p.id


@db_session
def change_passport(passenger_id, passport):
    """
    Изменение пасспорта пассажира
    :param passenger_id: id пассажира
    :param passport: новый пасспорт пассажира (строка из 10 цифр)
    """
    passenger = Passengers[passenger_id]
    passenger.passport_number = passport


@db_session
def delete_passenger(passenger_id):
    """
    Удаление пассажира
    :param passenger_id: id пассажира
    """
    Passengers[passenger_id].delete()


# noinspection PyUnusedLocal
@db_session
def get_company_flights(company_name):
    """
    Вызов хранимой процедуры
    Получение всех полетов компании
    :param company_name: имя компании
    :return: список полетов
    """
    return Flights.select_by_sql(
        'select * from bd_labs.company_flights($(company_name))'
    )


if __name__ == '__main__':
    print(get_passenger('Jon'))
    print(get_passenger_tickets(10))
    new_id = insert_passenger('name', '1999-09-09', 'm', '4612240333')
    print(new_id)
    change_passport(100, '1111222222')
    delete_passenger(new_id)
    print(get_company_flights('Pobeda'))
