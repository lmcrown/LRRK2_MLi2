function [amp_filt_sig, filt_sig] = filter_wiegand(x, lowlimit_fq, highlimit_fq, sr);

%x is vector
%sr is sampling rate
%smooth_window is in ms

d = designfilt('bandpassiir','FilterOrder',10, ...
    'HalfPowerFrequency1',lowlimit_fq,'HalfPowerFrequency2',highlimit_fq, ...
    'SampleRate',sr);
% 
% F_Ny = sr/2;    % Hz. Use the output because data sampled at the output
% N = 4;                 % Order of the filter
% passband = [lowlimit_fq/F_Ny highlimit_fq/F_Ny];
% booger = .1;
% [B,A] = cheby1(N, booger, passband);

%     N = 4; booger = .01; %%(4,.01) - this is really good but seems to pick up less (in length)
     
% filt_sig = filtfilt(B,A,double(x)); %filtered to spindle band
filt_sig = filtfilt(d,double(x)); %filtered to spindle band
amp_filt_sig = envelope(sqrt(filt_sig.^2)); %instantaneous amplitude; % He does a hilbert transform here for instantaneous amplitude