source(file = "sound-utils.R")
source(file = "sound-time.R")
source(file = "sound-frequency.R")

# Get file
soundvalues <-read.csv(file="~/Projects/003.eUL/workspace/Ranalysis/data/csvresults/mic1/1608-2017-04-01T11:15:30-soundvalues.csv",sep=" ", skip = 400)

# Prepare sound data for analysis
soundDataFrame <- prepareSoundFrame(soundvalues)
soundParams <- getSoundParams(soundDataFrame)

# Time analysis
soundTimeFaetures <- timeAnalyzeSound(soundDataFrame$probe)
soundTimePlot <- plotBasics(soundDataFrame, x = soundDataFrame$time, y = soundDataFrame$probe, 'Time [s]', 'Amplitude [mV]')

# Frequency analysis
soundFFTDataFrame <- prepareFFT(soundDataFrame$probe, soundParams$N)
soundFreqFeatures <- freqAnalyzeSound(soundFFTDataFrame)
soundSupLogFFTDataFrame <- getSuppressedLogFFT(soundFFTDataFrame, -6)
soundFreqFeatures["bandwidth"] <- getBandwidth(soundSupLogFFTDataFrame$fftAmpDb, -6)
soundFreqPlot <- plotBasics(soundFFTDataFrame, x = soundFFTDataFrame$xf, y = soundFFTDataFrame$fftAmp, 'Frequency [Hz]', 'Coefficent Amplitude')
soundFreqSubLogPlot <- plotBasics(soundSupLogFFTDataFrame, x = soundSupLogFFTDataFrame$xf, y = soundSupLogFFTDataFrame$fftAmp, 'Frequency [Hz]', 'Coefficent Amplitude [dBV]')
subplot(soundFreqPlot, soundFreqSubLogPlot, nrows = 2)

soundFeatures <- merge(soundTimeFaetures, soundFreqFeatures)


