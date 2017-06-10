#ifndef stringStack_h
#define stringStack_h


typedef struct stringStack* StringStack;
typedef char* ValueString;


StringStack pushString(StringStack, ValueString);
StringStack popString(StringStack);
ValueString topString(StringStack);
int emptyString(StringStack);
void destroyStringStack(StringStack);


#endif
