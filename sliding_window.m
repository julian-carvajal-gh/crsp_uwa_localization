function best_slice = sliding_window(originalWav, receivedWav)
[x, fs] = audioread(originalWav);
% [p, q] = rat(44100 / 170000); % Find integer approximation of the fraction
% rs = resample(x, p, q); % Resample using integer factors
% disp(fs);
rs = resample(x, 44100, fs);
% Calculate the FFT
N = min(length(rs), length());  % Length of the signal
FX_rs=fft(rs);
FX_rs_N=FX_rs/max(abs(FX_rs));
FX_rs_N=abs(FX_rs_N);
 
[x0,fs0]=audioread(receivedWav);
col_1=x0(:,1);% Extract the first column
mses=zeros(length(col_1)-N+1,1);
for i=1:length(col_1)-N+1
    W_start=i;
    W_end=W_start+N-1;
    Xre=col_1(W_start:W_end);%length=N
    FX=fft(Xre);
    FX_N=FX/max(abs(FX));
    FX_N=abs(FX_N);
    for k=1:N
        err_squared=(FX_N(k)-FX_rs_N(k));
        err_squared=err_squared*err_squared;
        mses(i) = mses(i)+err_squared;
    end
    mses(i)=sqrt(mses(i)/N);
end
 
[min_mse,i] = min(mses);
% Display the minimum MSE value
% fprintf('Minimum MSE at location: %f, %d\n', min_mse,i);
 
%extract portion
W_start=i;
W_end=W_start+N-1;
Xre_portion=col_1(W_start:W_end);%length=N
FX_portion=fft(Xre_portion);
FX_N_portion=FX_portion/max(abs(FX_portion));
FX_N_portion=abs(FX_N_portion);

best_slice = Xre_portion;

end
 
%frequency Domain
% psdData = 20*log10(abs(circshift(FX_N_portion,floor(N/2))));
% freqResolution = fs0/N;
% freqAxis = (freqResolution:freqResolution:fs0)-fs0/2;
% 
% figure;
% plot(freqAxis, psdData);
% xlabel('Frequency (Hz)');
% ylabel('Power spectral density (dB)');
% title('Frequency Domain Data');
% subtitle('F=96k R=1m D=0.762m');

% psdData = 20*log10(abs(circshift(FX_rs_N,floor(N/2))));
 
 
% figure;
% plot(freqAxis, psdData);
% xlabel('Frequency(Hz)');
% ylabel('Power spectral density (dB)');
% title('Frequency Domain Data');
% subtitle ('F=96k, R=1m, D=0m');

%figure;
%subplot(2,1,1);
%plot([1:length(x1)],x1);
%subplot(2,1,2);
%plot([1:i],x2(1:i),'b-');
%plot([i+1,i+N],x2(i+1,i+N),'r-');