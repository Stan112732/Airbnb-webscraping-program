# Extract airbnb listings within a boundbox
# Author : Alexandre Cebeillac
# Université de Rouen Normandie

# returns the reviews of the places visited
# needs the id of the places (from 01_rbnb_location)

list_appart=bnb_sf[which(bnb_sf$reviews_count >0),] 
list_appart=unique(list_appart$id)

place_review_all=NULL
print("Acquisition en cours")
for(i in seq(1,length(list_appart))){
  Sys.sleep(sample(seq(0.2,1,0.1),1,prob = rev(seq(0.2,1,0.1))))
  ID=list_appart[i]
  list_review=paste("https://www.airbnb.fr/api/v2/homes_pdp_reviews?currency=EUR",
                    "&key=d306zoyjsyarp7ifhu67rjxn52tv0t20",
                    "&locale=fr","&listing_id=",ID,
                    "&_format=for_p3",
                    "&limit=5000",sep="")
  webpage <- GET(list_review,
                 httpheader=c("User-Agent"="Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3"))
  raw_data=content(webpage,as = "text",encoding = "UTF-8")
  review<-jsonlite::fromJSON(raw_data, simplifyDataFrame = TRUE)
  
  nb_review=review$metadata$reviews_count
  if(length(nb_review) >0 ){
      if(length(review$reviews$id)==0){user_rev="no value"}else{user_rev=review$reviews$id}
      if(length(review$reviews$created_at)==0){date_rev="no value"}else{date_rev=review$reviews$created_at}
      if(length(review$reviews$language)==0){lang_rev="no"}else{lang_rev=review$reviews$language}
      if(length(review$reviews$reviewee$id)==0){id_home="no value"}else{id_home=review$reviews$reviewee$id}
      if(length(review$reviews$reviewee$host_name)==0){name_home="no value"}else{name_home=review$reviews$reviewee$host_name}
      if(length(review$reviews$reviewer$id)==0){id_review="no value"}else{id_review=review$reviews$reviewer$id}
      if(length(review$reviews$reviewer$host_name)==0){id_name="no value"}else{ id_name=review$reviews$reviewer$host_name}}
      place_review=data.frame(place_id=ID,
                              host_id=id_home,
                              host_name=name_home,
                              nb_review=nb_review,
                              review_id=user_rev,
                              reviewer_name=id_name,
                              reviewer_id=id_review,
                              review_date=date_rev,
                              rate=review$reviews$rating,
                              lang=lang_rev)
      place_review_all=rbind(place_review_all,place_review)
     

      }
print("Acquisition terminee")

rm(webpage)