#include <stdio.h>
#include <string.h>

char* FraseExemplo()
{
	char BUF[10000];
	int j = 0;
	j += sprintf(BUF + j, " Funcao sem argumentos \n");
	return strdup(BUF);
}


int main(){
	printf("%s\n", FraseExemplo());
}
