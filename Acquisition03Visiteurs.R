# ce programme est destine a trouver toutes les donnees dans 
#la zone qu'on a precis en fonction de l'identifiant explote par le programme precedent
# ATTENTION POUR EXPLOITER TOUTES LES DONNEES CE PROGRAMME PRENDRA ENVIRON 1 HEURE 30 MINUTES
# A la fin d'execution, un tableau "review_all" contenant toutes les donnees de reservation de 
#logement dans cette zone vous permettra de faire les analyses suivantes

require(httr)
require(dplyr)
require(rvest)
require(jsonlite)
library(sqldf)
place_review=place_review_all # l'etape precedant
list_id=c(unique(place_review$host_id),unique(place_review$reviewer_id))
# collecter tous les logements et commentaires dans le region qu'on choisit
id=list_id[1]
review_all=NULL
print("exploitation en cours")
for(i in seq(1,length(list_id))){
  id=list_id[i]
  off=0
  count=1
  #si il y a erreur:
  while(off <= count){
    error=500
    while(length(error)>0 ){
      if(error != 404){
        url=paste("https://www.airbnb.com/api/v2/reviews?",
                  "currency=EUR&key=d306zoyjsyarp7ifhu67rjxn52tv0t20&locale=en&",
                  "reviewee_id=",id,
                  "&role=","guest",
                  "&_format=for_user_profile_v2&_limit=100",
                  "&_offset=",off,"&_order=recent",sep="")
      
        webpage <- GET(url,
                       httpheader=c("User-Agent"="Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3"))
        raw_data=content(webpage,as = "text",encoding = "UTF-8")
        data<-jsonlite::fromJSON(raw_data, simplifyDataFrame = TRUE)
        error=data$error_code
    
      }#si le site du logment n'est pas vide on cherche les donnees les un apres les autres
      if(length(error)>0){
        if(error==404){error=NULL}
      }
    }
    
    count=data$metadata$reviews_count
    if(length(count)>0){
      off=off+100
      rev=data$reviews
      if(length(rev)>0){
        listing=rev$listing
        #regler les differents formules :
        if( listing %>% class() == "list"){
          pos_nok=summary(listing) %>% as.matrix()
          pos_nok=which(pos_nok[,1]==0)
          if(length(pos_nok)>0){
            for(j in pos_nok){
              listing[[j]]["id"]=0
            }
          }
          listing=do.call("rbind.data.frame",listing)
        }
        if( listing %>% class() == "character"){
          listing=data.frame(id=listing)
        }
        if( listing %>% class() == "logical"){
          listing=data.frame(id=listing)
        }
        listing_id=as.numeric(as.character(listing$id))
        
        #mettre tous les donnees collectes dans un tableau
        review=data.frame(
          user_id=id,
          date_review=rev$created_at,
          reviewer_id=rev$reviewer$id,
          reviewer_date=rev$reviewer$created_at,
          reviewer_name=rev$reviewer$first_name,
          reviewer_lang=rev$language,
          reviewer_role=rev$role,
          reviewer_place_vistied=listing_id,
          reviewer_location=rev$reviewer$location
        )
        review_all=rbind(review_all,review)
        review_all<-sqldf("SELECT * 
                          FROM review_all
                          WHERE reviewer_place_vistied IN (
                          SELECT place_id
                          FROM place_review_all)
                          ")
      }
    }
  }
}

print("exploitation terminee")
write.csv(review_all,file="InfoVisiteurs.csv")


