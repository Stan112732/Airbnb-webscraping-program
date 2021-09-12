#ce programme a pour objectif d'exploiter des commentaire selon id de guest et ensuite d'analyser la destination habituelle

library(tidyverse)
library(rvest)
library(jsonlite)
library(httr)
Sys.setenv(RETICULATE_PYTHON = "C:/Users/HP/python/venv/Scripts/python.exe") # il faut modifiez le chemin par le chemin de python sur votre appareil  
library(reticulate)

#Charger le script Python
reticulate::py_config()
source_python("C:/Users/HP/python/ExpDestination.py")

