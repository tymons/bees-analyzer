prepareFFT <- function(samples, N) {
  fftv <- fft(samples)
  fftv <- fftv[-1]
  fftv <- ((Mod(fftv)) / (N/2))
  fftAmp = fftv[1:(N/2)];
  xf <- c(1:(N/2)) - 1
  data.frame(fftAmp,xf)
}

freqAnalyzeSound <- function(samples) {
  # Get peak frequency
  pfAmp <- max(samples$fftAmp)
  pfIdx <- which(samples$fftAmp == pfAmp)
  pf <- samples$xf[pfIdx]
  
  # Spectral Centroid
  spectralCentroid = weighted.mean(samples$xf, samples$fftAmp)
  
  data.frame(peakFreq = pf, peakFreqAmp = pfAmp, meanFreq = spectralCentroid)
}

getSuppressedLogFFT <- function(samples, db) {
  fftDb <- 20*log10(samples$fftAmp/max(samples$fftAmp))
  fft6dBFilter = Vectorize(dget("fft6dBfilter.R"))
  fftDbFiltered <- fft6dBFilter(fftDb, db)
  data.frame(fftAmpDb = fftDbFiltered, xf = samples$xf)
}

getBandwidth <- function(samples, zeroLevel) {
  bandwidth <- sum(samples != zeroLevel)
  bandwidth
}