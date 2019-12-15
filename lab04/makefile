MODULES = plane

PG_CONFIG = pg_config
PGXS = $(shell $(PG_CONFIG) --pgxs)
INCLUDEDIR = $(shell $(PG_CONFIG) --includedir-server)
include $(PGXS)

plane.so: plane.o
	cc -shared -o plane.so plane.o

plane.o: plane.c
	cc -o plane.o -c plane.c $(CFLAGS) -I $(INCLUDEDIR)
