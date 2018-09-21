function [smooth_sig, amp_filt_sig, filt_sig] = spindle_filter_wiegand_CSI(x, sr);

%x is vector
%sr is sampling rate
%smooth_window is in seconds

% cubic spline interpolation

%% Phillips, Keith G., et al. 
%% "Decoupling of sleep-dependent cortical and hippocampal interactions in a neurodevelopmental model of schizophrenia." 
%% Neuron 76.3 (2012): 526-533.
lowlimit_fq  = 8; 
highlimit_fq = 18;

d = designfilt('bandpassiir','FilterOrder',4, ...
    'HalfPowerFrequency1',lowlimit_fq,'HalfPowerFrequency2',highlimit_fq, ...
    'SampleRate',sr);

filt_sig = filtfilt(d,double(x)); %filtered to spindle band
amp_filt_sig = envelope(sqrt(filt_sig.^2)); %instantaneous amplitude; % He does a hilbert transform here for instantaneous amplitude

[x, xx] =  findpeaks(amp_filt_sig);
y = sin(x);
zz = 1:length(amp_filt_sig);
smooth_sig = spline(x,y,zz);
