#include "postgres.h"
#include <fmgr.h>

#ifdef PG_MODULE_MAGIC
PG_MODULE_MAGIC;
#endif

typedef struct Plane {
	int places;
	char model[30];
} Plane;

PG_FUNCTION_INFO_V1(plane_in);

Datum  plane_in(PG_FUNCTION_ARGS) {
	char *str = PG_GETARG_CSTRING(0);
	int places = 0;
	char model[30];
	struct Plane *result;
	int i = 0;
	if (!(*str))
		ereport(ERROR,
                 (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                 errmsg("invalid input syntax for complex: \"%s\"", str)));
	for (str++; *str && *str != ','; i++, str++) {
		model[i] = *str;
	}
	if (!i) ereport(ERROR,
                 (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                 errmsg("invalid input syntax for complex: \"%s\"", str)));
	str += 2;
	if (sscanf(str, "%d", &places) != 1) ereport(ERROR,
                 (errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
                 errmsg("invalid input syntax for complex: \"%s\"", str)));
	result = (Plane *)palloc(sizeof(Plane));
	result->places = places;
	for (int i = 0; i < 30; i++)
		result->model[i] = model[i];
	PG_RETURN_POINTER(result);
}


PG_FUNCTION_INFO_V1(plane_out);

Datum plane_out(PG_FUNCTION_ARGS) {
	struct Plane *plane = (struct Plane *) PG_GETARG_POINTER(0);
	char *result;
	result = psprintf("(%s, %i)", plane->model, plane->places);
	PG_RETURN_CSTRING(result);
}
