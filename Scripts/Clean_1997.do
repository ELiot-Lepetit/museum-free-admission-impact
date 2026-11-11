/*
Eliot
LEPETIT

Projet de recherche
*/


clear

cd "/Users/eliot/Documents/Rmusee/Dofile/1997"


*** Import de la base de 1997
import delimited /Users/eliot/Documents/Rmusee/Data/1997/pcf98v2.csv, delimiter(";") clear 

gen annee = 1997

rename agei age
rename sexei sexe

rename acmuse musee_vie
replace musee_vie  = 0 if musee_vie  == .

recode acmuse12 (2=0)
rename acmuse12 musee_annee

rename nbf12m11  nb_musee_1 
rename unitc11 unit_nb_musee  

* Convertir les visites par mois/semaine en visites par année 
replace nb_musee = nb_musee_1 * 12 if unit_nb_musee == 2
replace nb_musee = nb_musee_1 * 52 if unit_nb_musee == 1
replace nb_musee = 0 if nb_musee_1 == .


**Diplome
* High = baccalauréat et + 
* Low = arrêt avant le bac

rename dipl diplome 

recode diplome (1=0) (2=0) (3=0) (4=1) (5=1) (6=1) (7=1) (8=0)

label define diplome 0 "Low" ///
                     1 "High" ///
                     , modify


*** Type d'agglomération  (agglo)		
recode agglo (1=0) (2=0) (3=0) (4=1) (5=2) (6=2)

label define agglo   0 "Moins de 100 000 habitants" ///
                     1 "Plus de 100 000 habitants" ///
					 2 "Agglomération parisienne" ///
                     , modify


/*histogram agglo, discrete frequency ///
    xtitle("") ///
    xlabel(0 "Moins de 100 000 habitants" 1 "Plus de 100 000 habitants" 2"Agglomération parisienne", labsize(small) angle(45)) ///
    addlabels
*/


*** CSP
rename cspcfa pcs 
recode pcs (2=1) (3=2) (4=3) (5=4) (6=5) (7=5) (8=6) (9=6)
label define pcs 1 "Indépendant" ///
			2 "Chef d'entreprise - Cadre" ///
			3 "Profession intermédiare" ///
			4 "Employé" ///
			5 "Ouvrier" ///
			6 "Inactif" ///
			, modify


		
*** Instrument de musique
rename joueinst instrument 
label variable instrument  "Jouer d'un instrument dans l'année"
recode instrument (2=0) 

label define instrument 0 "Non" 1 "Oui", modify  


			
*** Livres 	
rename lecteur livre_cat
label variable livre_cat  "Au total, diriez-vous que vous êtes plutôt quelqu'un qui lit..."
recode livre_cat (5=.) 
label define livre_cat 1 "beaucoup" 2 "moyennement" 3 "peu" 4 "pas", modify  


rename nbrlivre nb_livre 
replace nb_livre  = . if nb_livre == 999
replace nb_livre  = 0 if nb_livre == 998
label variable nb_livre "Nombre de livres lus ces 12 derniers mois"

							
* Créer une nouvelle variable nb_livre_grp en recodant la variable nb_livre
gen nb_livre_2 = nb_livre
recode nb_livre_2 (0 = 0) (1/9 = 1) (10/49 = 2) (50/max = 3), generate(nb_livre_grp)

* Étiqueter la variable nb_livre_grp
label define nb_livre_grp 0 "0" ///
                            1 "1 à 9" ///
					        2 "10 à 49" ///
							3 "50 et plus"

* Appliquer les étiquettes à la variable
label values nb_livre_grp nb_livre_grp

	
	
keep annee age sexe musee_vie musee_annee nb_musee diplome agglo pcs instrument livre_cat nb_livre nb_livre_grp


*** traitement
drop if age < 18 | age > 33

gen traitement = 0
replace traitement = 1 if age >= 18 & age <= 25

label define traitement 0 "26-33 ans" 1 "18-25 ans"

***
table traitement annee, contents(mean musee_annee)

*suppression des outilers
drop if nb_musee > 20

save "1997_treated.dta", replace

