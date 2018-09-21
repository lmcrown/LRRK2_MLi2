clear all

root_folder='E:\Lindsey\LRRK2_MLi2\L13_L14_W36_W35\L13_L14_W36_W35_Day3_5_31_18\L13_L14_W36_W35_Day3_5_31_18_180531_101443'
file= 'amp-B-005.dat'
mouseday= 'L14Day3'

rawdat=[root_folder '\' file];`
SpeedFile=[root_folder '\' mouseday '\SPEED_' mouseday];

load(SpeedFile)
plot(Speed_specific(:,1),Speed_specific(:,2))
xlabel('Time (s)')
ylabel('cm/s)')
title(sprintf('Speed for %s', mouseday))

[x,y]=ginput(2);
cd(root_folder)
IF=INTAN_Read_RHD_file('info.rhd');
%Looking at this, I'm going to say that I think he was probably sleeping
%between about 1.4 to 1.65 *10^4 secs

%grab that in the raw data
%looking at CTT: L16 ant Left is Port A chan 23
fs_initial=IF.frequency_parameters.amplifier_sample_rate;
fs_final=1000;
decimation_factor_LFP=ceil(fs_initial/fs_final);

ChosenLFP=INTAN_Read_DAT_file(rawdat);
%turn this into uV
ChosenLFP=ChosenLFP *IF.bit_to_uvolt_conversion;
ChosenLFP=decimate(ChosenLFP,decimation_factor_LFP);

Total_secs=length(ChosenLFP)/fs_final;
Secs=0:1/fs_final:(Total_secs-1/fs_final);

assert(isequal(length(Secs),length(ChosenLFP)),'Time and LFP not equal')

SleepIX=Secs>x(1) & Secs<x(2);
SleepLFP=ChosenLFP(SleepIX);
SleepSecs=0:1/fs_final:length(SleepLFP)/fs_final;
SleepSecs=SleepSecs(1:end-1);

figure;
plot(SleepSecs,SleepLFP)
xlabel('Seconds')
ylabel('uV')
title(sprintf('Raw LFP for %s', mouseday))
%there looks to still be artifacty crap in here

%% Filter for sigma
lowlimit_fq  = 8; 
highlimit_fq = 18;

d = designfilt('bandpassiir','FilterOrder',10, ...
    'HalfPowerFrequency1',lowlimit_fq,'HalfPowerFrequency2',highlimit_fq, ...
    'SampleRate',fs_final);

filt_sig = filtfilt(d,SleepLFP); %filtered to spindle band
as=abs(hilbert(filt_sig)); 
% power=envelope_cowen(as.^2);
envpower=convn(as.^2,hanning(round(fs_final*.1)),'same');
smoothed_power=envelope_cowen(envpower);


%smooth with gaussian
%one paper smooths over 40ms gaussian window- given an SR of 300, this
%would be 7.5- I'm gonna go with 10?- I really just want to ID higher power
%peaks

% smoothed_power=smoothdata(power,'gaussian',30);
% smoothed_power=convn(power,hanning(round(fs_final*.04)),'same');

maxpow = prctile(smoothed_power,97.5);
minpow = prctile(smoothed_power,2.5);

trimmedpowerIX=smoothed_power>minpow & smoothed_power<maxpow;

powstd=std(smoothed_power(trimmedpowerIX));
mean_power=(mean(smoothed_power(trimmedpowerIX)));

figure;
plot(SleepSecs,smoothed_power)
hold on
plot(SleepSecs,envpower)
title(sprintf('Envelope Sigma Power %s Putative Sleep',mouseday))
xlabel('Seconds')
ylable('Power (uV)')

%%
figure
title(sprintf('Raw Signal for Sleep and Power for %s', mouseday))

yyaxis left
plot(SleepSecs,SleepLFP,'k','LineWidth',1)
hold on
% plot(Secs(bigpowIX && SleepIX),L16_Left_Ant(SleepIX && bigpowIX),'r')
% hold on
plot(SleepSecs,filt_sig,'b')

yyaxis right
hold on
plot(SleepSecs,smoothed_power)  % now 1= 1 second and this should be easy to estimate Hz from
refline(0,mean_power)
refline(0,mean_power+2*powstd)
ylabel('uV')
xlabel('Time(s)')
