BEGIN {
	IGNORECASE = 1;
	fmtLI = "<li>%s</li>\n";
	fmtP = "<p>%s</p>\n"; 
	FS = "^[> !<]*pt(_br)?(_pt)?";
	end = "</body></html>";
	print "<html><head><meta charset='UTF-8'/></head><body>" > "index.html";
}


/^pt/ || /^[>< !<]*pt/ {
	printf(fmtLI, $2) > "index.html"; 
}

/[> <!?]*def/ {
	split($0, target, "def");
	printf(fmtP, target[2]) > "index.html"; 
}

/[> <!?-]*catgra/ {
	split($0, target, "catgra");
	printf(fmtP, target[2]) > "index.html"; 
}

END {
	print end > "index.html";
}
