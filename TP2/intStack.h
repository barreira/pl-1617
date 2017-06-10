#ifndef intStack_h
#define intStack_h


typedef struct intStack* IntStack;
typedef int ValueInt;


IntStack pushInt(IntStack, ValueInt);
IntStack popInt(IntStack);
ValueInt topInt(IntStack);
int emptyInt(IntStack);
void destroyIntStack(IntStack);


#endif
