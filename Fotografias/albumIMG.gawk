BEGIN {
	IGNORECASE = 1;
	fmtLI = "<li><b>%s</b></li>\n";
	fmtI = "<center><img src=\"http://npmp.epl.di.uminho.pt/images/%s\"/> </center>\n"
	FS = "<";
	end = "</body></html>";
	print "<html><head><meta charset='UTF-8'/></head><body>" > "index.html";
}


/<foto / {
	split($2, file, "\"");
}

/<quem>/ {
	split($2, persons, "[<>]");
	sub("^ ", "", persons[2]);

	printf(fmtLI, persons[2]) > "index.html";
	printf(fmtI, file[2]) > "index.html";
}

END {
	print end > "index.html";
}
