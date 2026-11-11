/*
Eliot
LEPETIT

Projet de recherche
*/

clear

cd "/Users/eliot/Documents/Rmusee/Dofile/2008"

*** Import de la base de 2008
import delimited /Users/eliot/Documents/Rmusee/Data/2008/pc08lab.csv, delimiter(";") clear 

gen annee = 2008

rename q28 sexe 
rename q29 age 

rename q223_m11 musee_vie 
replace musee_vie  = 0 if musee_vie  == .

rename q224_o11 musee_annee  
replace musee_annee  = 0 if musee_annee  == 2

rename q225_o11 nb_musee_1 

rename q226_o11 unit_nb_musee  


label variable musee_vie  "Visite d'un musee au moins une fois AU COURS DE VOTRE VIE ?"
label variable musee_annee  "Visite d'un musee au moins une fois au cours des 12 derniers mois ?"
label variable nb_musee_1 "Combien de fois par semaine, par mois ou dans l'année, êtes-vous allé au musée au cours des 12 derniers mois ?"
label variable unit_nb_musee "Unité de la question nb_musee : 1 = PAR SEMAINE ; 2 = PAR MOIS ; 3 = DANS L'ANNEE"

*recoder pour faire en sorte de tout avoir par année (x12 pour les mois ; x52 pour les semaines) --> attention risque de surdéclaration


* Convertir les visites par mois en visites par année (x12)
replace nb_musee  = nb_musee_1 * 12 if unit_nb_musee == 2
replace nb_musee  = 0 if nb_musee_1 == .

* Etiqueter la variable
label variable nb_musee  "Nombre de visites au musée par année"


**Diplome
* High = baccalauréat et + 
* Low = arrêt avant le bac

rename q315 diplome 
label variable diplome  "Diplôme le plus élevé que le chef de famille a obtenu"

recode diplome (1=0) (2=0) (3=0) (4=1) (5=1) (6=1) (7=1) (8=.) (9=.)

label define diplome 0 "Low" ///
                     1 "High" ///
                     , modify

/* histogram diplome, discrete frequency ///
    xtitle("") ///
    xlabel(0 "Low" 1 "High", labsize(medium) angle(45)) ///
    addlabels
*/
	
	
	
*** Pays naissance
** V = Q264 S(1-3) "S1.- Quel est votre pays de naissance ? "

rename q264 lnais
label variable lnais  "Pays de naissance de l'individu"

recode lnais (3=.)

label define lnais 1 "En France" 2 "A l'étranger", modify
 
/* histogram lnais, discrete frequency ///
    xtitle("") ///
    xlabel(1 "En France" 2 "A l'étranger", labsize(medium) angle(45)) ///
    addlabels
*/

*** Pays naissance parents
rename payspm lnais_parents
label variable lnais_parents  "Pays de naissance des parents de l'individu"

recode lnais_parents (3=2) (4=.)

label define lnais_parents 1 "En France" 2 "Au moins un parent né à l'étranger", modify
 
/*histogram lnais_parents, discrete frequency ///
    xtitle("") ///
    xlabel(1 "En France" 2 "Au moins un parent né à l'étranger", labsize(vsmall) angle(45)) ///
    addlabels
*/
	
	
	
*** Type d'agglomération  (agglo)
label variable agglo  "type d'agglomération"			
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
rename xcspc8 pcs 
label variable pcs  "CSP Chef de famille"
drop if pcs == 7
recode pcs (2=1) (3=2) (4=3) (5=4) (6=5) (8=6) 
label define pcs 1 "Indépendant" ///
			2 "Chef d'entreprise - Cadre" ///
			3 "Profession intermédiare" ///
			4 "Employé" ///
			5 "Ouvrier" ///
			6 "Inactif" ///
			, modify


			
			
*** Instrument de musique
rename q234 instrument 
label variable instrument  "Jouer d'un instrument dans l'année"
recode instrument (2=0) 

label define instrument 0 "Non" 1 "Oui", modify  

			
			
*** Livres 	
rename q185 livre_cat
label variable livre_cat  "Au total, diriez-vous que vous êtes plutôt quelqu'un qui lit..."
recode livre_cat (5=.) 
label define livre_cat 1 "beaucoup" 2 "moyennement" 3 "peu" 4 "pas", modify  
			

rename q191 nb_livre 
replace nb_livre  = . if nb_livre == 999
label variable nb_livre "Nombre de livres lus ces 12 derniers mois"


rename rlivlu nb_livre_grp
label variable nb_livre_grp "Nombre de livres lus ces 12 derniers mois RECOD"
recode nb_livre_grp (1=0)(2=1)(3=1)(4=2)(5=2)(6=3)(7=.)
label define nb_livre_grp   0 "0" ///
                            1 "1 à 9" ///
					        2 "10 à 49" ///
							3 "50 et plus" ///
                            , modify	  
			
/*histogram nb_livre_grp, discrete frequency ///
    xtitle("") ///
    xlabel( 0 "0" 1 "1 à 9" 2 "10 à 49" 3 "50 et plus", labsize(small) angle(45)) ///
    addlabels			
*/
	
***
keep annee age  musee_vie  musee_annee  diplome  lnais lnais_parents  nb_musee  agglo  pcs  sexe instrument livre_cat nb_livre nb_livre_grp

*** Changer l'ordre des variables (pour plus de visibilité) 
local neworder annee age  sexe  musee_vie  musee_annee  nb_musee diplome agglo lnais lnais_parents pcs  instrument livre_cat nb_livre nb_livre_grp
order `neworder'  


save "2008_clean_new.dta", replace




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
save "2008_treated.dta", replace






