%Goal: Take sleep times that are saved in the mouse's post-processed folder
%and use these to analyze just sleep periods

%then identify periods of high sigma power, and do a zoom in and visual
%inspection of the signal to look for spindles

%once potential spindles are found, grab data such as frequency, power in
%sigma band, duration and store this info to assist with automatic
%detection later on

% file=pwd;
file=uigetdir;
mouseday=file(end-6:end);
%being initially tried on post sleep
load([mouseday '-Sleep_Times_Post.mat']); %variable called actual sleep times post

ecog=uigetfile('','Pick ECoG Channel');
ref=uigetfile('','Pick Rereference Channel');

LFP=load(ecog);
ReRef=load(ref);

figure(999)
subplot(2,1,1)
plot(LFP.LFP_uV(:,1),LFP.LFP_uV(:,2))
subplot(2,1,2)
plot(ReRef.LFP_uV(:,1),ReRef.LFP_uV(:,2))

ReRefLFP(:,1)=LFP.LFP_uV(:,1);
ReRefLFP(:,2)=LFP.LFP_uV(:,2)-ReRef.LFP_uV(:,2);

%%COMMENT OR UNCOMMENT TO CHOOSE WHICH YOU USE
ECOG=ReRefLFP;
% ECOG=LFP;
%% 

%to get rid of annoying issues- just gonna filter whole damn thing- now
%they are the same length
   
    lowlimit_fq  = 7;
    highlimit_fq = 15;
    
    d = designfilt('bandpassiir','FilterOrder',10, ...
        'HalfPowerFrequency1',lowlimit_fq,'HalfPowerFrequency2',highlimit_fq, ...
        'SampleRate',LFP.fs_final);
    
    filt_sig = filtfilt(d,double(ECOG(:,2))); %filtered to spindle band
    as=abs(hilbert(filt_sig));
    % power=envelope_cowen(as.^2);
    envpower=convn(as.^2,hanning(round(LFP.fs_final*.1)),'same');
    smoothed_power=envelope_cowen(envpower);
    
    maxpow = prctile(smoothed_power,97.5);
    minpow = prctile(smoothed_power,2.5);
    
    trimmedpowerIX=smoothed_power>minpow & smoothed_power<maxpow;
    
    powstd=std(smoothed_power(trimmedpowerIX));
    mean_power=(mean(smoothed_power(trimmedpowerIX)));
    smoothed_power(smoothed_power>maxpow)=maxpow;

% LFP=load('L13-ECoG_Left_Ant-23-Day1.mat');
%first try by plotting it along with sigma power

for irow=1:Rows(Actual_Sleep_Times_Post)
    Sleep_PeriodIX= ECOG(:,1)>Actual_Sleep_Times_Post(irow,1) & ECOG(:,1)< Actual_Sleep_Times_Post(irow,2);
%     SleepLFP = ECOG(Sleep_PeriodIX,:);
% 
%    
%     lowlimit_fq  = 7;
%     highlimit_fq = 15;
%     
%     d = designfilt('bandpassiir','FilterOrder',10, ...
%         'HalfPowerFrequency1',lowlimit_fq,'HalfPowerFrequency2',highlimit_fq, ...
%         'SampleRate',LFP.fs_final);
%     
%     filt_sig = filtfilt(d,double(ECOG(Sleep_PeriodIX,2))); %filtered to spindle band
%     as=abs(hilbert(filt_sig));
%     % power=envelope_cowen(as.^2);
%     envpower=convn(as.^2,hanning(round(LFP.fs_final*.1)),'same');
%     smoothed_power=envelope_cowen(envpower);
%     
%     maxpow = prctile(smoothed_power,97.5);
%     minpow = prctile(smoothed_power,2.5);
%     
%     trimmedpowerIX=smoothed_power>minpow & smoothed_power<maxpow;
%     
%     powstd=std(smoothed_power(trimmedpowerIX));
%     mean_power=(mean(smoothed_power(trimmedpowerIX)));
%     smoothed_power(smoothed_power>maxpow)=maxpow;
  
    
    %%
    figure(irow)
    title(sprintf('Raw Signal for Sleep and Power for %s', mouseday))
    minnum=min(ECOG(Sleep_PeriodIX,1));
%     Secs=ECOG(Sleep_PeriodIX,1)-minnum;
    Secs=ECOG(Sleep_PeriodIX,1);

    yyaxis left
%     plot(Secs,ECOG(Sleep_PeriodIX,2),'k')
%         plot(SleepLFP(:,1),SleepLFP(:,2),'k')

    plot(ECOG(Sleep_PeriodIX,1),ECOG(Sleep_PeriodIX,2),'k')
%         plot(SleepLFP(:,1),SleepLFP(:,2),'k')


    hold on
%     plot(Secs,filt_sig,'b')
    plot(ECOG(Sleep_PeriodIX,1),filt_sig(Sleep_PeriodIX),'b')

    
    yyaxis right
%     plot(Secs,smoothed_power,'r')  % now 1= 1 second and this should be easy to estimate Hz from
    
    plot(ECOG(Sleep_PeriodIX,1),smoothed_power(Sleep_PeriodIX),'r')  % now 1= 1 second and this should be easy to estimate Hz from

    refline(0,mean_power+2*powstd)
    ylabel('uV')
    xlabel('Time(s)')
    
    pause
    answer2=inputdlg('Spindles? 0 or 1');
    if answer2{1}=='1'
        figure(irow)
        [x,y]=ginput(2);
        
%         IX=Secs>x(1) & Secs< x(2);
                IX=ECOG(:,1)>x(1) & ECOG(:,1)< x(2);

        
        GrabTimes=[x(1)-1,x(2)+1];
%         IXGRAB=Secs>GrabTimes(:,1) & Secs<GrabTimes(:,2);
IXGRAB=ECOG(:,1)>GrabTimes(:,1) & ECOG(:,1)<GrabTimes(:,2);        

        figure(irow*50)
        subplot(2,1,1)
        yyaxis left
%         plot(Secs(IXGRAB),ECOG(IXGRAB,2),'k')
                plot(ECOG(IXGRAB,1),ECOG(IXGRAB,2),'k')

        hold on
%         plot(Secs(IXGRAB),filt_sig(IXGRAB),'b')
                plot(ECOG(IXGRAB,1),filt_sig(IXGRAB),'b')

        yyaxis right
%         plot(Secs(IXGRAB),smoothed_power(IXGRAB),'r')  % now 1= 1 second and this should be easy to estimate Hz from
               plot(ECOG(IXGRAB,1),smoothed_power(IXGRAB),'r')  % now 1= 1 second and this should be easy to estimate Hz from

%         refline(0,mean_power)
%         refline(0,mean_power+2*powstd)
                refline(0,mean_power+2.5*powstd)

        ylabel('uV')
        xlabel('Time(s)')
        
         figure(irow*50)
        subplot(2,1,2)
        Spectrogram_spindle_LC(ECOG(IXGRAB,2), LFP.fs_final, 3:0.2:20, 'wavelet');
         [x2,y2]=ginput(1);
        title(sprintf('Pow 4.2%f 2.2%s Secs PkFreq 2.1%f',smoothed_power(IXGRAB),x(2)-x(1),y2))
        
        pause
        isgood=inputdlg('save spindle? 0/1');
        
        if isgood{1}==1
%             figure(irow*50) 
            SpinData{irow}=SleepLFP(IX,:);
            spinsigpower(irow)=mean(smoothed_power(IX));
            spinsigstd(irow)=std(smoothed_power(IX));
            spinLength_secs(irow)=x(2)-x(1);
            peakfrex=y2;
        end 
        if isgood{1}==0
            continue
        end
        %     savefig(sprintf('Spindle for sleep interval %s for %s Post Sleep',irow,mouseday))
    end
    if answer2{1} =='0'
        continue
    end
    
end

SpindleFeatures.Length=spinLength_secs;
SpindleFeatures.meansigpower=spinsigpower;
SpindleFeatures.sigstd=spinsigstd;
SpindleFeatures.times=SpinTimes;
SpindleFeatures.peakfrex=peakfrex;

cd([file '\figs\spindles'])
save('SpindleFeatures','SpindleFeatures')