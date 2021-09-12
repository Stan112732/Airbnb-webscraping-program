# ce programme est pour nettoyer les commentaires et ensuite d'analyser la destination habituelle

#install.packages("raster")
#install.packages("tidyverse")
#install.packages("sqldf")
#install.packages("tidyr")
#install.packages("dplyr")
#install.packages("readr")

library(raster)
library(tidyverse)
library(sqldf)
library(tidyr)
library(dplyr)
library(readr)

commentaires <- read_csv("resultat/commentaires.csv") # on peut chagcher ce fichier si on a des guest differents
DonneNettoyee <- read_csv("DonneNettoyee.csv")


# Dans la colonne 'location', certaines données contiennent des virgules
# Après la virgule indique le pays ou la région d'origine du client
# Avant la virgule c'est la ville d'où vient le client
# On veut mettre la valeur avant la virgule dans la colonne 'city' 
# et la valeur après la virgule dans la colonne 'Country'
commentaires <- separate(commentaires,
                       location,
                       into= c("City","Country"),sep= "\\,") 
#on suprime les espaces des deux c??tés de la valeur
commentaires <- trim(commentaires)

# Pour les données qui ne contiennent pas de virgules, NA est affiché dans la colonne 'Country'
# On veut remplacer la valeur NA dans la colonne 'Country' par la valeur dans la colonne 'City'
# parce que les données sans virgule sont le pays ou la région où se trouve le client
commentaires <- commentaires %>%
  mutate(Country = if_else(is.na(Country), City, Country))

# Le reviewer_location de nombreux clients américains est composé de ville et d'abréviations d'état
# Nous allons remplacer ces abréviations par USA afin de mieux classer les clients par pays
# Tout d'abord, on a créé une liste des abréviations des 50 états américains et une zone spéciale
list_data_USA= list("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID",
                    "IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS",
                    "MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK",'DC',
                    "OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY" )
head(commentaires)
# On remplace les valeurs dans la colonne 'Country' qui apparaissent dans la liste 'list_data_USA' par USA
for (i in 1:51){
  commentaires$Country[commentaires$Country==list_data_USA[i] ]<-"USA" }

# On remplace également 'UnitedStates' dans la colonne 'Country' par USA
commentaires$Country[commentaires$Country=="UnitedStates"]<-"USA"
# Saint-Barthélemy peut-etre ecrit de plusieurs maniere, donc on change a une seule façon d'écrire
commentaires$Country[commentaires$Country=="SaintBarthélemy"]<-"Saint-Barthélemy"
commentaires$Country[commentaires$Country=="StBarthelemy"]<-"Saint-Barthélemy"
commentaires$Country[commentaires$Country=="St.Barthélemy"]<-"Saint-Barthélemy"
commentaires$Country[commentaires$Country=="Saint-Barthelemy"]<-"Saint-Barthélemy"
commentaires$Country[commentaires$Country=="SaintBarthelemy"]<-"Saint-Barthélemy"

commentaires <- na.omit(commentaires)

commentaires<-sqldf("select distinct C.id, C.Guest, C.Country, C.Time_Comment, D.Country as 'Origine' from commentaires as C, DonneNettoyee as D where D.reviewer_id = C.id ")


View(commentaires)

