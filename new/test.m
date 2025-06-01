[x, fs] = audioread('testoriginal.Wav');
original = resample(x, 441, 1700);
w_size = length(original);
original_fft = fft(original);
norm_original_fft = abs(original_fft)/max(abs(original_fft));
% norm_original_fft = abs(original_fft);

[x0, fs0] = audioread('testreceived.wav');
received = x0(:,1);
mses = zeros(length(received) - w_size + 1, 1);

for i = 1:length(received)-w_size+1
    w_start = i;
    w_end = w_start+w_size-1; 
    current_window = received(w_start:w_end);
    curr_w_fft = fft(current_window);
    curr_w_norm = abs(curr_w_fft)/max(abs(curr_w_fft));
    % curr_w_norm = abs(curr_w_fft);
    for k = 1:w_size
        err_squared = (curr_w_norm(k) - norm_original_fft(k))^2; 
        mses(i) = mses(i) + err_squared;
    end
    mses(i) = sqrt(mses(i)/w_size);
end

[min_mse, i] = min(mses);
fprintf('Minimum MSE at location: %f, %d\n', min_mse,i);

%{
w_start = i;
w_end = w_start + w_size - 1;
best_slice = received(w_start:w_end);
    
% 2. Framing 
frame_size = 1024;
num_frames = length(original)-frame_size+1;

x_ff = zeros(num_frames,1);
y_ff = zeros(num_frames,1);
%why is y_ff using num_frames?

for n = 1:num_frames
    orig_frame = original(n: n+frame_size-1);
    orig_fft = fftshift(abs(fft(orig_frame)));
    x_ff(n) = orig_fft(abs(frame_size/2+1));
            
    rec_frame = best_slice(n: n+frame_size-1);
    rec_fft = fftshift(abs(fft(rec_frame)));
    y_ff(n) = rec_fft(abs(frame_size/2+1));
end
%}