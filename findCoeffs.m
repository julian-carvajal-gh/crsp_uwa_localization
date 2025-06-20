function findCoeffs(pathToOriginal, pathToBestWindow)

[original, originalSampleRate] = audioread(pathToOriginal);
[bestWindow, bestWindowSampleRate] = audioread(pathToBestWindow);
original = resample(original, bestWindowSampleRate, originalSampleRate);

% Frequency Extraction
WINDOW_SIZE = 1024;
JUMP_SIZE = WINDOW_SIZE / 2;
numFrames = floor((length(bestWindow) - WINDOW_SIZE) / JUMP_SIZE) + 1;
originalFreqs = zeros(numFrames, 1);
bestWindowFreqs = zeros(numFrames, 1);

for frameNumber = 1:numFrames
    frameStart = (frameNumber - 1) * JUMP_SIZE + 1;
    frameEnd = frameStart + WINDOW_SIZE - 1;

    originalFrame = original(frameStart:frameEnd);
    bestWindowFrame = bestWindow(frameStart:frameEnd);

    originalFrameFft = abs(fft(originalFrame, WINDOW_SIZE));
    [~, indexOriginalPeak] = max(originalFrameFft);
    originalFreqs(frameNumber) = (indexOriginalPeak - 1) * bestWindowSampleRate / WINDOW_SIZE;

    bestWindowFrameFft = abs(fft(bestWindowFrame, WINDOW_SIZE));
    [~, indexBestWindowPeak] = max(bestWindowFrameFft);
    bestWindowFreqs(frameNumber) = (indexBestWindowPeak - 1) * bestWindowSampleRate / WINDOW_SIZE;
end

% Standarization
originalFreqs = (originalFreqs - mean(originalFreqs)) / std(originalFreqs);
bestWindowFreqs = (bestWindowFreqs - mean(bestWindowFreqs)) / std(bestWindowFreqs);

% Adaptive Learning
LEARNING_RATE = 0.05;
EPOCHS = 3000;
TAPS = 32;
delta = 1e-6; % A small value to prevent division by zero
coefficients = zeros(TAPS, 1);
mseHistory = zeros(EPOCHS, 1);
predictedSignal = zeros(length(originalFreqs), 1);

for epoch = 1:EPOCHS
    for i = TAPS:length(originalFreqs)
        originalVec = originalFreqs(i:-1:i - TAPS + 1);
        predictedSignal(i) = coefficients.' * originalVec;
        error = bestWindowFreqs(i) - predictedSignal(i);

        coefficients = coefficients + LEARNING_RATE * error * originalVec / (originalVec.' * originalVec + delta);
    end

    mseHistory(epoch) = mean((bestWindowFreqs(TAPS:end) - predictedSignal(TAPS:end)).^2);

    if epoch == 1 || mod(epoch, 10) == 0
        fprintf('Epoch %i:\t MSE = %.6f \n', epoch, mseHistory(epoch));
    end

end

for tap = 1:TAPS
    fprintf('h(%d) = %.6f\n', tap - 1, coefficients(tap));
end

% Visualize MSE
figure(Name='MSE');
plot(mseHistory);
title('MSE Convergence');
xlabel('Epoch');
ylabel('Mean Squared Error (MSE)');
grid on;

end
