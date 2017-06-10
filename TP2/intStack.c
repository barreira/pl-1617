#include <stdlib.h>
#include "intStack.h"


struct intStack {
	ValueInt value;
	IntStack next;
};


IntStack pushInt(IntStack s, ValueInt value)
{
	IntStack nS = malloc(sizeof(struct intStack));

	nS->value = value;
	nS->next = s;

	return nS; 
}


IntStack popInt(IntStack s)
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


ValueInt topInt(IntStack s)
{
	ValueInt v = 0;

	if (s != NULL) {
		v = s->value;
	}

	return v;
}


int emptyInt(IntStack s)
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
