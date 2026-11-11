/*
Eliot
LEPETIT

Projet de recherche
*/


clear

cd "/Users/eliot/Documents/Rmusee/Dofile/1973"


*** Import de la base de 1973
import delimited /Users/eliot/Documents/Rmusee/Data/1973/pc73.csv, delimiter(";") clear 

gen annee = 1973

recode age (1=1) (2=1) (3=0) 

label define age   1 "15-24" ///
                   0 "25-39" ///
                     , modify

drop if age > 1

rename q77ax14 musee_annee

keep annee age musee_annee   


*** traitement
gen traitement = 1
replace traitement = 0 if age == 0

* Etiqueter la variable de traitement
label define traitement 0 "25-39 ans" 1 "15-24 ans"
	

***
table traitement annee, contents(mean musee_annee)
drop age

save "1973_treated.dta", replace



