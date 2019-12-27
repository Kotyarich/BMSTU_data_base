from py_linq import Enumerable

students = Enumerable([
    {'name': 'Joe Smith', 'mark': 80, 'gid': 1},
    {'name': 'Joanne Smith', 'mark': 90, 'gid': 2}
])

group = Enumerable([
    {'id': 1},
    {'id': 2}
])

names = students.where(lambda x: x['mark'] > 50) \
    .join(group, lambda s: s['gid'], lambda g: g['id'], lambda res: (res[0], res[0].update(res[1]))[0]) \
    .select(lambda x: x['name']) \
    .order_by(lambda x: x) \
    .reverse() \
    .distinct() \
    .skip(1) \
    .count()


res = students.any(lambda x: 'o' in x['name'])
res2 = students.all(lambda x: 'a' in x['name'])
res3 = students.contains({'name': 'Joanne Smith'}, lambda x: x['name'])
name1 = students.take(1).concat(students).element_at(2)
name2 = students.last()
name3 = students.first()

print(names)
print(res, res2, res3)
print(name1)
print(name2)
print(name3)
