source(file = "sound-utils.R")
source(file = "sound-time.R")
source(file = "sound-frequency.R")

xtime <- list(title = 'Czas [s]')
yamp <- list(title = 'Amplituda [mV]')
analyzeSound <- function(filename, skip) {
  soundFeatures = data.frame(RMS = 0.0,
                             meanFreqDataRaw = 0.0,
                             RVFdataRaw = 0.0,
                             bandwidth = 0.0,
                             RVFdataFiltered = 0.0,
                             meanFreqDatFiltered = 0.0)
  damping = -6
  #filename = "~/Projects/003.eUL/workspace/Ranalysis/data/temp/set2/26.csv"
  #skip = 0
  # Get file
  soundvalues <-read.csv(file=filename, skip = skip)

  # Prepare sound data for analysis
  soundDataFrame <- prepareSoundFrame(soundvalues)
  soundParams <- getSoundParams(soundDataFrame)
  
  # Time analysis
  soundFeatures$RMS <- RMS(soundDataFrame$probe)
  soundTimePlot <- plotBasics(soundDataFrame, x = soundDataFrame$time, y = soundDataFrame$probe, xtime$title, yamp$title) %>%
    layout(xaxis = xtime, yaxis = yamp )
  soundTimePlot
  # Frequency analysis
  # Get Raw FFT and supressed
  soundFFTDataFrame <- calculateFFT(soundDataFrame$probe, soundParams$N + skip)
  soundSupLogFFTDataFrame <- calculateSuppressedLogFFT(soundFFTDataFrame, damping)
  # Calculate features
  soundFreqFeatures <- calculatePeakFreqWithAmp(soundFFTDataFrame)
  soundFeatures <- merge(soundFeatures, soundFreqFeatures)
  soundFeatures$meanFreqDataRaw <- fastmean(soundFFTDataFrame$xf, soundFFTDataFrame$fftAmp)
  soundFeatures$RVFdataRaw <- calculateRVF(soundFFTDataFrame, 0)
  # Calculate features on filtered data
  soundFeatures$bandwidth <- calculateBandwidth(soundSupLogFFTDataFrame$fftAmpDb, damping)
  soundFeatures$RVFdataFiltered <- calculateRVF(soundSupLogFFTDataFrame, damping)
  soundFeatures$meanFreqDatFiltered <- fastmean(soundSupLogFFTDataFrame$xf,(soundSupLogFFTDataFrame$fftAmpDb - damping))
  
  soundFreqPlot <- plotBasics(soundFFTDataFrame, x = soundFFTDataFrame$xf, y = soundFFTDataFrame$fftAmp, 'Częstotliwość [Hz]', 'Amplituda składowej harmonicznej', color)
  soundFreqPlot
  soundFreqSubLogPlot <- plotBasics(soundSupLogFFTDataFrame, x = soundSupLogFFTDataFrame$xf, y = soundSupLogFFTDataFrame$fftAmp, 'Frequency [Hz]', 'Coefficent Amplitude [dBV]')
  subplot(soundTimePlot, soundFreqPlot, nrows = 2)
  
  # Return Sound  
  soundFeatures
}
