function findCoeffs(pathToOriginal, pathToBestWindow)

[original, originalSampleRate] = audioread(pathToOriginal);
[bestWindow, bestWindowSampleRate] = audioread(pathToBestWindow);
original = resample(original, bestWindowSampleRate, originalSampleRate);

% Frequency Extraction
WINDOW_SIZE = 1024;
numFrames = length(bestWindow) - WINDOW_SIZE + 1;

originalFreqs = zeros(numFrames, 1);
bestWindowFreqs = zeros(numFrames, 1);

for frameNumber = 1:numFrames
    frameStart = frameNumber;
    frameEnd = frameStart + WINDOW_SIZE - 1;

    originalFrame = original(frameStart:frameEnd);
    bestWindowFrame = bestWindow(frameStart:frameEnd);

    originalFrameFft = abs(fft(originalFrame));
    [~, indexOriginalPeak] = max(originalFrameFft);
    originalFreqs(frameNumber) = originalFrameFft(indexOriginalPeak);

    bestWindowFrameFft = abs(fft(bestWindowFrame));
    [~, indexBestWindowPeak] = max(bestWindowFrameFft);
    bestWindowFreqs(frameNumber) = bestWindowFrameFft(indexBestWindowPeak);
end

% Standarization
originalFreqs = (originalFreqs - mean(bestWindowFreqs)) / std(bestWindowFreqs);
bestWindowFreqs = (bestWindowFreqs - mean(bestWindowFreqs)) / std(bestWindowFreqs);

% Adaptive Learning
LEARNING_RATE = 0.0001;
EPOCHS = 200;
TAPS = 3;

coefficients = zeros(TAPS, 1);
mseHistory = zeros(EPOCHS, 1);
predictedSignal = zeros(length(originalFreqs), 1);

for epoch = 1:EPOCHS
    for i = TAPS:length(originalFreqs)
        originalVec = originalFreqs(i:-1:i - TAPS + 1);
        predictedSignal(i) = coefficients.' * originalVec;
        error = bestWindowFreqs(i) - predictedSignal(i);

        coefficients = coefficients + LEARNING_RATE * error * originalVec;
    end

    mseHistory(epoch) = mean((bestWindowFreqs(TAPS:end) - predictedSignal(TAPS:end)).^2);

    if epoch == 1 || mod(epoch, 10) == 0
        fprintf('Epoch %i:\t MSE = %.6f \n', epoch, mseHistory(epoch));
    end

end

for tap = 1:TAPS
    fprintf('h(%d) = %.6f\n', tap - 1, coefficients(tap));
end

end
