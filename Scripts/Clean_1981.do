/*
Eliot
LEPETIT

Projet de recherche
*/


clear

cd "/Users/eliot/Documents/Rmusee/Dofile/1981"


*** Import de la base de 1981
import delimited /Users/eliot/Documents/Rmusee/Data/1981/pc81.csv, delimiter(";") clear 

gen annee = 1981

rename q97x14 musee_annee

keep annee age musee_annee   


*** traitement
drop if age < 18 | age > 33

gen traitement = 0
replace traitement = 1 if age >= 18 & age <= 25

label define traitement 0 "26-33 ans" 1 "18-25 ans"

***
table traitement annee, contents(mean musee_annee)


save "1981_treated.dta", replace



