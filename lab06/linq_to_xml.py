from py_linq import Enumerable
import dict2xml
from bs4 import BeautifulSoup


def get_table(file_name):
    with open(file_name) as f:
        soup = BeautifulSoup(f, 'xml')

    rows = soup.find_all('row')
    res = []
    for row in rows:
        row_dict = {}
        for child in row:
            if child == '\n':
                continue
            row_dict.update({child.name: child.text})
        res.append(row_dict)

    return res


def get_count(table):
    return Enumerable(table).count()


def dict_to_row(row_dict):
    xml_title = 'row'
    xml_body = [dict2xml.dict2xml({attr: row_dict[attr]}) for attr in row_dict]
    return '<{0}>{1}</{0}>'.format(xml_title, ''.join(xml_body))


def add_airport(file_name, airport):
    with open(file_name) as f:
        soup = BeautifulSoup(f, 'xml')

    raw_row = dict_to_row(airport)
    row = BeautifulSoup(raw_row, 'xml')

    soup.airports.append(row)
    with open(file_name, 'w') as f:
        f.write(soup.prettify())


def replace_airport(file_name):
    with open(file_name) as f:
        soup = BeautifulSoup(f, 'xml')

    soup.row.city.string = 'Moscow'

    with open(file_name, 'w') as f:
        f.write(soup.prettify())


if __name__ == '__main__':
    file_name = 'airports.xml'
    table = get_table(file_name)
    print(get_count(table))
    add_airport(
        file_name,
        {'id': 1002, 'name': 'name', 'country': 'Finland', 'city': 'city'}
    )
    replace_airport(file_name)
