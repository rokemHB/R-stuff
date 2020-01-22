###############################
#### Robin                 ####
####                       ####
#### PhotoRename           ####
#### by exif data          ####
####                       ####
#### v 1.1                 ####
####                       ####
#### 2020.01.10            ####
###############################

library(exifr)
library(stringr)

####################################################
#### creates list of photos in the sourceFolder ####
####################################################
    
    # change these to match your System
    sourceFolder <- "path"
   
    # list all (.csv) files in sourceFolder 
    filesToRename <- list.files(sourceFolder, ".JPG")


#########################################    
#### iterates list and renames files ####
#########################################

    for (i in 1:length(filesToRename)){ 
      
      # reads the exif data of each photo, saves (besides path) only the DateTimeOriginal in second column of dataframe
      dat <- read_exif(paste0(sourceFolder, filesToRename[i], collapse = NULL), tags = "DateTimeOriginal")

      # read and convert new name from dataframe (second column, first row), extracts numbers from string  
      currentName <- str_extract_all(dat[1,2], "\\d+")[[1]]
      
      # The as.numeric(..)+X corrects the HOUR of the time, set X relativ to timezone photo vs timezone current. 
      # If no timezone correction is needed simply use: , currentName[3], currentName[4], ...
      convertedName <- paste0(currentName[1], currentName[2], currentName[3], "_", as.numeric(currentName[4])+6, currentName[5], currentName[6], collapse = NULL)

      # rename the current file
      file.rename(paste0(sourceFolder, filesToRename[i], collapse = NULL), paste0(sourceFolder, convertedName, ".JPG", collapse = NULL))
      
      # reset variables for next iteration
      dat <- NULL
      currentName <- NULL
      convertedName <- NULL
      
    } # end of for-loop


  