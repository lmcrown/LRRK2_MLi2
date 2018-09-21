% Example searching for spindles: 
%L13Day1
%the last 15 or so minutes (maybe 16 and then not the last min are probably
%sleep and would be good to use for spindle searching
uigetdir
% cd('E:\Lindsey\LRRK2_MLi2\L13_L14_W36_W35\L13_L14_W36_W35_Day1_5_29_18\L13_L14_W36_W35_Day1_5_29_18_180529_102838\L13Day1');
%Time for Sleep in LFP_time
% uigetfile %just pick a file so you can compare left and right
load('L13-ECoG_Left_Ant-23-Day1.mat')
LFP_sr=300;
sample_LFP=LFP_uV((end-(16*60*LFP_sr)):(end-LFP_sr*60),:); %damn I dont have this as a structure with the SR in it- its only in there for the EMG data- must fix
%thats for L13
%W35:
% sample_LFP=LFP_uV((270*60*LFP_sr):(290*LFP_sr*60),:); 

%next cohort: W36
sample_LFP=LFP_uV((1.15*10e4):(1.4*10e4),:);


secs=1:length(sample_LFP);
figure
plot(secs/LFP_sr,sample_LFP(:,2))  % now 1= 1 second and this should be easy to estimate Hz from
xlabel('Time(s)')
ylabel('uV')

%% JP's spindle filter
lowlimit_fq  = 8; 
highlimit_fq = 18;

d = designfilt('bandpassiir','FilterOrder',10, ...
    'HalfPowerFrequency1',lowlimit_fq,'HalfPowerFrequency2',highlimit_fq, ...
    'SampleRate',LFP_sr);

filt_sig = filtfilt(d,double(sample_LFP(:,2))); %filtered to spindle band
as=abs(hilbert(filt_sig)); 
power=as.^2;

%smooth with gaussian
%one paper smooths over 40ms gaussian window- given an SR of 300, this
%would be 7.5- I'm gonna go with 10?- I really just want to ID higher power
%peaks
smoothed_power=smoothdata(power,'gaussian',10);
%trimmed mean for average power
trimmean_power=trimmean(smoothed_power,5);

% hold on;
% plot(secs,power)
% refline(0,trimmean_power)


nintyfive = prctile(smoothed_power,97.5);
five = prctile(smoothed_power,2.5);

trimmedpower=sample_LFP(smoothed_power>five & smoothed_power<nintyfive);
trim_std=std(trimmedpower);

refline(0,trimmean_power+2*trim_std)

%Q = trapz(Y) approx trapizoidal area under the curve % could use for
%spindle power/ overall power AUC
%% PLOT it all
%shrink the power by some factor
%coult plot yy

% figure;
% plot(secs/LFP_sr,sample_LFP(:,2))  % now 1= 1 second and this should be easy to estimate Hz from
% hold on
% plot(secs/LFP_sr,power)  % now 1= 1 second and this should be easy to estimate Hz from
% refline(0,trimmean_power)
% refline(0,trimmean_power+3*trim_std)
% ylabel('uV')
% xlabel('Time(s)')

bigpowIX=smoothed_power>trimmean_power+3*trim_std;
tim=secs/LFP_sr;

figure
yyaxis left
plot(tim,sample_LFP(:,2),'k','LineWidth',2)
hold on
plot(tim(bigpowIX),sample_LFP(bigpowIX,2),'r')
hold on
plot(tim,filt_sig,'b')

yyaxis right
hold on
plot(secs/LFP_sr,power)  % now 1= 1 second and this should be easy to estimate Hz from
refline(0,trimmean_power)
refline(0,trimmean_power+3*trim_std)
ylabel('uV')
xlabel('Time(s)')
