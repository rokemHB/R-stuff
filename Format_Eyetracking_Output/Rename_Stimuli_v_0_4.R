###############################################################################################
####                                                                                       ####
####      Title:      Copy AOI column in Eyetracker Output                                 ####
####                    Copy&Pastes entries in 100.000+ row csv files between columns      ####
####                                                                                       ####
####      Disclaimer: This is work in progress and should be written in a cleaner way      ####
####                  but was only needed once to correct some other mistakes.             ####
####                                                                                       ####
####      Author:     Robin                                                                ####
####      Date:       15.11.2019                                                           ####
####      Version:    0.4                                                                  ####
####                                                                                       ####
###############################################################################################

###############################################################################
#### Copy all files from source to targetFolder to not overwrite originals ####
###############################################################################

# change these to match your System
sourceFolder <- "path"
targetFolder <- "path"

# list all (.csv) files in sourceFolder 
fileList <- list.files(sourceFolder, ".tsv")                          ########## CHANGE THIS FOR DIFFERENT FILETYPES

# copy the files from source to targetfolder
file.copy(file.path(sourceFolder,fileList), targetFolder)

# new list to make sure not to rename the originals
filesToIterate <- list.files(path=targetFolder, pattern = ".tsv")      ########## CHANGE THIS FOR DIFFERENT FILETYPES


for (j in 1:length(filesToIterate)) { #Outer-loop

  currentFile <- read.csv(file = paste0(targetFolder, filesToIterate[j], collapse = NULL),  header=TRUE, encoding = "UTF-16LE", sep="\t", skipNul = TRUE)
    
  rowCount <- 0
  # Reihenfolge in welcher die Dinge im Output erscheinen
  catFlag <- FALSE
  spoonFlag <- FALSE
  cookieFlag <- FALSE
  bookFlag <- FALSE
  secondRound <- FALSE # wird true wenn die anderen 4 alle == TRUE sind && counterHelpter > i + 1000
  counterHelper <- 0 # Damit secondRound nicht True wird nachdem die erste Reihe von der bookFlag durch ist
  
  # IN DER ÄUßEREN SCHLEIFE:
  # AOI Ball Spalte löschen:
  currentFile$AOI.hit..Ball. = NULL
  
  
  
  for (i in 1:nrow(data.table::fread(paste0(targetFolder, filesToIterate[j], collapse = NULL)))) { # inner-loop
   
    #Flags setzen:
    if (currentFile$Presented.Media.name[i] == "Katze_Hund.jpg" && catFlag == FALSE) {
      catFlag <- TRUE
    }
    if (currentFile$Presented.Media.name[i] == "Löffel_Flasche.jpg" && spoonFlag == FALSE) {
      spoonFlag <- TRUE
    }
    if (currentFile$Presented.Media.name[i] == "Keks_Banane.jpg" && cookieFlag == FALSE) {
      cookieFlag <- TRUE
    }
    if (currentFile$Presented.Media.name[i] == "Buch_Ball.jpg" && bookFlag == FALSE) {
      spoonFlag <- TRUE
      counterHelper <- i #um die ersten Zeilen mit BuchBall zu überspringen
    }
    
    #### Prüfen, ob alle 4 Flags gesetzt sind --> dann sind die ersten 4 Stimuli durch 
    #### und danach kann das kopieren beginnen
    
    if (secondRound == FALSE &&
        catFlag == TRUE && 
        spoonFlag == TRUE && 
        cookieFlag == TRUE && 
        spoonFlag == TRUE &&
        # Die 1000 muss evtl angepasst werden, pro stim idr 625 Zeilen... Also abhängig von presentationduration/hz
        i > (counterHelper + 1000)) {
      secondRound <- TRUE
      print("SECOND ROUND WURDE ERKANNT")
    }
    
    #### Hier muss nun beim Vorkommen die Spalte kopiert werden!!
    
    if (currentFile$Presented.Media.name[i] == "Katze_Hund.jpg" && secondRound == TRUE) {
      print ("Katze_Kopie") # NUR ZUM TESTEN, wenns funktioniert löschen!!
      #Spalten kopieren
      currentFile$AOI.hit..Hund_Katze...Katze_miss.[i] = currentFile$AOI.hit..Katze_Hund...Katze_hit.[i]
      currentFile$AOI.hit..Hund_Katze...Hund_hit. [i] = currentFile$AOI.hit..Katze_Hund...Hund_miss.[i]
      # alte Eintraege loeschen
      currentFile$AOI.hit..Katze_Hund...Katze_hit.[i] = NA
      currentFile$AOI.hit..Katze_Hund...Hund_miss.[i] = NA
    }
    if (currentFile$Presented.Media.name[i] == "Löffel_Flasche.jpg" && secondRound == TRUE) {
      print ("loefflKopie")
      #Spalten kopieren
      currentFile$AOI.hit..Flasche_LÃ.ffel...Flasche_miss.[i] = currentFile$AOI.hit..LÃ.ffel_Flasche...Flasche_hit.[i]
      currentFile$AOI.hit..Flasche_LÃ.ffel...Loeffel_hit.[i] = currentFile$AOI.hit..LÃ.ffel_Flasche...Loeffel_miss.[i]
      # alte Eintraege loeschen
      currentFile$AOI.hit..LÃ.ffel_Flasche...Flasche_hit.[i] = NA
      currentFile$AOI.hit..LÃ.ffel_Flasche...Loeffel_miss.[i] = NA
    }
    ###
    if (currentFile$Presented.Media.name[i] == "Keks_Banane.jpg" && secondRound == TRUE) {
      print ("cookieKopie")
      #Spalten kopieren
      currentFile$AOI.hit..Banane_Keks...Banane_miss.[i] = currentFile$AOI.hit..Keks_Banane...Banane_hit.[i]
      currentFile$AOI.hit..Banane_Keks...Keks_hit.[i] = currentFile$AOI.hit..Keks_Banane...Keks_miss.[i]
      # alte Eintraege loeschen
      currentFile$AOI.hit..Keks_Banane...Keks_miss.[i] = NA
      currentFile$AOI.hit..LÃ.ffel_Flasche...Loeffel_miss.[i] = NA
    }
    if (currentFile$Presented.Media.name[i] == "Buch_Ball.jpg" && secondRound == TRUE) {
      print ("ballKopie")
      #Spalten kopieren
      currentFile$AOI.hit..Buch_Ball...Ball_miss.[i] = currentFile$AOI.hit..Ball_Buch...Ball_hit.[i]
      currentFile$AOI.hit..Buch_Ball...Buch_hit.[i] = currentFile$AOI.hit..Ball_Buch...Buch_miss.[i]
      # alte Eintraege loeschen
      currentFile$AOI.hit..Ball_Buch...Buch_miss.[i] = NA
      currentFile$AOI.hit..Ball_Buch...Ball_hit.[i] = NA
    }
  
  } # end of inner-loop
  
  # File scheint zu stimmen aber Excel stellt es verrückt dar
  write.table(currentFile, file = paste0(targetFolder, filesToIterate[j], collapse = NULL),fileEncoding = "UTF-16LE", sep = "\t", row.names = FALSE, quote = FALSE)

} # end of outer-loop

