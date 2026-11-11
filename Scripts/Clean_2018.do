/*
Eliot
LEPETIT

Projet de recherche
*/

clear

cd "/Users/eliot/Documents/Rmusee/Dofile/2018"


*** Import de la base de 2018
import delimited /Users/eliot/Documents/Rmusee/Data/2018/pc18_quetelet_octobre2023.csv, delimiter(";") clear 

gen annee = 2018

rename h110 musee_vie

rename h210 musee_annee

rename h4_c_1 nb_musee_1

rename h4f unit_nb_musee


label variable musee_vie "visite d'un musee au moins une fois AU COURS DE VOTRE VIE ?"
label variable musee_annee "visite d'un musee au moins une fois au cours des 12 derniers mois ? : 1 = oui ; 0 = non"
label variable nb_musee_1 "Combien de fois par semaine, par mois ou dans l'année, êtes-vous allé au musée au cours des 12 derniers mois ?"
label variable unit_nb_musee "unité de la question nb_musee : 1 = PAR SEMAINE ; 2 = PAR MOIS ; 3 = DANS L'ANNEE"

* Convertir les visites par mois et par semaine en visites par année (x12)
replace nb_musee = nb_musee_1 * 12 if unit_nb_musee == 2
replace nb_musee = nb_musee_1 * 52 if unit_nb_musee == 1
replace nb_musee = 0 if nb_musee_1 == .

* Etiqueter la variable
label variable nb_musee "Nombre de visites au musée par année"



***Diplome

* High = baccalauréat et + 
* Low = arrêt avant le bac
rename m19 diplome
label variable diplome  "Diplôme le plus élevé que le chef de famille a obtenu"

recode diplome (1=0) (2=0) (3=0) (4=1) (5=0) (6=0) (7=1) (8=1) (9=1) (10=1) (11=1) (12=1) (13=1) (14=.)

label define diplome 0 "Low" ///
                     1 "High" ///
                     , modify
	 

	 
*** Pays naissance 
label define lnais 1 "En France" 2 "A l'étranger", modify
label variable lnais  "Pays de naissance de l'individu"

*** Pays naissance parents
gen lnais_parents = cond(naip == 1 & naim == 1, 1, ///
                    cond(naip == 2 | naim == 2, 2, .))
label variable lnais_parents  "Pays de naissance des parents de l'individu"

label define lnais_parents 1 "En France" 2 "Au moins un parent né à l'étranger", modify
 
 
 	   
*** Type de commune
rename tuu2016 agglo
label variable agglo "type d'agglomération"

recode agglo (1=0) (2=0) (3=0) (4=1) (5=0) (6=1) (7=1) (8=2)

label define agglo   0 "Moins de 100 000 habitants" ///
                     1 "Plus de 100 000 habitants" ///
					 2 "Agglomération parisienne" ///
                     , modify

					 
 
 *** CSP
rename g_pcs_menage_ pcs

replace pcs = "1" if pcs == "I"
replace pcs = "2" if pcs == "II"
replace pcs = "3" if pcs == "III"
replace pcs = "4" if pcs == "IV"
replace pcs = "5" if pcs == "V"
replace pcs = "6" if pcs == "VI"
replace pcs = "7" if pcs == "VII"
destring pcs, replace force

gen pcs_recode = pcs
* Recoder les valeurs de la variable temporaire
replace pcs_recode = 3 if pcs == 6 & _n <= _N/2
replace pcs_recode = 5 if pcs == 6 & _n > _N/2

drop pcs
rename pcs_recode pcs
recode pcs (1=2) (2=3) (3=4) (4=1) (7=6)
	
label define pcs   1 "Indépendant" ///
			2 "Chef d'entreprise - Cadre" ///
			3 "Profession intermédiare" ///
			4 "Employé" ///
			5 "Ouvrier" ///
			6 "Inactif" ///
			, modify

                
			
*** Instrument de musique
rename a21_musique instrument 
label variable instrument  "Jouer d'un instrument dans l'année"
recode instrument (2=0) 

label define instrument 0 "Non" 1 "Oui", modify  




*** Livres 	
rename f5 livre_cat
label variable livre_cat  "Au total, diriez-vous que vous êtes plutôt quelqu'un qui lit..."
recode livre_cat (5=.) (6=.)
label define livre_cat 1 "beaucoup" 2 "moyennement" 3 "peu" 4 "pas", modify  
			
			
			

rename f13_c_1 nb_livre 
label variable nb_livre "Nombre de livres lus ces 12 derniers mois"


recode nb_livre (0=0) (1/9=1) (10/49=2) (50/max=3), generate(nb_livre_grp)
label variable nb_livre_grp "Nombre de livres lus ces 12 derniers mois RECOD"

label define nb_livre_grp   0 "0" ///
                            1 "1 à 9" ///
					        2 "10 à 49" ///
							3 "50 et plus" ///
                            , modify	  
	
	
	

***
keep annee age  musee_vie  musee_annee  diplome  lnais lnais_parents  nb_musee  agglo  pcs  sexe instrument livre_cat nb_livre nb_livre_grp

*** Changer l'ordre des variables (pour plus de visibilité) 
local neworder annee age  sexe  musee_vie  musee_annee  nb_musee diplome agglo lnais lnais_parents pcs  instrument livre_cat nb_livre nb_livre_grp
order `neworder'  



save "2018_clean_new.dta", replace




***** TRAITEMENT *****

* Supprimer les individus qui n'ont pas entre 18 et 33 ans
drop if age < 18 | age > 33

*** Création d'une variable "traitement" 
gen traitement = 0
replace traitement = 1 if age >= 18 & age <= 25

* Etiqueter la variable de traitement
label define traitement 0 "26-33 ans" 1 "18-25 ans"
	
** Suppression des outliers
tabulate nb_musee if traitement == 1
tabulate nb_musee if traitement == 0
drop if nb_musee >= 20
save "2018_treated.dta", replace




