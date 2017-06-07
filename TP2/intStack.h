#ifndef intStack_h
#define intStack_h


typedef struct intStack* IntStack;
typedef int Value;


IntStack push(IntStack, Value);
IntStack pop(IntStack);
Value top(IntStack);
int empty(IntStack);
void destroyIntStack(IntStack);


#endif
