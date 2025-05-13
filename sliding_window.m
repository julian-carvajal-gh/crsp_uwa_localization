% Two parts
% 1) Get the recording to be the same length as trasmission by finding
% the best window. Use FFT to compare going along the time domain sequence.
% Return the time domain sequences.
% 
% 2) Get the frequency response for the new_recording and transmission by
% choosing a small window of time domain like len(1024) and do fft for it,
% extract that first value and add to dynamic vector.
% The resulting values will be the frequency domain of the "clean" recording and
% of the transmission.

% TODO: Create different plots for poster display purposes

function best_window = sliding_window(transmission_filename, recording_filename)

% Load the files
[transmission_samples, transmission_sr] = audioread(transmission_filename);
[recording_samples,recording_sr]=audioread(recording_filename);

% Resample them for computation time
% TODO: Should these be the same sample rate? If so, fix and write in the same way
[p,q] = rat(400/transmission_sr); % resampling helpers
transmission_resampled = resample(transmission_samples, p, q);
recording_resampled = resample(recording_samples, 8000, recording_sr);

% FFT analysis we will compare windows to
transmission_fft=fft(transmission_resampled);
normal_transmission_fft=transmission_fft/max(abs(transmission_fft));
normal_transmission_fft=abs(normal_transmission_fft);

% Extract the first column, appropriate for mono audio
% TODO: Do we need to extract the first column for the transmission as well?
recording=recording_samples(:,1);

% Use the length of the known signal as size of the window we're looking for
transmission_length = length(transmission_resampled);

if length(recording) < transmission_length
    % In order to choose a best window from the recording,
    % the recording must be longer than the original we compare to.
    fprintf("WAV received is shorter than original.\n");
end

recording_frequency_domain = [];

mses=zeros(length(recording)-transmission_length+1,1);
for i=1:length(recording)-transmission_length+1
    window_start=i;
    window_end=window_start+transmission_length-1;
    current_window=recording(window_start:window_end);
    current_window_fft=fft(current_window);

    normalized_current_window_fft=current_window_fft/max(abs(current_window_fft));
    normalized_current_window_fft=abs(normalized_current_window_fft);
    % EXTRACT FIRST FFT VALUE HERE
    first_freq = normalized_current_window_fft(1);
    % TODO need to add circle shift because we want the first freq
    % when the origin is the middle of symmetrical freq response
    % ADD IT TO THE VECTOR
    recording_frequency_domain(end+1) = first_freq;

    for j=1:transmission_length
        err_squared=(normalized_current_window_fft(j)-normal_transmission_fft(j));
        err_squared=err_squared*err_squared;
        mses(i) = mses(i)+err_squared;
    end
    mses(i)=sqrt(mses(i)/transmission_length);
end

[min_mse,i] = min(mses);
% Display the minimum MSE value
fprintf('Minimum MSE at location: %f, %d\n', min_mse,i);

% Do we extract the frequency doman from the extracted portion?
%extract portion
window_start=i;
window_end=window_start+transmission_length-1;
Xre_portion=recording(window_start:window_end);%length=N
FX_portion=fft(Xre_portion);
FX_N_portion=FX_portion/max(abs(FX_portion));
FX_N_portion=abs(FX_N_portion);

best_window = Xre_portion;
% Return recording in frequency domain?

end
