#R Libraries
library(RODBC)
library(RJSONIO)
library(gdata)


#ODBC Connection
odbcChannel <- odbcConnect("ChicagoCrimeDB")
#GeoLocation <- sqlFetch(odbcChannel,"GeoLocationDim")#,rownames = 'GeoLocationDimKey')
GeoLocation <- sqlQuery(odbcChannel, paste("SELECT  *  FROM  GeoLocationDim","WHERE ADDRESS IS NULL"))


#GeoLocation <- GeoLocation[is.na(GeoLocation$ADDRESS),]
#GeoLocation <- GeoLocation[1:24,]
#GeoLocation$CITY <- 'xxxx'

#samplee <- GeoLocation
#GeoLocation <- samplee

#sqlUpdate(odbcChannel,GeoLocation,"GeoLocationDim")

Key.Number <- 0
APIKeys <- c('AIzaSyDPJ84t0HUAgVF9AbP2hySEUtrzDadGvRs',
             'AIzaSyDYJ6iTAK4lYt4xmmAR_Y1yKrlY7wAVsmw',
             'AIzaSyC2hQMySJ7Z6Pk0CyQ6dH_M_6IU4FSzilE',
             'AIzaSyC9hXBtv99DX4pV1ECnQovXQKhNs3WMJGs',
             'AIzaSyDMK0Q-RLU8c4U4hpcot0VB8xPGXVZgL8A')

if(dim(GeoLocation)[1] != 0){
  print("Fetch Data for Location")
  #For Loop to Capture the Address through LAtitude Longitude
  for(i in seq(1:dim(GeoLocation)[1])){
    Key.Number <- Key.Number + 1
    Latitude <- GeoLocation[i,'Latitude']
    Longitude <- GeoLocation[i,'Longitude']
    RevGeoURL <- paste0('https://maps.googleapis.com/maps/api/geocode/json?latlng=',Latitude,',',
                        Longitude,'&sensor=false&key=',APIKeys[Key.Number])
    JSON.Out <- fromJSON(RevGeoURL)
    print(paste0('Process : ',i,' Url : ',RevGeoURL))
    
    Location <- JSON.Out$results[[1]]$formatted_address
    print(paste0('Location : ',Location))
    
    
    GeoLocation[i,'ADDRESS'] <- strsplit(Location,',')[[1]][1]
    GeoLocation[i,'CITY'] <- trim(strsplit(Location,',')[[1]][length(strsplit(Location,',')[[1]])-2])
    GeoLocation[i,'ST'] <- strsplit(trim(strsplit(Location,',')[[1]][(length(strsplit(Location,',')[[1]])-1)]),' ')[[1]][1]
    GeoLocation[i,'ZIP'] <- strsplit(trim(strsplit(Location,',')[[1]][(length(strsplit(Location,',')[[1]])-1)]),' ')[[1]][2]
    GeoLocation[i,'COUNTRY'] <- trim(strsplit(Location,',')[[1]][length(strsplit(Location,',')[[1]])])
    
    if(Key.Number == 5){
      Key.Number <- 0
    }
  }
  
  ##Update Database 
  odbcChannel <- odbcConnect("ChicagoCrimeDB")
  sqlUpdate(odbcChannel,GeoLocation,"GeoLocationDim")
  
}else{
  print("Table UptoDate.No Need of Update")
}


close(odbcChannel)


#http://api.v3.factual.com/t/places?geo={"$point":[41.773229362,-87.59672304]}
#http://maps.googleapis.com/maps/api/geocode/json?latlng=41.773229362,-87.59672304&sensor=false
