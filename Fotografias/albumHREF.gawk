BEGIN {
	IGNORECASE = 1;
	enc = "<html> <head> <meta charset='UTF-8'/> </head> <body>"
	fmtHREF = "<p><a href=\"%s.html\"> %s </a></p>\n";
	fmtIMG = "<li><center><img src=\"http://npmp.epl.di.uminho.pt/images/%s\"/> </center></li>\n"
	FS = "<";
	end = "</body></html>";
	print enc > "index.html";
}


/<foto / {
	split($2, file, "\"");
}

/<quem>/ {
	split($2, persons, "[<>]");

	if (length(persons[2]) < 200) {
		sub("^ ", "", persons[2]);
		sub(" $", "", persons[2]);

		array[persons[2]][file[2]] = 0;
	}

}


END {
	for (i in array) {
		printf(fmtHREF, i, i) > "index.html";

		print enc > i".html";

		for (j in array[i]) {
			printf(fmtIMG, j) > i".html";
		}

		print end > i".html";
	}

	print end > "index.html";
}
