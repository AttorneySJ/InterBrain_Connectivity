function [conv_data] = wavelet_sj(data,freqoi,ncycle,fs)
switch nargin
    case 2
        ncycle = linspace(3,6,length(freqoi));
        fs = 1200;
    case 3
        fs = 1200;
end
[pnts,nchan]=size(data);

freqboi = round(freqoi ./ (fs ./ pnts)) + 1;
freqboi   = unique(freqboi);
freqoi    = (freqboi-1) ./ (pnts./fs);
nfreq = length(freqoi);
conv_data = NaN(nfreq,pnts,nchan);
%% Wavelet

tt = (-3:1/fs:3)';
nwave = length(tt);
hL = (nwave-1)/2;
nfft = nwave + size(data,1) - 1;
fft_data = fft(data,nfft); % pnt x channel  

if isnumeric(ncycle)
    ncycle = repelem(ncycle,nfreq);
end

for fi = 1:nfreq
fc = freqoi(fi);
st = ncycle(fi)/(2*pi*fc);
A = 1/sqrt(st*sqrt(pi));
tap = A*exp(-tt.^2./(2*(st^2)));

wavelet = exp(2*1i*pi*fc .*tt) .* tap;
fft_wave = fft(wavelet, nfft);
%% convolution     
conv_res = ifft(fft_wave .* fft_data,nfft)*sqrt(2./fs);
conv_data(fi,:,:) = conv_res(hL+1 : end-hL,:);
end
conv_data = squeeze(conv_data);
end