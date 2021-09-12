require(Cairo)
#les graphiques sont sauvegardées dans la repertoire racine par defaut
#si vous souhaitez les mettre dans le fichier "resultat", configurez le passage de la commande suivante
#setwd("ProjetAirbnbV6.0/resultat")
TypeImage = ".pdf"
Name1 = paste("Provenance", DateDebut,"-",DateFin,TypeImage, sep = "", collapse = NULL)
CairoPDF(Name1,width = 12, height = 8)
print(PeriodeCherche(DateDebut,DateFin))
dev.off()

TypeImage = ".pdf"
Name = paste(Pays_choisi,"Du",DateDebut,"Au",DateFin,TypeImage, sep = "", collapse = NULL)
CairoPDF(Name)
print(Diagramme_Saison(Pays_choisi,DateDebut,DateFin))
dev.off()