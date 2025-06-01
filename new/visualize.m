    [x, fs] = audioread('testoriginal.wav');
    %rs = resample(x, 441, 1972);
    rs = resample(x, 44100, fs);
    [x0, fs0] = audioread('testreceived.wav');
    col_1 = x0(:,1);

    fft_rs = fft(rs);
    fft_rs_normalized = (rs-mean(rs))/std(rs);
    fft_col_1 = fft(col_1);
    fft_col_1_normalized = (col_1-mean(col_1))/std(col_1);

    figure
    % plot(x)
    plot(rs)
    
    figure
    plot(col_1)
   
    figure
    % plot(x)
    plot(abs(fft_rs_normalized))
    
    figure
    plot(abs(fft_col_1_normalized))