require(Cairo)
TypeImage = ".pdf"
Name3 = paste("DestinationHabituelle", DateBegin,"-",DateEnd,TypeImage, sep = "", collapse = NULL)
CairoPDF(Name3,width=12,height=8)
print(PeriodeDonnees(DateBegin,DateEnd,Origine_choisi))
dev.off()

require(Cairo)
TypeImage = ".pdf"
Name4 = paste("Analyse des voyagers frequent de ", Pays_choisi, TypeImage, sep = "", collapse = NULL)
CairoPDF(Name4,width=12,height=8)
print(VoyageurFrequent(DateBegin,DateEnd,Pays_choisi))
dev.off()
