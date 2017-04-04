library(plotly)
source("sound-params.R")

prepareSoundFrame <- function(samples) {
  names(samples) <- "probe"
  N = length(samples$probe)
  duration <- (N - 1) * cycle
  x <- seq(0, duration, cycle)
  samples["time"] <- x
  samples
}

getSoundParams <- function(samples) {
  N = length(samples$probe)
  duration <- (N - 1) * cycle
  data.frame(freq = samplingFreq, cycle = cycle, N = N, duration = duration)
}

plotBasics <- function(dataFrame, x, y, titlex, titley) {
 plot_ly(dataFrame, x = ~x, y = ~y, type = 'scatter', mode = 'lines') %>% 
    layout(xaxis = list(title = titlex), yaxis = list(title = titley)) 
}

fastmean <- function(x, y) {
  sum(x*y)/sum(y)
}
 
fastRMSE <- function(x, y) {
  mu <- fastmean(x, y)
  sqrt(sum(y*(x-mu)^2)/(sum(y)-1))
}

RMS <- function(samples) {
  sqrt(mean(samples^2))
}