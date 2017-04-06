library(readr)
library(plotly)
source(file = "sound.R")
source(file = "sound-utils.R")

dirName <- "full"

dataTempDir <- paste0("~/Projects/003.eUL/workspace/Ranalysis/data/temp/", dirName, "/temperatures.csv")
dataHumDir <- paste0("~/Projects/003.eUL/workspace/Ranalysis/data/temp/", dirName, "/humidities.csv")

temperaturevalues <- read_csv(dataTempDir, col_names = FALSE)
humidityvalues <- read_csv(dataHumDir, col_names = FALSE)
colnames(temperaturevalues) <- "temperature"
colnames(humidityvalues) <- "humidity"

soundFeatures = data.frame()
for(i in 0:(length(temperaturevalues$temperature)-1)) {
  soundFeatures = rbind(soundFeatures, analyzeSound(paste0("~/Projects/003.eUL/workspace/Ranalysis/data/temp/", dirName,"/", i, ".csv"), 400))
}

soundFeatures["Temp"] <- temperaturevalues
soundFeatures["Hum"] <- humidityvalues

corrMatrix = matrix(nrow=length(soundFeatures), ncol=length(soundFeatures)) 
dimnames(corrMatrix) = list(colnames(soundFeatures), colnames(soundFeatures)) 

for(i in 1:nrow(corrMatrix)) {
  for(j in 1:ncol(corrMatrix)) {
    corrMatrix[i, j] = cor(soundFeatures[, i], soundFeatures[, j])
  }
}

