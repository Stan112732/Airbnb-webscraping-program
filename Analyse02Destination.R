# ce programme est pour analyser d'autre destination habituelle et visualiser le resultat
library(sqldf)
library(ggplot2)
library(RColorBrewer)
library(tidyverse)
library(Cairo)
library(sp)
library(dplyr)
library(forcats)
PeriodeDonnees = function(DateBegin,DateEnd,Origine_choisi){
PeriodeDonnees<-subset(commentaires, as.Date(Time_Comment) > as.Date(DateBegin) & as.Date(Time_Comment) < as.Date(DateEnd))
PeriodeDonnees = PeriodeDonnees[,c('id','Guest','Country','Time_Comment','Origine')]
colnames(PeriodeDonnees)=c('id','Guest','Country','Time_Comment','Origine')
PeriodeDonnees <- PeriodeDonnees[PeriodeDonnees$Origine == Origine_choisi,]

autre_destination<-sqldf("select Country, count(id) as Nombre
FROM PeriodeDonnees
GROUP BY Country
ORDER BY Nombre DESC
LIMIT 10")




autre_destination %>%
  mutate(Country = fct_reorder(Country, Nombre)) %>%
  ggplot(aes(x=Country, y=Nombre)) +
  geom_bar(stat="identity", fill="#f68060", alpha=.6, width=0.6) +
  geom_text(mapping = aes(label = Nombre),size=4,vjust=0.5)+ 
  ggtitle(paste("le top 10 destination habituelle de visiteurs venant de", Origine_choisi ,"entre" ,DateBegin, "et", DateEnd))+
  coord_flip() +
  xlab("") +
  theme_bw()
# mets le chiffre sur chaque barre
}




