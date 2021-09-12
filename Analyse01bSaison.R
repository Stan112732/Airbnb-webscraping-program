library(sqldf)
library(ggplot2)

Diagramme_Saison = function(Pays,DateDebut,DateFin) {
  
  Donnee_Brute = review_all[,c('user_id','date_review','Country')]
  colnames(Donnee_Brute) = c('user_id','date_review','Country')
  
  Periode = subset(Donnee_Brute, as.Date(date_review) > as.Date(DateDebut) & as.Date(date_review) < as.Date(DateFin))
  strptime(Periode$date_review, format="", tz = "")
  Periode$date_review=substr(Periode$date_review, 1,7)
  
  #Visualisation France
  Donnee_Brute1 <- Periode[Periode$Country == Pays,]
  

  Nombre_Visiteurs_Par_Mois<-sqldf("select date_review, count(date_review) as NombreVisiteurs
FROM Donnee_Brute1 GROUP BY date_review")
  Nombre_Visiteurs_Par_Mois=na.omit(Nombre_Visiteurs_Par_Mois)
  
  Titre = paste("Nombre de visiteurs de", Pays_choisi,"du",DateDebut,"au",DateFin, sep = " ", collapse = NULL)
  
  ggplot(Nombre_Visiteurs_Par_Mois, aes(x = date_review, y = NombreVisiteurs)) +
    
    geom_bar(stat = "identity", fill = "#8FBC94")+
    ggtitle(Titre)+
    theme(               #j'enleve les elements inutiles
      panel.grid = element_blank(),
      panel.background = element_blank(),
      legend.position = c(0.2,0.3), 
      plot.title = element_text(hjust = 0.5),
      axis.text.x = element_text(angle = 60, hjust = 0.5, 
                                 vjust = 0.5,color = "black",size=9)
    )+
    scale_y_continuous(name='Nombre de visiteurs' #nom de l"axe y
    )+
    scale_x_discrete(name='Mois' #nom de l"axe x
    )+
    geom_text(mapping = aes(label = NombreVisiteurs),size=4,vjust=1.4) 
  # mets le chiffre sur chaque barre
}
