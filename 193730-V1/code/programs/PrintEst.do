***Author: Will McGrew
***This version 01/25/2021


capture program drop PrintEst
program PrintEst
	args est name txtb4 txtaftr fmt
	di `est'
	di "`name'"
	tempname sample 
	cap mkdir $figtab/text
	file open `sample' using  "$figtab/text/`name'.txt", text write replace
	local est_rounded : di %`fmt' `est'
	file write `sample'  `"`txtb4'`est_rounded'`txtaftr'"'
	file close `sample'
end
