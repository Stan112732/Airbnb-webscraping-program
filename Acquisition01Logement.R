#ce fichier permet de chercher et exploiter les donnees dans un zone precis
# a la fin de execution de ce programme, un dataframe "bnb_sf" avec tous les logements de la zone que vous avez choisi sera visible
require(dplyr)
require(sf)
require(osmdata)
require(rnaturalearth)
require(httr)
require(mapview)
#il peut retourner un nombre arrondi au multiple souhaite.
mround=function(x,base){
  base*round(x/base)
}

st_as_bbox = function(bb,proj) {
  
  box = st_polygon(list(matrix(bb[c(1, 2, 3, 2, 3, 4, 1, 4, 1, 2)], ncol=2, byrow=TRUE)))
  st_sfc(box, crs=proj)
}

#transformer les charactere en nombres:
asnum=function(x){
  x=as.numeric(as.character(x))
  return(x)
}

#divise la carte en petite boitres
fun_split_bb=function(bb, # les coordonnee de boundbox
                      nb_place, #combien airbnb location dans cette boundbox
                      coef,
                      proj # projection
){
  nb_bbox=mround(coef*nb_place/300,2) 
  bbox=matrix(bb,nrow=1) %>% st_as_bbox(proj)
  #creer un grille
  grid=st_make_grid(bbox,n = c(nb_bbox,nb_bbox)) %>% 
    st_cast("POLYGON") %>% 
    st_sf() %>%
    mutate(ID=seq(1,nrow(.)))
  # obtenir les coordonnees de cette griile dans le boundbox:
  list_bb=by(grid,grid$ID,st_bbox)
  list_bb=do.call("rbind.data.frame",list_bb)
  colnames(list_bb)=c("xmin","ymin","xmax","ymax")
  return(list_bb)
}

#connecter au site d'airbnb
session_id="31110a55-4943-439a-b92d-c291ce9242ac"
key="d306zoyjsyarp7ifhu67rjxn52tv0t20"
#collecter les donnees dans le siteweb airbnb
fun_get_bnb_info=function(bb_tmp, # the boundbox
                          session_id,
                          key){
  off=0
  out=NULL
  page=TRUE
  while(page == TRUE){
    offsetX=50*off
    off=off+1
    xtnd=0
    url=paste("https://www.airbnb.com/api/v2/explore_tabs?_format=for_explore_search_web",
              "&client_session_id=",session_id,#"cf1e4c92-2d21-4650-b699-0cec92f69424",
              "&currency=EUR",
              "&items_per_grid=200",
              "&key=",key,#"d306zoyjsyarp7ifhu67rjxn52tv0t20",
              "&locale=en",
              "&query_understanding_enabled=true",
              "&refinement_paths[]=/homes",
              # "&s_tag=3UYZAiK8",
              "&satori_version=1.1.9",
              "&search_type=UNKNOWN","&selected_tab_id=home_tab",
              "&show_groupings=true",
              "&supports_for_you_v3=true",
              "&sw_lat=",bb_tmp[2]-xtnd,#68.8156145583058",
              "&sw_lng=",bb_tmp[1]-xtnd,#31.890734048670197",
              "&ne_lat=",bb_tmp[4]+xtnd,#69.19154118402558",
              "&ne_lng=",bb_tmp[3]+xtnd,#34.34297415066328",
              "&timezone_offset=120",
              "&version=1.5.6","&zoom=4",
              "&items_offset=",offsetX,
              sep="")
    #trouver les donnes et tester s'il y a trop de requirements
    raw_data=1
    while(nchar(raw_data) < 2000){ #avoid some problems
      Sys.sleep(sample(seq(0.8,2,0.1),1))
      #scrape the websiste 
      webpage <- GET(url,
                     httpheader=c("User-Agent"="Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3"))
      raw_data=content(webpage,as = "text",encoding = "UTF-8")
      req=raw_data[grepl("429 Too Many Requests",raw_data)]
      #if too many request, let's wait!
      if(length(req)==1){
        print(paste("error 429, ==> sleep",date()))
        Sys.sleep(sample(seq(5,20,0.2),1))}
      req=NULL
    }
    # sinon, collecter les donnees de logement par petit grille
    data<-jsonlite::fromJSON(raw_data, simplifyDataFrame = TRUE)
    page=data$explore_tabs$pagination_metadata$has_next_page
    id_1=data$explore_tabs$home_tab_metadata$remarketing_ids %>% unlist() %>% asnum()
    nb_place=data$explore_tabs$home_tab_metadata$listings_count
    if(nb_place >0){
      
      list_ing=data$explore_tabs$sections[[1]]$listings
      list_ing=list_ing[[max(length(list_ing))]]
      listing=list_ing$listing
      name=colnames(listing)
      name=name[!grepl("url",name)]
      listing=listing[,name]
      host_lang=listing$host_languages
      host_lang[[1]] %>% paste(collapse = "_")
      tmp= base::lapply(host_lang,FUN = function(x) paste(x,collapse = "_"))
      host_lang=tmp %>% unlist()
      list_lite=listing[,c(#"bathrooms",
        "bedrooms",#"beds",
        "city",
        "id",
        # "is_business_travel_ready")],
        "lat","lng",
        "localized_city",
        "person_capacity",
        "reviews_count",
        # "room_and_property_type",
        # "room_type_category",
        "room_type","space_type"
      )]
      list_lite$host_lang=host_lang
      list_lite$host_id=listing$user$id
      list_lite$rate=listing$avg_rating
      id=c(id,id_1)
      if(length(list_lite)>0){
        out=rbind(out[,colnames(list_lite)],list_lite)
      }
      out=unique(out)
      #print(paste(nrow(out),round(100*j/nrow(list_bb))))
    }
  }
  if(!is.null(out)){
    out$nb_place=nb_place
    return(out)
  }
}

#definir la zone qu'on veut trouver les logements
  bb<<-getbb(Zone)
  
  #separate des boundbox 
  list_bb=fun_split_bb(bb,500,1,proj = 4326)
  list_bb$id=seq(1,nrow(list_bb))
  #pour chaque grille, collecter des donnees
  compt=1
  bnbr=NULL
  print("exploitation en cours")
  while(length(list_bb) > 0){
    
    for(i in seq(1,nrow(list_bb))){
      # une pause pour eviter les erreurs 429(ban)
      Sys.sleep(sample(seq(1,3,0.1),1))
      
      # collecter les data 
      bnb=fun_get_bnb_info(list_bb[i,],session_id,key)
      bnb$bb_id=list_bb[i,"id"]
      if(!is.null(ncol(bnb))){
        bnbr=bind_rows(bnbr,bnb)
      }
      Sys.sleep(sample(seq(1,2,0.1),1))
      
    }
    # s'il y a plus de 300 logement dans un grille, peut etre il y a des donnees perdus
    # donc on refait pour collecter les donnees perdues
    list_doub=bnbr[which(bnbr$nb_place > 300),c("nb_place","bb_id")] %>% unique()
    bb_large=list_bb[list_bb$id %in% list_doub[,"bb_id"],c(1:4)]
    nb_tmp=list_doub$nb_place
    bb2=NULL
    bnbr$bb_id=0
    if(nrow(bb_large)>0){
      for(w in seq(1,nrow(bb_large))){
        bb_tmp=fun_split_bb(bb_large[w,] %>% as.numeric(),
                            nb_tmp[w],
                            2,proj = 4326)
        bb2=rbind(bb2,bb_tmp)
      }
      compt=compt+1
      bnbr=unique(bnbr)
      
    }
    list_bb=bb2
    if(!is.null(list_bb)){
      list_bb$id=seq(1,nrow(list_bb))
    }
  }
  # on trouve tous les logements
  
  bnbr=bnbr %>% select(-bb_id,-nb_place) %>% unique()
  bnb_sf=bnbr %>% st_as_sf(coords=c("lng","lat"),crs=4326)
  bnb_sf<-bnb_sf[!duplicated(bnb_sf$id), ]
  print("exploitation terminee")
  
  rm(bnbr)
  