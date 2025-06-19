function visualAnalysis(pathToOriginal, pathToBestWindow, pathToRawRecording)
[original, originalSampleRate] = audioread(pathToOriginal);
[bestWindow, bestWindowSampleRate] = audioread(pathToBestWindow);
[recording, recordingSampleRate] = audioread(pathToRawRecording);

original = resample(original, recordingSampleRate, originalSampleRate);
recording = recording(:,1);

figure(Name='Time Domain');
% Pad these with 0's since the recording is much longer
originalForPlot = [original; zeros(length(recording) - length(original), 1)];
bestWindowForPlot = [bestWindow; zeros(length(recording) - length(bestWindow), 1)];

totalTime = length(recording) / recordingSampleRate;
timePerSample = 1 / recordingSampleRate;
commonX = timePerSample:timePerSample:totalTime;

subplot(3,1,1);
plot(commonX, originalForPlot);
xlabel('Time (seconds)');
ylabel('Sound level (amplitude)');
title('Original Signal');

subplot(3,1,2);
plot(commonX, recording);
xlabel('Time (seconds)');
ylabel('Sound level (amplitude)');
title('Experiment Recording');

subplot(3,1,3);
plot(commonX, bestWindowForPlot);
xlabel('Time (seconds)');
ylabel('Sound level (amplitude)');
title('Best Window');

figure(Name='Frequency Domain');

originalRes = recordingSampleRate/length(originalForPlot);
originalX = (originalRes:originalRes:recordingSampleRate) - recordingSampleRate / 2;
originalFft = fft(originalForPlot);
originalPsd = 20*log10(abs(circshift(originalFft,floor(length(originalForPlot)/2))));

subplot(3,1,1);
plot(originalX, originalPsd);
xlabel('Frequency (Hz)');
ylabel('Power spectral density (dB)');
title('Original Signal');

recordingRes = recordingSampleRate/length(recording);
recordingX = (recordingRes:recordingRes:recordingSampleRate) - recordingSampleRate / 2;
recordingFft = fft(recording);
recordingPsd = 20*log10(abs(circshift(recordingFft,floor(length(recording)/2))));

subplot(3,1,2);
plot(recordingX, recordingPsd);
xlabel('Frequency (Hz)');
ylabel('Power spectral density (dB)');
title('Experiment Recording');

bestWindowRes = recordingSampleRate/length(bestWindowForPlot);
bestWindowX = (bestWindowRes:bestWindowRes:recordingSampleRate) - recordingSampleRate / 2;
bestWindowFft = fft(bestWindowForPlot);
bestWindowPsd = 20*log10(abs(circshift(bestWindowFft,floor(length(bestWindowForPlot)/2))));

subplot(3,1,3);
plot(bestWindowX, bestWindowPsd);
xlabel('Frequency (Hz)');
ylabel('Power spectral density (dB)');
title('Best Window');

end
