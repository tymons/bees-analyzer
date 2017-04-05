source(file = "sound-utils.R")
source(file = "sound-time.R")
source(file = "sound-frequency.R")

soundFeatures = data.frame(RMS = 0.0,
                           meanFreqDataRaw = 0.0,
                           RVFdataRaw = 0.0,
                           bandwidth = 0.0,
                           RVFdataFiltered = 0.0,
                           meanFreqDatFiltered = 0.0) 

analyzeSound <- function(filename) {
  damping = -6
  
  # Get file
  soundvalues <-read.csv(file="~/Projects/003.eUL/workspace/Ranalysis/data/csvresults/mic1/1890-2017-04-04T15:45:30-soundvalues.csv" ,sep=" ", skip = 400)

  # Prepare sound data for analysis
  soundDataFrame <- prepareSoundFrame(soundvalues)
  soundParams <- getSoundParams(soundDataFrame)
  
  # Time analysis
  soundFeatures$RMS <- RMS(soundDataFrame$probe)
  soundTimePlot <- plotBasics(soundDataFrame, x = soundDataFrame$time, y = soundDataFrame$probe, 'Time [s]', 'Amplitude [mV]')
  
  # Frequency analysis
  # Get Raw FFT and supressed
  soundFFTDataFrame <- calculateFFT(soundDataFrame$probe, soundParams$N)
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
  
  soundFreqPlot <- plotBasics(soundFFTDataFrame, x = soundFFTDataFrame$xf, y = soundFFTDataFrame$fftAmp, 'Frequency [Hz]', 'Coefficent Amplitude')
  soundFreqSubLogPlot <- plotBasics(soundSupLogFFTDataFrame, x = soundSupLogFFTDataFrame$xf, y = soundSupLogFFTDataFrame$fftAmp, 'Frequency [Hz]', 'Coefficent Amplitude [dBV]')
  subplot(soundFreqPlot, soundFreqSubLogPlot, nrows = 2)
  
  # Return Sound  
  soundFeatures
}