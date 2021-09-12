# ce programme est pour analyser les visiteurs qui deja visite SXB avant irma
#quelle est la pourcentage de ses visiteurs qui re-visiter SXB par an
#install.packages("lubridate")
library(sqldf)
library(ggplot2)
library(RColorBrewer)
library(tidyverse)
library(Cairo)
library(sp)
library(lubridate)

VoyageurFrequent = function(DateBegin,DateEnd,Pays_choisi){
#selecter dans la periode choisi
  VoyageurFrequent<-subset(commentaires, as.Date(Time_Comment) > as.Date(DateBegin) & as.Date(Time_Comment) < as.Date(DateEnd))
  VoyageurFrequent = VoyageurFrequent[,c('id','Guest','Country','Time_Comment','Origine')]
  #donner le nom de header
  colnames(VoyageurFrequent)=c('id','Guest','Country','Time_Comment','Origine')
  #limiter le pays choisi dans la periode choisi
  VoyageurFrequent <- VoyageurFrequent[VoyageurFrequent$Country == Pays_choisi,]
  
  commentaires<-subset(commentaires, as.Date(Time_Comment) > as.Date(DateEnd))
  commentaires = commentaires[,c('id','Guest','Country','Time_Comment','Origine')]
  #donner le nom de header
  colnames(commentaires)=c('id','Guest','Country','Time_Comment','Origine')
  #limiter le pays choisi apres la periode choisi
  commentaires<-commentaires[commentaires$Country == Pays_choisi,]
  
  #selecter par an
  VoyageurFrequent$Year<-year(VoyageurFrequent$Time_Comment)
  commentaires$Year<-year(commentaires$Time_Comment)
 
   # calculer il y a combien de voyageur dans la periode choisi
  sum<-sqldf("select count(id) as sum from VoyageurFrequent")
  
  
  # calculer le nombre de voyageur qui re visiter le pays choisi
  comparer<-sqldf("select C.Year, count(C.id) as nombre
                  from VoyageurFrequent as V, commentaires as C 
                  where V.id=C.id
                  group by C.Year")
  
comparer$pourcentage<-comparer$nombre/sum$sum*100
comparer$pourcentage=round(comparer$pourcentage,2)


#visualiser en diagramme
library(ggplot2)
ggplot(comparer, aes(x = Year, y = pourcentage)) +
  geom_bar(stat = "identity", fill = "#51BBF6")+
  ggtitle(paste("Analyse des voyagers frequent de cette zone" , Pays_choisi))+
  geom_text(mapping = aes(label = pourcentage),size=4,vjust=0.5)+ 
  theme(              
    panel.grid = element_blank(),
    panel.background = element_blank(),
    legend.position = c(0.2,0.3), 
    plot.title = element_text(hjust = 0.5)
  )
}



