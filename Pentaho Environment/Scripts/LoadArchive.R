#Set Working Environment
SourceLoc <- 'C:/Users/Priyank/OneDrive/Documents/MIS/BI/Project/Pentaho Environment/Sources'
LoadArchiveLoc <- 'C:/Users/Priyank/OneDrive/Documents/MIS/BI/Project/Pentaho Environment/Sources/LoadArchive'

# Load 
SysDate <- Sys.time()
SysDate.Numeric <- as.numeric(unlist(strsplit(gsub("[^0-9]", "", unlist(SysDate)), "")))
CurrentDate <- paste0(SysDate.Numeric[1],SysDate.Numeric[2],SysDate.Numeric[3],SysDate.Numeric[4],
                      SysDate.Numeric[5],SysDate.Numeric[6],SysDate.Numeric[7],SysDate.Numeric[8],
                      SysDate.Numeric[9],SysDate.Numeric[10],SysDate.Numeric[11],SysDate.Numeric[12],
                      SysDate.Numeric[13],SysDate.Numeric[14])

MoveFolderLoc <- paste0(LoadArchiveLoc,'/',CurrentDate)
dir.create(MoveFolderLoc)


my.file.rename <- function(from, to) {
  todir <- dirname(to)
  if (!isTRUE(file.info(todir)$isdir)) dir.create(todir, recursive=TRUE)
  file.rename(from = from,  to = to)
}

IUCRFileName <- 'IUCR_Codes.xls'
ChicagoCrimeFileName <- 'Crimes.csv'
PoliceStationFileName <- 'Police_Stations.xls'
SeniorCenterFileName <- 'Senior_Centers.xls'


my.file.rename(from = paste0(SourceLoc,'/',IUCRFileName),to =  paste0(MoveFolderLoc,'/',IUCRFileName))
my.file.rename(from = paste0(SourceLoc,'/',ChicagoCrimeFileName),to =  paste0(MoveFolderLoc,'/',ChicagoCrimeFileName))
my.file.rename(from = paste0(SourceLoc,'/',PoliceStationFileName),to =  paste0(MoveFolderLoc,'/',PoliceStationFileName))
my.file.rename(from = paste0(SourceLoc,'/',SeniorCenterFileName),to =  paste0(MoveFolderLoc,'/',SeniorCenterFileName))

setwd(MoveFolderLoc)
ArchiveFilesName = list.files(MoveFolderLoc, recursive = TRUE)
zip(zipfile = CurrentDate, files=ArchiveFilesName)
setwd(LoadArchiveLoc)

#Move File
my.file.rename(from = paste0(MoveFolderLoc,'/',CurrentDate,'.zip'),to =  paste0(LoadArchiveLoc,'/',CurrentDate,'.zip'))

#Delete Folder
unlink(MoveFolderLoc,recursive = TRUE) 




