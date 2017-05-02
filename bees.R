library(readr)
library(plotly)
source(file = "sound.R")
source(file = "sound-utils.R")

dirName <- "full"

dataTempDir <- paste0("~/Projects/003.eUL/workspace/Ranalysis/data/temp/", dirName, "/temperatures.csv")
dataHumDir <- paste0("~/Projects/003.eUL/workspace/Ranalysis/data/temp/", dirName, "/humidities.csv")
dataTempOutDir <- paste0("~/Projects/003.eUL/workspace/Ranalysis/data/temp/", dirName, "/temperature-outdoor.csv")
dataHumOutDir <- paste0("~/Projects/003.eUL/workspace/Ranalysis/data/temp/", dirName, "/humidities-outdoor.csv")
dataPressOutDir <- paste0("~/Projects/003.eUL/workspace/Ranalysis/data/temp/", dirName, "/pressure-outdoor.csv")

temperatureValues <- read_csv(dataTempDir, col_names = FALSE)
humidityValues <- read_csv(dataHumDir, col_names = FALSE)
temperatureOutValues <- read_csv(dataTempOutDir, col_names = FALSE)
humidityOutValues <- read_csv(dataHumOutDir, col_names = FALSE)
pressureOutValues <- read_csv(dataPressOutDir, col_names = FALSE)

colnames(temperatureValues) <- "Temperature"
colnames(humidityValues) <- "Humidity"
colnames(temperatureOutValues) <- "Temperature-outdoor"
colnames(humidityOutValues) <- "Humidity-outdoor"
colnames(pressureOutValues) <- "Pressure-outdoor"

soundFeatures = data.frame()
for(i in 0:(length(temperatureValues$Temperature)-1)) {
  soundFeatures = rbind(soundFeatures, analyzeSound(paste0("~/Projects/003.eUL/workspace/Ranalysis/data/temp/", dirName,"/", i, ".csv"), 400))
}

soundFeatures["Temperature"] <- temperatureValues
soundFeatures["Humidity"] <- humidityValues
soundFeatures["Temperature-outdoor"] <- temperatureOutValues
soundFeatures["Humidity-outdoor"] <- humidityOutValues
soundFeatures["Pressure-outdoor"] <- pressureOutValues

corrMatrix = matrix(nrow=length(soundFeatures), ncol=length(soundFeatures)) 
dimnames(corrMatrix) = list(colnames(soundFeatures), colnames(soundFeatures)) 

for(i in 1:nrow(corrMatrix)) {
  for(j in 1:ncol(corrMatrix)) {
    corrMatrix[i, j] = cor(soundFeatures[, i], soundFeatures[, j])
  }
}

