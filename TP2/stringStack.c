#include <stdlib.h>
#include <string.h>
#include "stringStack.h"


struct stringStack {
	ValueString value;
	StringStack next;
};


StringStack pushString(StringStack s, ValueString value)
{
	StringStack nS = malloc(sizeof(struct stringStack));

	nS->value = strdup(value);
	nS->next = s;

	return nS; 
}


StringStack popString(StringStack s)
{
	StringStack aux = NULL;

	if (s != NULL) {
		aux = s;
		s = s->next;
		free(aux);
		aux = NULL;
	}

	return s;
}


ValueString topString(StringStack s)
{
	ValueString v = "";

	if (s != NULL) {
		v = strdup(s->value);
	}

	return v;
}


int emptyString(StringStack s)
{
	int ret = 1;

	if (s != NULL) {
		ret = 0;
	}

	return ret;
}


void destroyStringStack(StringStack s)
{
	StringStack aux = NULL;

	while (s != NULL) {
		aux = s;
		s = s->next;
		free(aux);
		aux = NULL;
	}
}
