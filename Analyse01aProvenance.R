#ce programme vous permet de choisir une periode que vous souhaitez analyser,
#d'analyser l'existance d'une differenciation de saison
#en choisissant un pays et une annee pour desquelles les visiteurs sont passes a la zone cherche,
#et visualiser le resultat 
#vous trouvrez une carte mondiale et une graphique a barre dans la repertoire racine
library(sqldf)
library(ggplot2)
library(dplyr)
library(forcats)
#on peut aussi importer le fichier sauvegardé après le nettoyage pour les étapes suivantes
#read.csv("DonneNettoyee.csv")
PeriodeCherche = function(DateDebut,DateFin){
  Periode<-subset(review_all, as.Date(date_review) > as.Date(DateDebut) & as.Date(date_review) < as.Date(DateFin))
  
  sommePays<-sqldf("select Country, count(reviewer_id) as NombreVisiteur
FROM Periode
GROUP BY Country")
  
  #calcul de la pourcentage
  
  sommePays$Percentage<-sommePays$NombreVisiteur/sum(sommePays$NombreVisiteur)*100
  sommePays$Percentage=round(sommePays$Percentage,1)
  #sommePays$Percentage<-paste(format(sommePays$NombreVisiteur/sum(sommePays$NombreVisiteur)*100,digits=1), sep='')
  
  sommePays %>%
    mutate(Country = fct_reorder(Country, Percentage)) %>%
    ggplot(aes(x=Country, y=Percentage)) +
    geom_bar(stat="identity", fill="#f68060", alpha=.6, width=0.6) +
    geom_text(mapping = aes(label =format(Percentage,digits=2)),size=3,vjust=0.5)+ 
    ggtitle(paste("Analyse de provenance des visiteurs a la zone","entre", DateDebut ,"et" ,DateFin))+
    coord_flip() + 
    xlab("") +
    theme_bw() +
    scale_y_continuous(name='Pourcentage(%)', 
                       breaks=seq(0,100,10),
                       limits=c(0,100))
  
  
  # mets le chiffre sur chaque barre
  
}

