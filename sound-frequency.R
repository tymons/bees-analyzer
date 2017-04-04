source(file = "sound-utils.R")

calculateFFT <- function(samples, N) {
  fftv <- fft(samples)
  fftv <- fftv[-1]
  fftv <- ((Mod(fftv)) / (N/2))
  fftAmp = fftv[1:(N/2)];
  xf <- c(1:(N/2)) - 1
  data.frame(fftAmp,xf)
}

calculatePeakFreqWithAmp<- function(samples) {
  # Get peak frequency
  pfAmp <- max(samples$fftAmp)
  pfIdx <- which(samples$fftAmp == pfAmp)
  pf <- samples$xf[pfIdx]
  data.frame(peakFreq = pf, peakFreqAmp = pfAmp)
}

calculateSuppressedLogFFT <- function(samples, db) {
  fftDb <- 20*log10(samples$fftAmp/max(samples$fftAmp))
  fft6dBFilter = Vectorize(dget("fft6dBfilter.R"))
  fftDbFiltered <- fft6dBFilter(fftDb, db)
  data.frame(fftAmpDb = fftDbFiltered, xf = samples$xf)
}

calculateBandwidth <- function(samples, zeroLevel) {
  sum(samples != zeroLevel)
}

calculateRVF <- function(samples, lowestValue) {
  # Do reflection to get positive values 
  xf <- samples[,2]
  values <- samples[,1] - lowestValue
  # Spectral Centroid
  spectralCentroid = fastmean(xf, values)
  # RVF
  fastRMSE(xf, values)
}