BEGIN {
	FS = " *[:;,] *"
}

/title: / {
	song = $2;
}

/author: / {
	for (i = 2; i <= NF; i++) {
		aux = subString($i, "[ ?()\\t]*$", "");
		aux2 = subString(aux, "&", "e");

		if (aux2 != "") {
			authors[aux2][song] = song;
		}
		else {
			authors["Autor desconhecido"][song] = song;
		}

	}
}

END {
	for (i in authors) {
		printf("%s: ", i);

		flag = 0;		

		for (j in authors[i]) {
			if (flag == 0) {
				printf("%s", j);
			}
			else {
				printf(", %s", j);
			} 

			flag++;
		}

		print;
	}
}


function subString(str, sequence, replace) {
	return gensub(sequence, replace, "g", str); 
}
