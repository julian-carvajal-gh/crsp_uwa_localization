ORIGINAL_AUDIO = 'trim-original.wav';
EXPERIMENT_RECORDINGS_DIR = 'recordings_to_process'; % Selected the recordings for only a change in depth
BEST_FIT_RECORDINGS_DIR = 'best_fit_recordings';

experimentRecordings = dir(fullfile(EXPERIMENT_RECORDINGS_DIR, '*.wav'));

for i = 1: length(experimentRecordings)
    currentExperiment = fullfile(EXPERIMENT_RECORDINGS_DIR, experimentRecordings(i).name);
    currentResult = fullfile(BEST_FIT_RECORDINGS_DIR, ['best_', experimentRecordings(i).name]);
    fprintf('Trying file #%i: %s ==> %s\n', i, currentExperiment, currentResult);
    findBestWindow(ORIGINAL_AUDIO, currentExperiment, currentResult);
end

