#include <stdlib.h>
#include "intStack.h"


struct intStack {
	Value value;
	IntStack next;
};


IntStack push(IntStack s, Value value)
{
	IntStack nS = malloc(sizeof(struct intStack));

	nS->value = value;
	nS->next = s;

	return nS; 
}


IntStack pop(IntStack s)
{
	IntStack aux = NULL;

	if (s != NULL) {
		aux = s;
		s = s->next;
		free(aux);
		aux = NULL;
	}

	return s;
}


Value top(IntStack s)
{
	Value v = 0;

	if (s != NULL) {
		v = s->value;
	}

	return v;
}


int empty(IntStack s)
{
	int ret = 1;

	if (s != NULL) {
		ret = 0;
	}

	return ret;
}


void destroyIntStack(IntStack s)
{
	IntStack aux = NULL;

	while (s != NULL) {
		aux = s;
		s = s->next;
		free(aux);
		aux = NULL;
	}
}
