BEGIN {
	
	FS = " *[:;,] *"
}

/singer:/ {
	for (i = 2; i <= NF; i++) {
		aux = subString($i, "[ ?()]*$", "");
		aux2 = subString(aux, "&", "e");

		if (!(aux2 in singers) && (aux2 != "")) {
			count++;
			singers[aux2] = aux2;
		}
	}
}

END {
	for (i in singers) {
		print singers[i];
	}

	print "Total: " count;
}


function subString(str, sequence, replace) {
	return gensub(sequence, replace, "g", str); 
}
