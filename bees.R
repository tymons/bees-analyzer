library(readr)
library(plotly)
source(file = "sound.R")
source(file = "sound-utils.R")


temperaturevalues <- read_csv("~/Projects/003.eUL/workspace/Ranalysis/data/csvresults/thermal/temperature/2017-04-02T10:00:00 to 2017-04-04T23:23:20-temperaturevalues.csv", n_max = 800)
humidityvalues <- read_csv("~/Projects/003.eUL/workspace/Ranalysis/data/csvresults/thermal/humidity/2017-04-02T10:00:00 to 2017-04-04T23:23:38-humidityvalues.csv", n_max = 800)

thermalData = data.frame(temp = temperaturevalues$value, hum = humidityvalues$value)

for(i in 1000:1890) {
  
  #soundFeaturesData = analyzeSound("~/Projects/003.eUL/workspace/Ranalysis/data/csvresults/mic1/1890-2017-04-04T15:45:30-soundvalues.csv")   
  #soundFeaturesDataSet = rbind(soundFeaturesDataSet,soundFeaturesData)
}


cor(thermalData$temp, thermalData$hum)

