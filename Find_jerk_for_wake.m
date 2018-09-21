% Q3: Do LRRKS move more when the are awake?

%look at jerk values for just awake periods
function [Wake]=Find_jerk_for_wake

Wake.aborted=0;

direct=strsplit(pwd,'\');
mouseday=direct{end};
load('Session_Info.mat');

ff=find_files('*jerk*');
Jerk=load(ff{1});

jerk=[Jerk.jerk(:,1),Jerk.jerk(:,5)];
clear Jerk

% figure
% plot(jerk(:,1),jerk(:,2))

if jerk(:,2)>200
    Wake.aborted=1;
    disp('high jerk vals')
    figure;
    plot(jerk(:,2),jerk(:,2))
    title('Jerk over threshold')
    return
end

fff=find_files('*Sleep_Times_Pre*');
PRE=load(fff{1});

ffff=find_files('*Sleep_Times_Post*');
POST=load(ffff{1});

f=find_files('*EPOCHS*');
load(f{1})

[Adjusted_Pre, Adjusted_Post, adjusted_bounds]=Adjust_to_Middle_Sleep...
    (EPOCHS,PRE.Actual_Sleep_Times_Pre, POST.Actual_Sleep_Times_Post,100);

% SLEEP(:,1)=jerk(:,1)>adjusted_bounds.lower_bound_pre & jerk(:,1)<adjusted_bounds.upper_bound_pre;

SLEEP(:,2)=zeros(length(jerk),1);
for isleep=1:length(PRE.Actual_Sleep_Times_Pre)
    if isnan(Adjusted_Pre(:,1))
        return
    end
   sleepix= SLEEP(:,1)>Adjusted_Pre(isleep,1) & SLEEP(:,1)< Adjusted_Pre(isleep,2);
    SLEEP(sleepix,2)=1;
end
SLEEPIX=logical(SLEEP(:,2));

Area4sleepIX=jerk(:,1)>adjusted_bounds.lower_bound_pre & jerk(:,1)<adjusted_bounds.upper_bound_pre;
WAKEIX=~SLEEPIX & Area4sleepIX; 

averagejerkPRE=mean(jerk(WAKEIX,2));

%% POST
SLEEP(:,2)=zeros(length(jerk),1);
for isleep=1:length(POST.Actual_Sleep_Times_Post)
   sleepix= SLEEP(:,1)>Adjusted_Post(isleep,1) & SLEEP(:,1)< Adjusted_Post(isleep,2);
    SLEEP(sleepix,2)=1;
end
SLEEPIX=logical(SLEEP(:,2));

Area4sleepIX2=jerk(:,1)>adjusted_bounds.lower_bound_post & jerk(:,1)<adjusted_bounds.upper_bound_post;
WAKEIX=~SLEEPIX & Area4sleepIX2; 

averagejerkPOST=mean(jerk(WAKEIX,2));


%%
Wake.averagejerkPost=averagejerkPOST;
Wake.averagejerkPre=averagejerkPRE;
Wake.DayType=Session_Info.RecordingType{1};
Wake.Mouse=mouseday(1:3);
Wake.Day=Session_Info.Recordingday;
ixx=Session_Info.drugs.Mouse==mouseday(1:3);
 Wake.drugmouse=Session_Info.drugs.GotDrug(ixx);
Wake.MouseType=mouseday(1);
%%
% figure
% plot((jerk(:,1)/60)/60,jerk(:,2))
% hold on
% plot(jerk(WAKEIX,1)/60/60,jerk(WAKEIX,2),'r')
% xlabel('Time(hours)')
% ylabel('Summed Jerk')
% axis tight
% title('Middle 100 Minutes: Wake')
% pubify_figure_axis
