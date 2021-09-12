#Ce programme est destine a nettroyer les donnees exploitees par les etapes pree&dentes afin d'analyser
#a la fin d'execution le format des donnees dans le tableau "review_all" seront optimises pour l'analyse
library(raster)
library(tidyverse)
library(sqldf)
library(tidyr)
#on peut aussi importer le fichier sauvegardé après l'acquisition pour les étapes suivantes
#read.csv("InfoVisiteurs.csv")
review_all<-review_all[complete.cases(review_all[,9]),]

# Dans la colonne 'reviewer_location', certaines donnees contiennent des virgules
# Apres la virgule indique le pays ou la region d'origine du client
# Avant la virgule c'est la ville d'oU vient le client
# On veut mettre la valeur avant la virgule dans la colonne 'city' 
# et la valeur apres la virgule dans la colonne 'Country'
review_all <- separate(review_all,
                       reviewer_location,
                       into= c("City","Country"),sep= "\\,") 
#on suprime les espaces
review_all <- trim(review_all)

# Pour les donnees qui ne contiennent pas de virgules, NA est affiche dans la colonne 'Country'
# On veut remplacer la valeur NA dans la colonne 'Country' par la valeur dans la colonne 'City'
# parce que les donnees sans virgule sont le pays ou la region 
review_all <- review_all %>%
  mutate(Country = if_else(is.na(Country), City, Country))

# Le reviewer_location de nombreux clients americains est compose de ville et d'abreviations d'etat
# Nous allons remplacer ces abreviations par USA afin de mieux classer les clients par pays
# Tout d'abord, on a cree une liste des abreviations des 50 etats americains et une zone speciale
list_data_USA= list("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID",
                    "IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS",
                    "MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK",'DC',
                    "OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")

head(review_all)
# On remplace les valeurs dans la colonne 'Country' qui apparaissent dans la liste 'list_data_USA' par USA
for (i in 1:51){
  review_all$Country[review_all$Country==list_data_USA[i] ]<-"USA" }

# On remplace egalement 'etats-Unis' dans la colonne 'Country' par USA
review_all$Country[review_all$Country=="United States"]<-"USA"

review_all <- na.omit(review_all)
write.csv(review_all,file="DonneNettoyee.csv")
reviewer_id<-sqldf("select distinct reviewer_id from review_all where reviewer_role='guest' ")
write.csv(reviewer_id,file="reviewer_id.csv")