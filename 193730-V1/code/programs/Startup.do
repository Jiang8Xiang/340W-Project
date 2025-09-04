*** Pathnames (only forward slashes! No forward slash at the end, i.e. X:/BGT, not X:/BGT/)

*** Colors
* Du Bois color scheme: https://github.com/ajstarks/dubois-data-portraits/blob/master/dubois-style.pdf

	global black	"0 0 0"
	global brown    "101 67 33"
	global tan  	"210 180 140"
	global gold 	"255 215 0"
	global pink 	"255 192 203"
	global crimson 	"220 20 60"
	global green 	"0 128 0"
	global blue		"70 130 180"

** Load Programs

#d ;

local Programs "
	PrintEst
	";
	

#d cr

	
foreach prg in `Programs' {

	noi run "programs/`prg'.do"
	
}

macro dir
exit 

