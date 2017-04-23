#include <stdio.h>
#include <string.h>

char* Fli(char* ele)
{
	char BUF[10000];
	int j = 0;
	j += sprintf(BUF + j, "<li> %s </li>\n", ele);
	return strdup(BUF);
}


char* Fhtml(char* tit, int comp, char* items[])
{
	char BUF[10000];
	int j = 0;
	j += sprintf(BUF + j, "<html>\n");
	j += sprintf(BUF + j, "	<head><title>%s</title></head>\n", tit);
	j += sprintf(BUF + j, "<body>\n");
	j += sprintf(BUF + j, "	<h1>%s</h1>\n", tit);
	j += sprintf(BUF + j, "	<ul>");
	for(int i = 0; i < comp; i++) {
		j += sprintf(BUF + j, "%s", Fli(items[i]));
	}
	j += sprintf(BUF + j, "</ul>\n");
	j += sprintf(BUF + j, "</body>\n");
	j += sprintf(BUF + j, "</html>\n");
	return strdup(BUF);
}


int main(){
	char * a[]={"expressões regulares","parsers","compiladores"};
	printf("%s\n",Fhtml("Conteudo programático", 3, a));
}
