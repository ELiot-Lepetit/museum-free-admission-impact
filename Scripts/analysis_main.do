/*
Eliot
LEPETIT

Projet de recherche
*/

********** Merge & labels **********
clear

* Fermer le fichier log
*Ouvrir le fichier log
log using "/Users/eliot/Documents/Rmusee/Rendu.log", replace


cd "/Users/eliot/Documents/Rmusee/Dofile/2008"

use "2008_treated.dta"

append using "/Users/eliot/Documents/Rmusee/Dofile/1973/1973_treated.dta"
append using "/Users/eliot/Documents/Rmusee/Dofile/1981/1981_treated.dta"
append using "/Users/eliot/Documents/Rmusee/Dofile/1997/1997_treated.dta"
append using "/Users/eliot/Documents/Rmusee/Dofile/2018/2018_treated.dta"

label variable age ""
label variable sexe ""
label define sexe_lab  1 "Homme" ///
				       2 "Femme"
label values sexe sexe_lab

label variable musee_vie  "Visite d'un musee au moins une fois au cours de votre vie"
label variable musee_annee  "Visite d'un musee au moins une fois dans l'année" 
label variable nb_musee  "Nombre de visites au musée par année"

label variable diplome  "Diplôme le plus élevé que le chef de famille a obtenu"
label define diplome_lab 0 "Low" ///
                         1 "High" ///
                     , modify
label values diplome diplome_lab

label variable lnais  "Pays de naissance de l'individu"
label define lnais_lab 1 "En France" 2 "A l'étranger", modify
label values lnais lnais_lab

label variable lnais_parents  "Pays de naissance des parents de l'individu"
label define lnais_parents_lab 1 "En France" 2 "Au moins un parent né à l'étranger", modify
label values lnais_parents lnais_parents_lab


label variable agglo  "type d'agglomération"			
label define agglo_lab   0 "Moins de 100 000 habitants" ///
                     1 "Plus de 100 000 habitants" ///
					 2 "Agglomération parisienne" ///
                     , modify
label values agglo agglo_lab					 
					 
label variable pcs  "CSP Chef de famille"
label define pcs_l 1 "Indépendant" ///
			2 "Cadre" ///
			3 "PI" ///
			4 "Employé" ///
			5 "Ouvrier" ///
			6 "Inactif" ///
			, modify
label values pcs pcs_l
			
label variable instrument  "Jouer d'un instrument dans l'année"
label define instrument 0 "Non" 1 "Oui", modify  
label variable livre_cat  "Au total, diriez-vous que vous êtes plutôt quelqu'un qui lit..."
label define livre_cat 1 "beaucoup" 2 "moyennement" 3 "peu" 4 "pas", modify  
label variable nb_livre "Nombre de livres lus ces 12 derniers mois"
label variable nb_livre_grp "Nombre de livres lus ces 12 derniers mois RECOD"
label define nb_livre_grp_lab   0 "0" ///
                            1 "1 à 9" ///
					        2 "10 à 49" ///
							3 "50 et plus" ///
                            , modify	  
label values nb_livre_grp nb_livre_grp_lab
							
label define traitement_lab 0 "26-33 ans" 1 "18-25 ans"
label values traitement traitement_lab

cd "/Users/eliot/Documents/Rmusee/Dofile/Merge"
save "data_merged_PP.dta", replace


*** Pour comparer avec la valeur de référence "2008", je créé des binaires pour les autres années
gen AN_1997 = (annee == 1997)
gen AN_2018 = (annee == 2018)

*** Gorupe des traités en 2018, utile pour la regression (?) 
gen T_apres_ref = (annee == 2018 & traitement == 1)


* variables binaires pour les pcs
gen CSP_Inde = 0
replace CSP_Inde = 1 if pcs == 1

gen CSP_Cadre = 0
replace CSP_Cadre = 1 if pcs == 2

gen CSP_PI = 0
replace CSP_PI = 1 if pcs == 3

gen CSP_Employe = 0
replace CSP_Employe = 1 if pcs == 4

gen CSP_Ouvrier = 0
replace CSP_Ouvrier = 1 if pcs == 5

gen CSP_Inactif = 0
replace CSP_Inactif = 1 if pcs == 6


* variables binaires pour le type d'unité urbaine (agglo)					 
gen agglo_moins100 = 0
replace agglo_moins100 = 1 if agglo == 0

gen agglo_plus100 = 0
replace agglo_plus100 = 1 if agglo == 1

gen agglo_Paris = 0
replace agglo_Paris = 1 if agglo == 2

label variable agglo_moins100 "Unité urbaine de moins de 100 000 habitants"
label variable agglo_plus100 "Unité urbaine de plus de 100 000 habitants"
label variable agglo_Paris "Agglomération parisienne"


drop if annee < 1997
save "data_merged.dta", replace


ssc install estout


***** STAT DESC *****
use data_merged.dta, clear

* Supprimer les observations de 1997
drop if annee == 1997

* Créer des indicateurs pour les périodes avant et après 2009
gen pre_reform = (annee < 2009)
gen post_reform = (annee >= 2009)

* Statistiques descriptives pour la période avant 2009
estpost summarize sexe musee_annee nb_musee diplome nb_livre lnais instrument if pre_reform
eststo pre_reform

* Statistiques descriptives pour la période après 2009
estpost summarize sexe musee_annee nb_musee diplome nb_livre lnais instrument if post_reform
eststo post_reform

* Exporter le tableau combiné en LaTeX
esttab pre_reform post_reform using "descriptive_stats.tex", ///
    title("Descriptive Statistics") ///
    label ///
    fragment ///
    replace ///
    cells("mean sd") ///
    nonumber ///
    nomtitle ///
    nostar

	
	
***AGGLO et PCS faire un graphique/tableau à part	

** AGGLO
* Histogramme pour l'année 2008
histogram agglo if annee == 2008, discrete frequency ///
    xtitle("") ///
    xlabel(0 "Moins de 100 000 habitants" 1 "Plus de 100 000 habitants" 2 "Agglomération parisienne", labsize(small) angle(45)) ///
    ylabel(0(200)800, labsize(small)) ///
    yscale(range(0 800)) ///
    addlabels ///
    title("Répartition des types d'agglomérations en 2008") 
   
graph export "Répartition_Agglo_2008.pdf", as(pdf) replace


* Histogramme pour l'année 2018
histogram agglo if annee == 2018, discrete frequency ///
    xtitle("") ///
    xlabel(0 "Moins de 100 000 habitants" 1 "Plus de 100 000 habitants" 2 "Agglomération parisienne", labsize(small) angle(45)) ///
    ylabel(0(200)800, labsize(small)) ///
    yscale(range(0 800)) ///
    addlabels ///
    title("Répartition des types d'agglomérations en 2018") 
   

graph export "Répartition_Agglo_2018.pdf", as(pdf) replace

	

** PCS
// Générer un histogramme des CSP du chef de famille pour l'année 2008
   *title("Répartition des catégories socioprofessionnelles du chef de famille en 2008") 

histogram pcs if annee == 2008, discrete frequency ///
    xtitle("") ///
    xlabel(1 "Indépendant" 2 "Cadre" 3 "PI" 4 "Employé" 5 "Ouvrier" 6 "Inactif", labsize(small) angle(45)) ///
	ytitle("") ///
	ylabel(0(200)600, labsize(small)) ///
    yscale(range(0 600)) ///
	addlabels 

graph export "RepartPCS08.pdf", as(pdf) replace

* Histogramme pour l'année 2018
histogram pcs if annee == 2018, discrete frequency ///
xtitle("") ///
    xlabel(1 "Indépendant" 2 "Cadre" 3 "PI" 4 "Employé" 5 "Ouvrier" 6 "Inactif", labsize(small) angle(45)) ///
	ytitle("") ///
    ylabel(0(200)600, labsize(small)) ///
    yscale(range(0 600)) ///
	addlabels 	
graph export "RepartPCS18.pdf", as(pdf) replace
	
	
	
	

********** Analyse **********
* Réaliser l'analyse de double différence sur TOUTE LA POP
summarize musee_annee if annee == 2018 & traitement == 1
local A = r(mean)
summarize musee_annee if annee == 2018 & traitement == 0, 
local A_star = r(mean)
summarize musee_annee if annee == 2008 & traitement == 1, 
local B = r(mean)
summarize musee_annee if annee == 2008 & traitement == 0, 
local B_star = r(mean)

* Calculer la double différence
local DiD = (`A' - `A_star') - (`B' - `B_star')
display "Double différence : `DiD'"

local drop A B A_star B_star

** DiD = .0440698305110139


* NB MUSEE
summarize nb_musee if annee == 2018 & traitement == 1
local A = r(mean)
summarize nb_musee if annee == 2018 & traitement == 0, 
local A_star = r(mean)
summarize nb_musee if annee == 2008 & traitement == 1, 
local B = r(mean)
summarize nb_musee if annee == 2008 & traitement == 0, 
local B_star = r(mean)

* Calculer la double différence
local DiD_nb = (`A' - `A_star') - (`B' - `B_star')
display "Double différence : `DiD_nb'"

** DiD_nb = .2294961334325738


	

*** REGRESSIONS

*Première étape de mon analyse : 
use data_merged.dta, clear

reg musee_annee i.traitement##ib2008.annee
esttab using regression_results_1.tex, replace label



reg nb_musee i.traitement##ib2008.annee

/*On voit bien qu'il y a un effet de diminution au fil des années : 
Effet Année: La fréquentation des musées était significativement plus élevée en 1997 par rapport à 2008, et significativement plus basse en 2018 par rapport à 2008.
Effet Traitement: Aucune différence significative de la fréquentation des musées n'a été observée pour le groupe 18-25 ans (traité) par rapport au groupe d'des 26-33 ans (contrôle).

la politique de gratuité des musées n'a pas eu d'impact significatif sur la fréquentation des musées des jeunes de 18-25 ans par rapport aux autres groupes d'âge. 
La baisse significative de la fréquentation en 2018 par rapport à 2008 pourrait indiquer d'autres facteurs influençant la fréquentation des musées au-delà de la politique de gratuité.

*/ 
rreg musee_annee i.traitement##ib2008.annee sexe diplome nb_livre agglo_Paris agglo_plus100 CSP_Cadre CSP_Employe CSP_Ouvrier CSP_Inactif CSP_Inde
esttab using regression_results_2.tex, replace label



*Multicolinéarité ?
*vif

*** ANNEXE 
** Régression avec imputations multiples
mi set mlong
* Enregistrer les variables avec des valeurs manquantes
mi register imputed  diplome nb_livre lnais lnais_parents instrument
* Imputer les valeurs manquantes
mi impute chained (regress) diplome nb_livre lnais lnais_parents instrument = traitement annee, add(5)

* Régression avec imputation multiple (CSP par rapport aux PI / agglo par rapport à agglo de moins de 100)
mi estimate: reg musee_annee i.traitement##ib2008.annee sexe diplome nb_livre agglo_Paris agglo_plus100 CSP_Cadre CSP_Employe CSP_Ouvrier CSP_Inactif CSP_Inde lnais lnais_parents instrument
esttab using regression_results_A.tex, replace label
	
*** Les résultats sont inchangés, les variables de contrôle ajoutées ne sont pas significatives	
	
			
*** Parralel trend assumption ***

**Pourcentage de personne ayant visité un musée au moins une fois cette année  
use data_merged_PP.dta, clear

* Calculer la moyenne de musee_annee pour chaque traitement et chaque année
collapse (mean) musee_annee, by(annee traitement)

replace musee_annee = musee_anne*100

twoway (scatter musee_annee annee if traitement == 0, mcolor(cranberry) mlabel(annee) mlabcolor(black) mlabposition(6) mlabsize(vsmall)) ///
       (scatter musee_annee annee if traitement == 1, mcolor(blue)) ///
       (line musee_annee annee if traitement == 0, lcolor(cranberry)) ///
       (line musee_annee annee if traitement == 1, lcolor(blue)), ///
       xline(2009, lwidth(thin) lpattern(dash)) ///
       title("Graphique de la part de visiteurs dans l'année selon le groupe d'âge", size(medium)) ///
       xtitle("Année", size(medium)) ytitle("Visiteurs de musées dans l'année (%)", size(medium)) ///
       legend(order(1 "26-33 ans" 2 "18-25 ans") pos(1) ring(0))
	   

graph use Graph_PP.gph
graph export Graph_PP.pdf, as(pdf) replace


* Fermer le fichier log
log close

