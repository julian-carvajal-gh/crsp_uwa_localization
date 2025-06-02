% Load and resample of original audio signal
[x, fs] = audioread('original.wav');
original = resample(x, 44100, 170000);
w_size = length(original);
original_fft = abs(fft(original));
norm_original_fft = original_fft / max(original_fft);

% Load received audio signal
[x0, fs0] = audioread('R1A.wav');
received = x0(:,1); % extracting first channel (stereo to mono)

% Parameters
step = 100;
num_steps = floor((length(received) - w_size + 1)/step);
mses = zeros(num_steps, 1);
positions = zeros(num_steps, 1);

% Sliding window to find best window with step size = step
idx = 1;
for i = 1:step:(length(received) - w_size + 1)
    w_start = i;
    w_end = w_start + w_size - 1;
    current_window = received(w_start:w_end);

    curr_w_fft = abs(fft(current_window));
    curr_w_norm = curr_w_fft / max(curr_w_fft);
    
    % MSE Calculation
    err_squared = sum((curr_w_norm - norm_original_fft).^2);
    mses(idx) = sqrt(err_squared / w_size);
    positions(idx) = i;
    idx = idx + 1;
end

[min_mse, min_idx] = min(mses);
best_position = positions(min_idx);
fprintf('Minimum MSE at location: %f, index in received: %d\n', min_mse, best_position);

% Best window extraction in time domain
Xre_portion = received(best_position:best_position + w_size - 1);

% ---- Framing and zero frequency extraction ----
frame_size = 1024;
num_frames = w_size - frame_size + 1;

x_ff = zeros(num_frames,1);
y_ff = zeros(num_frames,1);

for n = 1:num_frames
    orig_frame = original(n : n + frame_size - 1);
    orig_fft = fftshift(abs(fft(orig_frame)));
    x_ff(n) = orig_fft(frame_size/2 + 1);

    rec_frame = Xre_portion(n : n + frame_size - 1);
    rec_fft = fftshift(abs(fft(rec_frame)));
    y_ff(n) = rec_fft(frame_size/2 + 1);
end

% ---- Adaptative LMS Filter ----
u = 0.009; % Learning rate
epoch = 200;
order = 3; % Taps or order of the FIR filter
h = zeros(order,1);
delta = 1e-3;

mse_history = zeros(epoch,1);
y_pred = zeros(length(x_ff), 1);

% Standarization
x_ff = (x_ff - mean(x_ff)) / std(x_ff);
y_ff = (y_ff - mean(y_ff)) / std(y_ff);

%x_ff = abs(x_ff) / max(abs(x_ff));
%y_ff = abs(y_ff) / max(abs(y_ff));

%LMS Algorithm or NLMS if h is normalized
for i = 1:epoch
    for k = order:length(x_ff)
        x_vec = x_ff(k:-1:k-order+1);
        y_pred(k) = h.' * x_vec;
        error = y_ff(k) - y_pred(k);

        h = h + u * error * x_vec / ((x_vec'*x_vec) + delta);
    end
    mse_history(i) = mean((y_ff(order:end) - y_pred(order:end)).^2);
    if mod(i,10) == 0
        fprintf('Iter %d: MSE=%.6f\n', i, mse_history(i));
    end
end

fprintf('\nOptimal coefficients (order=%d):\n', order);
for j = 1:order
    fprintf('h%d = %.4f\n', j-1, real(h(j)));
end

% ---- Graphs ----
figure;
subplot(3,1,1);
plot(abs(y_ff), 'g');
ylabel('Magnitude');
xlabel('Frame index')
legend('Received');

subplot(3,1,2);
plot(abs(y_pred), 'b');
ylabel('Magnitude');
xlabel('Frame index')
legend('Predict');

subplot(3,1,3);
plot(abs(y_ff), 'g');
hold on;
plot(abs(y_pred), 'b');
hold off;
ylabel('Magnitude');
xlabel('Frame index');
legend('Received', 'Predicted');

figure;
subplot(3,1,1);
plot(mse_history);
title('MSE');
xlabel('Epoch');

subplot(3,1,2);
plot(real(h), '-o');
title('Final Coefficients h');
xlabel('Index');
ylabel('Value');
grid on;

subplot(3,1,3);
plot(abs(x_ff), 'r');
hold on;
plot(abs(y_ff), 'g');
hold off;
ylabel('Magnitude');
xlabel('Frame index');
legend('Original', 'Received');