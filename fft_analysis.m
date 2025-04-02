%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function displays time domain and frequency domain audio data
% e.g. fft_analysis('test.wav');
% wavName: input audio file name
% 
% Copyright @ CUNY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fft_analysis(wavName)
[y, Fs] = audioread (wavName);

totalSample = length(y);
totalTime = totalSample/Fs;
sampleDuration = 1/Fs;
timeAxis = sampleDuration:sampleDuration:totalTime;
freqResolution = Fs/totalSample;
freqAxis = (freqResolution:freqResolution:Fs)-Fs/2; 

figure;
plot(timeAxis,y(:,1)); %select one channel
xlabel('Time (s)');
ylabel('Sound level');
title('Time domain data');
subtitle('R=10m D=0.5m');

fftData = fft(y(:,1));
psdData = 20*log10(abs(circshift(fftData,floor(totalSample/2))));

figure;
plot(freqAxis, psdData);
xlabel('Frequency (Hz)');
ylabel('Power spectral density (dB)');
title('Frequency domain data');
subtitle('R=10m D=0.5m ');
end