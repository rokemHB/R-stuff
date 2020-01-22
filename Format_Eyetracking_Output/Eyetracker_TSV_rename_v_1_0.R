###############################
#### Robin                 ####
####                       ####
#### Rename CSV/TSV        ####
#### output eyetracker     ####
####                       ####
#### Eyetracker:           ####
#### Tobii Pro Spectrum    ####
####                       ####
####                       ####
#### v 1.0                 ####
####                       ####
#### 2019.09.12            ####
###############################


###############################################################################
#### Copy all files from source to targetFolder to not overwrite originals ####
###############################################################################

#copyFiles <- function(){
    # change these to match your System
    sourceFolder <- "path"
    targetFolder <- "path"
    
    # list all (.csv) files in sourceFolder 
    fileList <- list.files(sourceFolder, ".tsv")                          ########## CHANGE THIS FOR DIFFERENT FILETYPES
   
    # copy the files from source to targetfolder
    file.copy(file.path(sourceFolder,fileList), targetFolder)

    # new list to make sure not to rename the originals
    filesToRename <- list.files(path=targetFolder, pattern = ".tsv")      ########## CHANGE THIS FOR DIFFERENT FILETYPES

    # Initialises data.frame to store unique ID's and their n of occurrences
    idList <- data.frame(BriseID=character(), Occurrences=integer(), stringsAsFactors = FALSE)
    

###################################################################################    
#### iterates list and renames files, checks for duplicates on the targetNames ####
###################################################################################

    for (i in 1:length(filesToRename)){ 
      
        # read and store individual file; TAB separated; not working on Linux, wrong encoding (for this specific output)
        currentFile <- read.csv(file = paste0(targetFolder, filesToRename[i], collapse = NULL), header=TRUE, encoding = "UTF-16LE", sep="\t", skipNul = TRUE)
        # reads targetName from file
        getFileName <- currentFile[2,4]
        
        # if targetName exists  -> Duplicate!  
        if (getFileName %in% idList$BriseID){
            
            # index where ID is stored in List
            index <- match(getFileName, idList$BriseID)
            
            # checks whether its the first duplicate of this ID -> if so overwrites first occurence of that with duplicate name
            if (idList[index, 2] == 1){
              file.rename(paste0(targetFolder, idList[index, 1], ".tsv", collapse = NULL), paste0(targetFolder, "0000_DUPLICATE_CHECK_MANUALLY_", getFileName, ".tsv", collapse = NULL))
            }
    
            # write occurrences at the end of file to indicate duplicates        
            file.rename(paste0(targetFolder, filesToRename[i], collapse = NULL), paste0(targetFolder,"0000_DUPLICATE_CHECK_MANUALLY_", getFileName, idList[index, 2], ".csv", collapse = NULL))
            idList[index, 2] <- idList[index, 2] + 1
        
        # targetName occurs for the first time  
        } else {
            
            # set new row in dataframe with the new ID
            newRow <- data.frame(BriseID=as.character(getFileName), Occurrences=1)
            idList <- rbind(idList, newRow)
            
            # renames the file of the current iteration
            file.rename(paste0(targetFolder, filesToRename[i], collapse = NULL), paste0(targetFolder, getFileName, ".tsv", collapse = NULL))
        }
    }

#######################
#### check results ####
#######################
    
    # check how many file are left (so no overwrites have happened)
    resultingFiles <- list.files(targetFolder)

    # print result
    print(idList)
    print(paste0("Es wurde mit ", length(fileList), " Dateien begonnen, am Ende sind es noch ", length(resultingFiles), " Dateien. Wir haben also ", (length(fileList) - length(resultingFiles)),  " Dateien fälschlicherweise überschrieben"))


