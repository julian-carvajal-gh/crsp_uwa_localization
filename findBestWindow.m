function pathToResult = findBestWindow(pathToOriginal, pathToRecording)
% IMPORTANT: This function takes a long time to execute! ~15 minutes per recording!
% Use the output file for further analysis.

% What folder to write the resulting file to. Must already exist, written with Linux/macOS? filepaths in mind.
RESULTS_DIR = "best_fits/";

fprintf('FILE = %s\n', pathToRecording);

% Load the original transmitted signal and the recording from the experiment
[original, originalSampleRate] = audioread(pathToOriginal);
[recording, recordingSampleRate] = audioread(pathToRecording);

% Extract samples and make sure the sample rates match
originalSamples = resample(original, recordingSampleRate, originalSampleRate);
recordingSamples = recording(:,1);

% We look for best portion of recording so let's skip this file
if length(recordingSamples) < length(originalSamples)
    fprintf('! The recording is smaller than the original. Exiting.');
    exit;
end

% Prepare original audio for comparison
originalSamplesFft = fft(originalSamples);

WINDOW_SIZE = length(originalSamples);
numWindows = length(recordingSamples) - WINDOW_SIZE + 1;
% Greedy algorithm, we keep the best solution so far
minMse = Inf;
bestWindowNumber = 1;

for windowNumber = 1:numWindows
    currentWindow = recordingSamples(windowNumber:windowNumber + WINDOW_SIZE - 1);
    currentWindowFft = fft(currentWindow);

    mse = mean((abs(originalSamplesFft) - abs(currentWindowFft)).^2);

    % If this window is better we want to track it to compare it to others
    if mse < minMse
        minMse = mse;
        bestWindowNumber = windowNumber;
    end

end

bestWindow = recordingSamples(bestWindowNumber:bestWindowNumber + WINDOW_SIZE - 1);

fprintf('Minimum MSE: %f \nWindow: %i \n', minMse, bestWindowNumber);
fprintf('Samples in original: %i \nSamples in best window: %i \n', length(originalSamples), length(bestWindow));

pathToResult = RESULTS_DIR + "best_fit_" + pathToRecording;
audiowrite(pathToResult, bestWindow, recordingSampleRate);
fprintf('Wrote %s \n', pathToResult);

end
