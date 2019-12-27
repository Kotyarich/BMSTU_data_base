# coding=utf-8
import psycopg2
from py_linq import Enumerable
from psycopg2.extras import DictConnection, DictCursor

conn = psycopg2.connect(dbname="postgres",
                        user="kotyarich",
                        password="1234",
                        host="localhost",
                        connection_factory=DictConnection,
                        cursor_factory=DictCursor)


def task1_way1():
    query = "select department " \
            "from (select department, count(id) as cnt " \
            "       from rk3.students " \
            "       where tutor_id isnull " \
            "       group by department) as dc " \
            "order by cnt desc " \
            "limit 1"

    cursor = conn.cursor(cursor_factory=DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    cursor.close()

    return result


def task1_way2():
    cursor = conn.cursor(cursor_factory=DictCursor)
    cursor.execute("select * from rk3.students")

    filtered = Enumerable(cursor.fetchall()) \
        .where(lambda s: s["tutor_id"] is None).to_list()

    departments = {}
    for student in filtered:
        if student["department"] in departments:
            departments[student["department"]] += 1
        else:
            departments[student["department"]] = 1

    if not departments.items():
        return []
    return departments.items().sort(key=lambda x: x[1])[-1]


def task2_way1():
    query = "select rk3.students.* " \
            "from rk3.students " \
            "join rk3.teachers on tutor_id = teachers.id " \
            "where teachers.name = 'Рудаков Игорь Владимирович' " \
            "and extract(year from birthday) = 1990"

    cursor = conn.cursor(cursor_factory=DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    cursor.close()

    return result


def task2_way2():
    cursor = conn.cursor(cursor_factory=DictCursor)
    cursor.execute("select * from rk3.students")
    students = cursor.fetchall()

    cursor.execute("select * from rk3.teachers")
    teachers = cursor.fetchall()
    cursor.close()

    result = Enumerable(students) \
        .join(Enumerable(teachers),
              lambda s: s['tutor_id'],
              lambda t: t['id'],
              lambda res: res) \
        .where(lambda r: r[1]['name'] == 'Рудаков Игорь Владимирович') \
        .where(lambda r: r[0]['birthday'].year == 1990) \
        .select(lambda r: r[0])

    return result


def task3_way1():
    query = "select rk3.teachers.* " \
            "from rk3.teachers " \
            "where department = 'Л' and max_students = (" \
            "   select count(*)" \
            "   from students" \
            "   where tutor_id = rk3.teachers.id" \
            ")"

    cursor = conn.cursor(cursor_factory=DictCursor)
    cursor.execute(query)
    result = cursor.fetchall()
    cursor.close()

    return result


def count_students(students, tid):
    return Enumerable(students).where(lambda s: s['tutor_id'] == tid).count()


def task3_way2():
    cursor = conn.cursor(cursor_factory=DictCursor)
    cursor.execute("select * from rk3.students")
    students = cursor.fetchall()

    cursor.execute("select * from rk3.teachers")
    teachers = cursor.fetchall()
    cursor.close()

    result = Enumerable(teachers) \
        .where(lambda t: t['department'] == 'Л') \
        .where(lambda t: t['max_students'] == count_students(students, t['id'])) \
        .to_list()

    return result


if __name__ == "__main__":
    print(task1_way1())
    print(task1_way2())
    print(task2_way1())
    print(task2_way2())
    print(task3_way1())
    print(task3_way2())
