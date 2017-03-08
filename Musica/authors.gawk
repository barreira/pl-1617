BEGIN {
	FS = " *[:;,] *"
}

/author: / {
	for (i = 2; i <= NF; i++) {
		aux = subString($i, "[ ?()\\t]*$", "");
		aux2 = subString(aux, "&", "e");

		if (aux2 != "") {
			songs[aux2]++;
		}
		else {
			songs["Autor desconhecido"]++;
		}

	}
}

END {
	for (i in songs) {
		print i " - " songs[i];
	}
}


function subString(str, sequence, replace) {
	return gensub(sequence, replace, "g", str); 
}
