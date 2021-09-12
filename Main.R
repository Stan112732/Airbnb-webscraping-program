#Equipe developpeurs: Zijian LI & Shuaining FENG & Wenhui GAN & Jie LIU & Shuanghong LI 
#references: https://journals.openedition.org/eps/10452 - What can we learn from Airbnb data on tourist flows? A case study on Iceland
#Avant tout, veuillez installer les packages necessaires en executant cette commande:
source("InstallationPack.R")
#auteur: Jie LIU---------------------------------------------------------------------------------------------------
#en cas de changement de stockage du fichier, remplacer le passage en executant les deux lignes de codes suivantes
#path="votre passage de stockage"
#setwd(path)

#pour obtenir les donnees concernant votre projet airbnb, modifier et executer:
Zone ="Saint Barthelemy"
source("Acquisition01Logement.R")
source("Acquisition02Avis.R")
source("Acquisition03Visiteurs.R")

#auteur: Zijian LI Shuanghong LI------------------------------------------------------------------------------------------------------------
#Veuillez nettoyer les donnees exportees avant l'analyse, executer:
source("Nettoyage01.R")

#pour configurer la periode que vous souhaitez analyser la provenance, executer: 
DateDebut = "2017-09-01"
DateFin ="2020-03-01"
source("Analyse01aProvenance.R")
#pour dominer une periode et un pays dans lequel vous voulez analyser une distinction de saison, executer:
Pays_choisi = 'USA'
source("Analyse01bSaison.R")
#pour visualiser les resultats, executer:
CarteProv= PeriodeCherche(DateDebut,DateFin)
Diagramme = Diagramme_Saison(Pays_choisi,DateDebut,DateFin)
source("SauvegardeGraphique01Provenance_Session.R")#par defaut, retrouvez les graphiques dans le repertoire racine

#auteur: Shuaining FENG & Wenhui GAN---------------------------------------------------------------------------------------------------------

# pour analyser la destination habituelle, d'abord obtenir des donnees selons id de guest
source("Acquisition04DestinationHab.R")

#pour nettoyer des donnees vient de commentaire
source("Nettoyage02.R")

#pour analyser la destination habituelle
#pour configurer la periode et l'origine que vous souhaitez analyser, executer:
DateBegin="2020-03-01"
DateEnd="2021-05-01"
Origine_choisi = "USA"
source("Analyse02Destination.R")

#pour analyse des voyageurs frequents
#Parmi tous les visiteurs de SXB, ceux qui qui sont allés dans un Pays_choisi dans une pediode donnee 
#Combien de personnes(en pourcentage) sont retournées dans ce Pays_choisi après cette periode donnee
DateBegin="2016-09-01"
DateEnd="2017-09-01"
Pays_choisi = "USA"
source("Analyse03VoyageurFrequent.R")

#pour visualiser la destination habituelle
DesHab=PeriodeDonnees(DateBegin, DateEnd,Origine_choisi)
VogFre=VoyageurFrequent(DateBegin, DateEnd, Pays_choisi)
source("SauvegardeGraphique02Destination_Habituelle.R")

