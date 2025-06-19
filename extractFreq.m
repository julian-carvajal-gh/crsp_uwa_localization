function [] = extractFreq()
[original, originalSampleRate] = audioread('trim-original.wav');
[recording, recordingSampleRate] = audioread('clean_output.wav');

originalSamples = resample(original, recordingSampleRate, originalSampleRate);
% Let the recording dictate the number of samples in case they dont match,
original = originalSamples(1:length(recording));

% Plot amplitude of both signals
% figure(Name='Amplitude');
% commonX = 1:length(recordingSamples);
% originalSamplesForPlot = [originalSamples; zeros(length(recordingSamples) - length(originalSamples), 1)];

% subplot(2,1,1);
% x1 = gca;
% plot(x1, commonX, originalSamplesForPlot);
% xlabel(x1, 'Sample Number');
% ylabel(x1, 'Amplitude');
% title(x1, 'Original Signal');

% subplot(2,1,2);
% x2 = gca;
% plot(x2, commonX, recordingSamples);
% xlabel(x2, 'Sample Number');
% ylabel(x2, 'Amplitude');
% title(x2, 'Recorded Signal');



% Extraction
WINDOW_SIZE = 1024;
numFrames = length(recording) - WINDOW_SIZE + 1;

extractedOriginal = zeros(numFrames);
extractedRecording = zeros(numFrames);

for frameNumber = 1:numFrames
    originalFrame = original(frameNumber:frameNumber + WINDOW_SIZE - 1);
    recordingFrame = recording(frameNumber:frameNumber + WINDOW_SIZE - 1);

    originalFrameFft = fftshift(abs(fft(originalFrame)));
    extractedOriginal(frameNumber) = originalFrameFft(WINDOW_SIZE/2 + 1);

    recordingFrameFft = fftshift(abs(fft(recordingFrame)));
    extractedRecording(frameNumber) = recordingFrameFft(WINDOW_SIZE/2 + 1);

end

end