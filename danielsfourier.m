function [amplitudes frequencies] = danielsfourier(timeseries, samplingRate)

L = length(timeseries);
NFFT = L;

amplitudes = 2*abs(fft(timeseries)/L);
amplitudes = amplitudes(1:NFFT/2+1);

if exist('samplingRate')
    frequencies = samplingRate/2*linspace(0,1,NFFT/2+1);
    figure; plot(frequencies, amplitudes);
end
