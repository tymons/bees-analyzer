timeAnalyzeSound <- function(samples) {
  RMS <- sqrt(mean(samples^2))
  data.frame(RMS = RMS)
}


