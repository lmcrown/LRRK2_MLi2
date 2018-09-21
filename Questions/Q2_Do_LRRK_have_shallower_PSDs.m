function [OUT]=Q2_Do_LRRK_have_shallower_PSDs(eeg_chan)
% Same process as with spindles- get the file you want to look at and
% ReReference if need be
%just doing on presleep
%output b will have first the b0 (intercept) and then b1 (slope)
frex=10:200;
OUT.aborted=false;
if nargin<1
    f=find_files('*ECoG_Left_Mid*');
    if isempty(f)
        disp('No ECoG channel for requested location')
        OUT.aborted=true;
        return
    end
    eeg_chan=f{1};
end

% eeg_chan=uigetfile;

direct=strsplit(pwd,'\');
mouseday=direct{end};
load('Session_Info.mat');

%mainsignal could be a function input
main_signal=eeg_chan;
LFP=load(main_signal);

% ff=find_files('*Reref.mat');
% if isempty(ff)
%     [ReRef]=LRRK2MLi2_Rereference;
% else
%     load(ff{1})
% end

%below is assuming that you've run the rereference on everything and if you
%have stuff thats not in there its because you didn't want to use that day
ff=find_files('*Reref.mat');
if isempty(ff)
    disp([mouseday 'excluded due to lack of reference file'])
    OUT.aborted=true;
    return
else
    load(ff{1})
end


%what side you will use as reref depends on what side you have
bits=strsplit(main_signal,'-');
location=bits{2};
if contains(location,'Left')==1
    Ref=ReRef.Allright;
end
if contains(location,'Right')==1
    Ref=ReRef.Allleft;
end

ECOG(:,1)=LFP.LFP_uV(:,1);
ECOG(:,2)=LFP.LFP_uV(:,2)-Ref(:,2);

assert(isequal(LFP.LFP_uV(:,1),Ref(:,1)),'Time Stamps not equal')
%%
SleepPeriods.Pre=load([mouseday '-Sleep_Times_Pre.mat']);
% SleepPeriods.Post=load([mouseday '-Sleep_Times_Post.mat']);
psd=[];
for isleep=1:Rows(SleepPeriods.Pre.Actual_Sleep_Times_Pre)
    SleepIntervalIX= ECOG(:,1)> SleepPeriods.Pre.Actual_Sleep_Times_Pre(isleep,1) & ECOG(:,1)< SleepPeriods.Pre.Actual_Sleep_Times_Pre(isleep,2);
    [pxx,f]=pwelch(ECOG(SleepIntervalIX,2),2*LFP.fs_final,LFP.fs_final,frex,LFP.fs_final);
    psd(:,:,isleep)=[f', pxx'];
    %sleep number is first dim, then frex then pxx
%     figure;plot(log(f),log(pxx));
end
if isempty(psd)
    disp('No PSDs- probably no sleep periods to speak of')
    return
end
%%
avpsd=mean(psd,3);
figure;
plot(avpsd(:,1),avpsd(:,2));
title('average PSD for all Pre Sleep Periods')

xvals=[(ones(length(avpsd(:,1)),1)), log(avpsd(:,1))];
b=regress(log(avpsd(:,2)),xvals);
figure;
plot(log(avpsd(:,1)),log(avpsd(:,2)),'k')
hold on
refline(b(2),b(1))
title(sprintf('Log-Log of average PSD with Linear Fit Line %2.2f',b(2)))
%%
[Mouse_info]=Get_Mouse_Session_Info;

OUT.slope=b(2);
OUT.intercept=b(1);
OUT.avpsd=avpsd(:,2);
OUT.frex=avpsd(:,1);
OUT.psd=psd;
OUT.Mouse_info=Mouse_info;  
%%
% pburg