function [filt_smooth_EMG, filt_sig] = emg_filter_wsmoothing(x, sr)

%x is vector
%sr is sampling rate
%smooth_window is in s

lowlimit_fq  = 70;
highlimit_fq = 249;

d = designfilt('bandpassiir','FilterOrder',4, ...
    'HalfPowerFrequency1',lowlimit_fq,'HalfPowerFrequency2',highlimit_fq, ...
    'SampleRate',sr);

filt_sig = filtfilt(d,double(x)); 

 amp_filt_sig = envelope(sqrt(filt_sig.^2));

 filt_smooth_EMG=smoothdata(amp_filt_sig,'gaussian',100); 
 %see envelope_cowen