
load('L13Day1-Sleep_Times_Post.mat')

SpinTimes=Actual_Sleep_Times_Post(3,:); % need to make this an actual spindel time

%243:244
figure
plot(LFP.LFP_uV(:,1),LFP.LFP_uV(:,2))

LFP=load('L13-ECoG_Left_Ant-23-Day1.mat');
IX=LFP.LFP_uV(:,1)>SpinTimes(:,1) & LFP.LFP_uV(:,1)<SpinTimes(:,2);
Spectrogram_spindle_LC(LFP.LFP_uV(IX,2), 1000, 2:0.2:30, 'wavelet');

figure(1);
plot(LFP.LFP_uV(IX,1),LFP.LFP_uV(IX,2))

%% Filter for sigma
lowlimit_fq  = 8; 
highlimit_fq = 18;

d = designfilt('bandpassiir','FilterOrder',10, ...
    'HalfPowerFrequency1',lowlimit_fq,'HalfPowerFrequency2',highlimit_fq, ...
    'SampleRate',LFP.fs_final);

filt_sig = filtfilt(d,double(LFP.LFP_uV(IX,2))); %filtered to spindle band
as=abs(hilbert(filt_sig)); 
% power=envelope_cowen(as.^2);
envpower=convn(as.^2,hanning(round(fs_final*.1)),'same');
smoothed_power=envelope_cowen(envpower);

figure(1)
hold on;
plot(LFP.LFP_uV(IX,1),smoothed_power)

%%
figure
title(sprintf('Raw Signal for Sleep and Power for %s', mouseday))

yyaxis left
plot(LFP.LFP_uV(IX,1),LFP.LFP_uV(IX,2),'k','LineWidth',1)
hold on
% plot(Secs(bigpowIX && SleepIX),L16_Left_Ant(SleepIX && bigpowIX),'r')
hold on;
plot(LFP.LFP_uV(IX,1),filt_sig)

yyaxis right
hold on
plot(LFP.LFP_uV(IX,1),smoothed_power)
 % now 1= 1 second and this should be easy to estimate Hz from
% refline(0,mean_power)
% refline(0,mean_power+2*powstd)
ylabel('uV')
xlabel('Time(s)')
%%
[x,y]=ginput(2);
%%
SpinTimes=[x(1)-1,x(2)+1];
IXS=LFP.LFP_uV(:,1)>SpinTimes(:,1) & LFP.LFP_uV(:,1)<SpinTimes(:,2);

Spectrogram_spindle_LC(LFP.LFP_uV(IXS,2), 1000, 3:0.2:20, 'wavelet');
%%
figure
title(sprintf('Raw Signal for Sleep and Power for %s', mouseday))

yyaxis left
plot(LFP.LFP_uV(IXS,1),LFP.LFP_uV(IXS,2),'k','LineWidth',1)
hold on
% plot(Secs(bigpowIX && SleepIX),L16_Left_Ant(SleepIX && bigpowIX),'r')
hold on;
plot(LFP.LFP_uV(IXS,1),filt_sig)

yyaxis right
hold on
plot(LFP.LFP_uV(IXS,1),smoothed_power)
 % now 1= 1 second and this should be easy to estimate Hz from
% refline(0,mean_power)
% refline(0,mean_power+2*powstd)
ylabel('uV')
xlabel('Time(s)')
