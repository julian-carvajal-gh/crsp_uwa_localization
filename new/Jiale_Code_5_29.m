    
    % [x, fs] = audioread('original.Wav');% 1. 滑动窗口 Slide Window
    [x, fs] = audioread('testoriginal.wav');
    rs = resample(x, 441, 1700);%customize depend on each wav file 每个文件不同的sample rate

    N = length(rs);
    FX_rs = fft(rs);
    % FX_rs_N = abs(FX_rs)/max(abs(FX_rs));
    FX_rs_N = abs(FX_rs);

    % [x0, fs0] = audioread('te.wav');% consider a function to auto, 需改文件
    [x0, fs0] = audioread('testreceived.wav');
    col_1 = x0(:,1);
    mses = zeros(length(col_1)-N+1,1);
    
    for i = 1:length(col_1)-N+1
        W_start = i;
        W_end = W_start+N-1;
        Xre = col_1(W_start:W_end);
        FX = fft(Xre);
        % FX_N = abs(FX)/max(abs(FX));
        FX_N = abs(FX);
        for k = 1:N
            err_squared = (FX_N(k)-FX_rs_N(k))^2;
            mses(i) = mses(i) + err_squared;
        end
        mses(i) = sqrt(mses(i)/N);
    end
    
    [min_mse, i] = min(mses);
    fprintf('Minimum MSE at location: %f, %d\n', min_mse,i);
    
    % we know the best portion, 最佳部分
    W_start = i;
    W_end = W_start+N-1;
    Xre_portion = col_1(W_start:W_end);
    
    % 2. 分帧处理 Framing， 
    frame_size = 1024; % 帧长
    num_frames = length(rs)-frame_size+1;
    
    % 3. FFT,取第一个点，zero frequency？
    x_ff = zeros(num_frames,1); % 原始信号零频序列 original _ff = fft + first point
    y_ff = zeros(num_frames,1); % 接收信号零频序列 receive
    %why is y_ff using num_frames?

    for n = 1:num_frames
        % get part to do fft. 一段一段做fft， 原始
        %orig_frame = rs((n-1)*frame_size+1 : n*frame_size);
        orig_frame = rs(n: n+frame_size-1);
        orig_fft = fftshift(abs(fft(orig_frame)));%%  45 46 绝对值
        x_ff(n) = orig_fft(abs(frame_size/2+1)); % move N/2, right? 平移后的零频点
        
        % same but receive 
        %rec_frame = Xre_portion((n-1)*frame_size+1 : n*frame_size);
        rec_frame = Xre_portion(n: n+frame_size-1);
        rec_fft = fftshift(abs(fft(rec_frame)));
        y_ff(n) = rec_fft(abs(frame_size/2+1));
    end
    
    % 4. 找系数 (LMS Adaptive Filter) finding coefficients

u = 0.0001;       % learning rate  
epoch = 100;    
order = 10;     % tap FIR滤波器阶数 higher is better!!!
h = zeros(order,1);  % initial
delta = 1e-3;

mse_history = zeros(epoch,1);
y_pred = zeros(length(x_ff), 1);

% normalization avoid NaN
x_ff = (x_ff - mean(x_ff)) / std(y_ff);
y_ff = (y_ff - mean(y_ff)) / std(y_ff);

for i = 1:epoch
    for k = order:length(x_ff)
        x_vec = x_ff(k:-1:k-order+1);  % vector length
        y_pred(k) = h.' * x_vec;
        error = y_ff(k) - y_pred(k);

        h = h + u * error * x_vec/((x_vec'*x_vec)+delta);
    end

    mse_history(i) = mean((y_ff(order:end) - y_pred(order:end)).^2);

    if mod(i,10)==0
        fprintf('Iter %d: MSE=%.6f\n', i, mse_history(i));
    end
end

fprintf('\n Optimal coefficients (order=%d):\n', order);
for j = 1:order
    fprintf('h%d = %.4f\n', j-1, real(h(j)));
end

    % then draft a graph?
figure;
subplot(3,1,1);
plot(abs(y_ff), 'g');
ylabel('Magnitude');
xlabel('Frequency')
legend('Received');
subplot(3,1,2);
plot(abs(y_pred), 'b');
ylabel('Magnitude'); %what's the name??????/
xlabel('Frequency')
legend('Predict');
subplot(3,1,3);
plot(abs(y_ff), 'g');
hold on;
plot(abs(y_pred), 'b');
hold off;
ylabel('Magnitude');
xlabel('Frequency');
legend('Received', 'Predicted');

figure
subplot(3,1,1);
plot(mse_history);
title('MSE');
xlabel('Epoch');
subplot(3,1,2);
plot(real(h), '-o');  % Plot the final filter coefficients
title('Final Coefficients h');
xlabel('Index'); ylabel('Value'); grid on;
subplot(3,1,3);
plot(abs(x_ff), 'r');
hold on;
plot(abs(y_ff), 'g');
hold off;
ylabel('Magnitude');
xlabel('Frequency');
legend('Original', 'Received');