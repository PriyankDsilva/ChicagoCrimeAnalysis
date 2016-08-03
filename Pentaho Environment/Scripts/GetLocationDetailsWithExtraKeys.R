#R Libraries
library(RODBC)
library(RJSONIO)
library(gdata)


#ODBC Connection
odbcChannel <- odbcConnect("ChicagoCrimeDB")
#GeoLocation <- sqlFetch(odbcChannel,"GeoLocationDim")#,rownames = 'GeoLocationDimKey')
GeoLocation <- sqlQuery(odbcChannel, paste("SELECT *  FROM  GeoLocationDim","WHERE ADDRESS IS NULL"))


#GeoLocation <- GeoLocation[is.na(GeoLocation$ADDRESS),]
#GeoLocation <- GeoLocation[1:24,]
#GeoLocation$CITY <- 'xxxx'

#samplee <- GeoLocation
#GeoLocation <- samplee

#sqlUpdate(odbcChannel,GeoLocation,"GeoLocationDim")

Key.Number <- 0
APIKeys <- c(#'AIzaSyDPJ84t0HUAgVF9AbP2hySEUtrzDadGvRs',
             #'AIzaSyC2hQMySJ7Z6Pk0CyQ6dH_M_6IU4FSzilE',
             #'AIzaSyDYJ6iTAK4lYt4xmmAR_Y1yKrlY7wAVsmw',
             #'AIzaSyC9hXBtv99DX4pV1ECnQovXQKhNs3WMJGs',
             #'AIzaSyDMK0Q-RLU8c4U4hpcot0VB8xPGXVZgL8A',
             #'AIzaSyCtN3poS9MydU1L55BGE6lA94DoEFUkAM8',
             #'AIzaSyAIpcCpEu-VCcQsChTwxzbu9ZY8Dobp9h0',
             #'AIzaSyDFQsxXTOzN2ejRMLW1WCFdwdMifo7rbLQ',
             #'AIzaSyDXEQLhWP-K4rG_4wNqUgJoUP8ceR9jV3E',
             #'AIzaSyD3iL-lbuiuPAkeoJNUHbqInMi3N52x374',
             #'AIzaSyDvoiwXDiIiWDdSyUOJVZPddzeQgzRrldA',
             #'AIzaSyDg6QfsA1L7eyP_qMLzUr3lIeYC97pKgEc',
             #'AIzaSyCMY2dSl4OzDx8GMvmd9JMAEnfgaO0f9P8',
             #'AIzaSyBR0sloBySDfwccBblZ0vgXsGW4aNqCu_k',
             #'AIzaSyDQMmkuC0MbIjJuGhqB6R28-yuvQPjktgw',
             #'AIzaSyBNSTN07sH9ks1lkKlaCw-7TqSwI0yNpK0',
             #'AIzaSyBP0w6qmpOagZPUSXUhxUxLGxFpW5xRZxQ',
             #'AIzaSyADgYH7OXypPUI_cIJElJku556ORV6Ck3s',
             #'AIzaSyAJIAgMVRxoFb2DQi9yf8jUQoA6nZjQ4ik',
             #'AIzaSyCNodbhI_zgwqK6PUPk4CgW4MVYp85ljvE',
             #'AIzaSyAUgEg0uPgqLzV1M4zb9e7AdgxtNSk3OYA',
             #'AIzaSyCZ7dWUpUDaghjoDCykWlybbu11WlKr1bc',
             #'AIzaSyCbVZEysjEZgqqc-2xeM4pBWwvsZWro9QM',
             #'AIzaSyDsa0F4ozFJ_4nNe6qEKyv_azQKzmYWQco',
             #'AIzaSyA9kmtM2FeC4kbIRKuEZP_jRN2_JstTXcE'
             #'AIzaSyBPaJ0du4Tx-DWpskhfsDeXQNisJxCHN6s',
             #'AIzaSyAWsAtLlQI4i1xR57Qu0mkgMLnZ3cN8lUE'
             #'AIzaSyAWsAtLlQI4i1xR57Qu0mkgMLnZ3cN8lUE',
             #'AIzaSyDw-EYY4l8Lf_KYd7z82lekMLKZV0Oy1SI'
             #'AIzaSyCADWNJ-1-A-NzEx65rF82tsfSO78Ffx0Q',
             #'AIzaSyBXVl0fBwyURDwHi9i__BMqiEBntBqQ8MY'
             #'AIzaSyAQSeJQoIvxznzeu0CnDuqdZA9E2Dz2_jM',
             #'AIzaSyCC_VJJCTmlsSN0Y-uEuPJwa98UGmh0H18'
             #'AIzaSyBPWOMaXqK8cTLWcjG13BCdtcjgVQveMuw',
             #'AIzaSyD8gXCCAG9N9r6LduSsF2s1hpEfsq1dV_Q',
  'AIzaSyCo104TR1p679J6qxTXNVt3pnO4cgLhM4w',
  'AIzaSyDeWIljSFdve9g8BKKdqwPSe-NrP15Ihq0',
  'AIzaSyDIbqWlFVvluQflp9aVNedHZaGCL2YAUIM',
  'AIzaSyAFqeuLM8R-QHeJuFGL8RbdWwBCSbvzgoI',
  'AIzaSyAun0Zw-EJl2b_DVn9ZgfQ1v7hyB7cxNEc'
    )

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
