function [Actual_Sleep_Times_Pre, Actual_Sleep_Times_Post] = MLi2_Find_Sleep(mousedir, length_for_sleep_sec, min_interinterval_sec,speedthresh,jerkthresh,plotit)

%input will be mouse folder- full file name up to (ex)L13Day1'
%output will be times that are then saved to the mouse folder or could be
%used in bigger function

%Emily Monroe, looked over/adjusted by Lindsey 7/12/2018
%changed jerk thresh to 1 and added ylim to ginput
if nargin<6
    plotit=true;
end
if nargin<5
    jerkthresh=1; %because its been smoothed, JP didnt smooth so he set his at 5
end
if nargin<4
    speedthresh=2; %not sure about this one, will likely change as we get more data
end
if nargin<3
    min_interinterval_sec=0.5;
end
if nargin <2
    length_for_sleep_sec=40;
end
if nargin<1
    mousedir=pwd;
end


%% Go to mousedir, figure out what EMG fs is and load the filtered EMGs
cd(mousedir)
root_folder=pwd;
f=find_files('*EMG_*');
rawEMG=load(f{1});
emgfs=rawEMG.emgfs;
ff=find_files('*SPEED*'); %speed has been smoothed with cowen's speed from xy function
if isempty(ff)
   [Actual_Sleep_Times_Pre, Actual_Sleep_Times_Post] = Find_Sleep_without_POS;
   return
end
Speed=load(ff{1});
fff=find_files('jerk*');
load(fff{1});

assert(exist('filteredEMGs.mat')==2,'need filtered EMGs')
load('filteredEMGs.mat') %should we just be looking at the filtered stuff
%% Pick your EMG and manually set the threshold

minimum_duration_in_samples = length_for_sleep_sec*emgfs;
minimum_inter_interval_period=min_interinterval_sec*emgfs;

% figure
% subplot(2,1,1)
% plot(filteredEMGs(:,1),filteredEMGs(:,2));%leftEMG.EMG_uV
% if Cols(filteredEMGs)>2
% subplot(2,1,2)
% plot(filteredEMGs(:,1),filteredEMGs(:,3)); %rightEMG.EMG_uV
% end
%weird that its negative..
% answer=inputdlg('Which EMG??');
% EMG2use=str2double(cell2mat(answer)) ;
% clf

figure
plot(filteredEMGs(:,1),filteredEMGs(:,2))
ylim([0 500]);
title('Manually pick where you want to set EMG threshold')
[x,y]=ginput(1);
EMG_thresh=y;


clf('reset')

%% load the speed

%Interpolating SPEED to be same times as EMG

InterpSPEED(:,1)=filteredEMGs(:,1); %setting it up to be the same time scale as EMG
try
    InterpSPEED(:,2)= interp1(Speed.Speed_specific(:,1),Speed.Speed_specific(:,2),filteredEMGs(:,1)); %interpolating so that time will match
catch
    if sum(isnan(Speed.Speed_specific))>0
        IX=sum(~isnan(Speed.Speed_specific),2)==2;
        InterpSPEED(:,2)= interp1(Speed.Speed_specific(IX,1),Speed.Speed_specific(IX,2),filteredEMGs(:,1)); %interpolating so that time will match
        disp('there were NaNs in the POS data, interpolated through it but i wouldn''t trust the POS data here')
    end
end
%load EPOCHS
load('EPOCHS.mat')
%Pre/Post Sleep Logical
PreSleep=InterpSPEED(:,1)<=EPOCHS.PREsleep_t_sec;
PostSleep=InterpSPEED(:,1)>=EPOCHS.POSTsleep_t_sec;

%breaking SPEED into Pre and Post SLEEP
PRE_SPEED=InterpSPEED(PreSleep,:);
POST_SPEED= InterpSPEED(PostSleep,:);

if length(jerk)~=length(filteredEMGs)
    disp(length(jerk)-length(filteredEMGs))
    if length(jerk)-length(filteredEMGs)==-1
        disp('all good,appending one record to jerk')
    else
        disp('not one record as predicted...shit might fail?')
    end
end
last_rec(:,1)=jerk(end,1)+1;
last_rec(:,2)=1;
Jerk(:,1)=jerk(:,1);
Jerk(:,2)=jerk(:,5);
Jerk=[Jerk;last_rec];%fix the one record offset?
%fix the one record offset?
smoothjerk(:,1)=Jerk(:,1);
smoothjerk(:,2)=smoothdata(Jerk(:,2),'movmean',50);
%Breaking jerk into Pre and Post
PRE_jerk=smoothjerk(PreSleep,:);
POST_jerk= smoothjerk(PostSleep,:);

PRE_EMG=filteredEMGs(PreSleep,:); %make this a variable that can be the one that you choose it
POST_EMG= filteredEMGs(PostSleep,:);


%% finding intervals
[PRE_SPEED_SLEEPIX, PRE_SPEED_START_END_IX, PRE_SPEED_NEW_START_END_IX] =sleep_intervals_Monroe(PRE_SPEED,speedthresh, minimum_duration_in_samples,minimum_inter_interval_period);
SLEEP_SPEED_PRE=PRE_SPEED_NEW_START_END_IX;
[POST_SPEED_SLEEPIX, POST_SPEED_START_END_IX, POST_SPEED_NEW_START_END_IX] =sleep_intervals_Monroe(POST_SPEED,speedthresh, minimum_duration_in_samples,minimum_inter_interval_period);
SLEEP_SPEED_POST=POST_SPEED_NEW_START_END_IX;
[PRE_JERK_SLEEPIX, PRE_JERK_START_END_IX, PRE_JERK_NEW_START_END_IX] =sleep_intervals_Monroe(PRE_jerk,jerkthresh, minimum_duration_in_samples,minimum_inter_interval_period);
SLEEP_jerk_PRE=PRE_JERK_NEW_START_END_IX;
[POST_JERK_SLEEPIX, POST_JERK_START_END_IX, POST_JERK_NEW_START_END_IX] =sleep_intervals_Monroe(POST_jerk,jerkthresh, minimum_duration_in_samples,minimum_inter_interval_period);
SLEEP_jerk_POST=POST_JERK_NEW_START_END_IX;
[PRE_EMG_SLEEPIX, PRE_EMG_START_END_IX, PRE_EMG_NEW_START_END_IX] =sleep_intervals_Monroe(PRE_EMG,EMG_thresh, minimum_duration_in_samples,minimum_inter_interval_period);
SLEEP_EMG_PRE=PRE_EMG_NEW_START_END_IX;
[POST_EMG_SLEEPIX, POST_EMG_START_END_IX, POST_EMG_NEW_START_END_IX] =sleep_intervals_Monroe(POST_EMG,EMG_thresh, minimum_duration_in_samples,minimum_inter_interval_period);
SLEEP_EMG_POST=POST_EMG_NEW_START_END_IX;
figure;
%Find PRE-SLEEP Intervals, save as SLEEP_SPEED_PRE


subplot(3,2,1)
plot(PRE_SPEED(:,1),PRE_SPEED(:,2)), xlabel('time (s)'),ylabel('Pre Speed (cm/s)')
axis tight
plot_markers_simple(SLEEP_SPEED_PRE(:,1),[],[],'g');
plot_markers_simple(SLEEP_SPEED_PRE(:,2),[],[],'r');
hline = refline([0 speedthresh]);
hline.Color = 'r';
title('PRE SPEED')

subplot(3,2,2)
plot(POST_SPEED(:,1),POST_SPEED(:,2)), xlabel('time (s)'),ylabel('Post Speed (cm/s)')
axis tight
plot_markers_simple(SLEEP_SPEED_POST(:,1),[],[],'g');
plot_markers_simple(SLEEP_SPEED_POST(:,2),[],[],'r');
hline = refline([0 speedthresh]);
hline.Color = 'r';
title('POST SPEED-time since beginning of recording')

subplot(3,2,3)
plot(PRE_jerk(:,1),PRE_jerk(:,2)),xlabel('time (s)'),ylabel('Pre jerk (summed jerk (m/s^3)')  %this plot worked
axis tight
plot_markers_simple(SLEEP_jerk_PRE(:,1),[],[],'g');
plot_markers_simple(SLEEP_jerk_PRE(:,2),[],[],'r');
hline = refline([0 1.75]);
hline.Color = 'r';
title('PRE JERK')

subplot(3,2,4)
plot(POST_jerk(:,1),POST_jerk(:,2)),xlabel('time (s)'),ylabel('Post jerk (m/s^3)')
axis tight
plot_markers_simple(SLEEP_jerk_POST(:,1),[],[],'g');
plot_markers_simple(SLEEP_jerk_POST(:,2),[],[],'r');
hline = refline([0 jerkthresh]); %jerk smoothed so moving this to 1.75
hline.Color = 'r';
title('POST JERK- time since beginning of recording')

subplot(3,2,5)
plot(PRE_EMG(:,1),PRE_EMG(:,2)), xlabel('time (s)'),ylabel('EMG-PRE (uV)')
axis tight
plot_markers_simple(SLEEP_EMG_PRE(:,1),[],[],'g');
plot_markers_simple(SLEEP_EMG_PRE(:,2),[],[],'r');
hline = refline([0 EMG_thresh]);
hline.Color = 'r';
title('PRE EMG')

subplot(3,2,6)
plot(POST_EMG(:,1),POST_EMG(:,2)), xlabel('time (s)'),ylabel('EMG-POST (uV)')
axis tight
plot_markers_simple(SLEEP_EMG_POST(:,1),[],[],'g');
plot_markers_simple(SLEEP_EMG_POST(:,2),[],[],'r');
hline = refline([0 EMG_thresh]);
hline.Color = 'r';
title('POST EMG- time since beginning of recording')


%% finding all corresponding sleep times PRE

%logicals for sleep interval times
SLEEP_ALL_PRE= PRE_SPEED(:,1); %initialize time variable
SLEEP_ALL_PRE(:,2)=zeros(length(SLEEP_ALL_PRE),1);

for iRows=1:Rows(PRE_SPEED_NEW_START_END_IX)
    IX_start=PRE_SPEED_NEW_START_END_IX(iRows,1);
    IX_end=PRE_SPEED_NEW_START_END_IX(iRows,2);
    b=find(SLEEP_ALL_PRE>IX_start & SLEEP_ALL_PRE<IX_end);
    SLEEP_ALL_PRE(b,2)=1;
end


SLEEP_ALL_PRE(:,3)=zeros(length(SLEEP_ALL_PRE),1);
for iRows=1:Rows(PRE_JERK_NEW_START_END_IX)
    IX_start=PRE_JERK_NEW_START_END_IX(iRows,1);
    IX_end=PRE_JERK_NEW_START_END_IX(iRows,2);
    b=find(SLEEP_ALL_PRE>IX_start & SLEEP_ALL_PRE<IX_end);
    SLEEP_ALL_PRE(b,3)=1;
end

SLEEP_ALL_PRE(:,4)=zeros(length(SLEEP_ALL_PRE),1);
for iRows=1:Rows(PRE_EMG_NEW_START_END_IX)
    IX_start=PRE_EMG_NEW_START_END_IX(iRows,1);
    IX_end=PRE_EMG_NEW_START_END_IX(iRows,2);
    b=find(SLEEP_ALL_PRE>IX_start & SLEEP_ALL_PRE<IX_end);
    SLEEP_ALL_PRE(b,4)=1;
end

%adding all columns

SLEEP_ALL_PRE(:,5)=SLEEP_ALL_PRE(:,2)+SLEEP_ALL_PRE(:,3)+SLEEP_ALL_PRE(:,4);

%find when at least 2 (another logical)
SLEEPIX = SLEEP_ALL_PRE(:,5) >= 2;

%find difference for interval index
d = diff([0; SLEEPIX]);

%make sure the last value is -1 to avoid problems
if SLEEPIX(end) == 1
    d(end) = -1;
end
%index
start_ix = find(d ==1);
end_ix   = find(d == -1) - 1;

%make 2 columns for start and end times
START_END_IX = [start_ix(:) end_ix(:)];

%make sure new intervals are at least 40 seconds
durations = START_END_IX(:,2) - START_END_IX(:,1);

BADIX = durations < minimum_duration_in_samples;

START_END_IX(BADIX,:) = [];
SLEEPIX = zeros(size(SLEEPIX));

for iR = 1:Rows(START_END_IX)
    SLEEPIX(START_END_IX(iR,1):START_END_IX(iR,2)) = 1;
end

%returning index to time
Actual_Sleep_Times_Pre=[];
for dx=1:Rows(START_END_IX)
    Actual_Sleep_Times_Pre(dx) = SLEEP_ALL_PRE(START_END_IX(dx));
    Actual_Sleep_Times_Pre= Actual_Sleep_Times_Pre(:);
end
Actual_Sleep_Times_Pre(:,2) = SLEEP_ALL_PRE(START_END_IX(:,2));

%% finding all corresponding sleep times POST
SLEEP_ALL_POST= POST_SPEED(:,1); %initialize time variable
SLEEP_ALL_POST(:,2)=zeros(length(SLEEP_ALL_POST),1);
for iRows=1:Rows(POST_SPEED_NEW_START_END_IX)
    IX_start=POST_SPEED_NEW_START_END_IX(iRows,1);
    IX_end=POST_SPEED_NEW_START_END_IX(iRows,2);
    b=find(SLEEP_ALL_POST>IX_start & SLEEP_ALL_POST<IX_end);
    SLEEP_ALL_POST(b,2)=1;
end


SLEEP_ALL_POST(:,3)=zeros(length(SLEEP_ALL_POST),1);
for iRows=1:Rows(POST_JERK_NEW_START_END_IX)
    IX_start=POST_JERK_NEW_START_END_IX(iRows,1);
    IX_end=POST_JERK_NEW_START_END_IX(iRows,2);
    b=find(SLEEP_ALL_POST>IX_start & SLEEP_ALL_POST<IX_end);
    SLEEP_ALL_POST(b,3)=1;
end

SLEEP_ALL_POST(:,4)=zeros(length(SLEEP_ALL_POST),1);
for iRows=1:Rows(POST_EMG_NEW_START_END_IX)
    IX_start=POST_EMG_NEW_START_END_IX(iRows,1);
    IX_end=POST_EMG_NEW_START_END_IX(iRows,2);
    b=find(SLEEP_ALL_POST>IX_start & SLEEP_ALL_POST<IX_end);
    SLEEP_ALL_POST(b,4)=1;
end

%adding all columns

SLEEP_ALL_POST(:,5)=SLEEP_ALL_POST(:,2)+SLEEP_ALL_POST(:,3)+SLEEP_ALL_POST(:,4);

%find when at least 2 (another logical)
SLEEPIX = SLEEP_ALL_POST(:,5) >= 2;

%find difference for interval index
d = diff([0; SLEEPIX]);


%make sure the last value is -1 to avoid problems
if SLEEPIX(end) == 1
    d(end) = -1;
end
%index
start_ix = find(d ==1);
end_ix   = find(d == -1) - 1;

%make 2 columns for start and end times
START_END_IX = [start_ix(:) end_ix(:)];

%make sure new intervals are at least 40 seconds
durations = START_END_IX(:,2) - START_END_IX(:,1);

BADIX = durations < minimum_duration_in_samples;

START_END_IX(BADIX,:) = [];
SLEEPIX = zeros(size(SLEEPIX));

for iR = 1:Rows(START_END_IX)
    SLEEPIX(START_END_IX(iR,1):START_END_IX(iR,2)) = 1;
end


%returning index to time
Actual_Sleep_Times_Post=[];
for dx=1:Rows(START_END_IX)
    Actual_Sleep_Times_Post(dx) = SLEEP_ALL_POST(START_END_IX(dx));
    Actual_Sleep_Times_Post= Actual_Sleep_Times_Post(:);
end
Actual_Sleep_Times_Post(:,2) = SLEEP_ALL_POST(START_END_IX(:,2));

%% final Figure
if plotit==true
    figure(1000)
    
    subplot(3,2,1)
    plot(PRE_SPEED(:,1),PRE_SPEED(:,2)), xlabel('time (m)'),ylabel('Pre_Speed (cm/s)')
    axis tight
    pubify_figure_axis
    plot_markers_simple(Actual_Sleep_Times_Pre(:,1),[],[],'g');
    plot_markers_simple(Actual_Sleep_Times_Pre(:,2),[],[],'r');
    hline = refline([0 speedthresh]);
    hline.Color = 'r';
    title('PRE SPEED- actual sleep times labeled')
    
    subplot(3,2,2)
    plot(POST_SPEED(:,1),POST_SPEED(:,2)), xlabel('time (s)'),ylabel('Post_Speed (cm/s)')
    axis tight
    plot_markers_simple(Actual_Sleep_Times_Post(:,1),[],[],'g');
    plot_markers_simple(Actual_Sleep_Times_Post(:,2),[],[],'r');
    hline = refline([0 speedthresh]);
    hline.Color = 'r';
    title('POST SPEED- actual sleep times labeled')
    pubify_figure_axis
    
    subplot(3,2,3)
    plot(PRE_jerk(:,1),PRE_jerk(:,2)),xlabel('time (s)'),ylabel('Pre_jerk (summed jerk (m/s^3)')  %this plot worked
    axis tight
    plot_markers_simple(Actual_Sleep_Times_Pre(:,1),[],[],'g');
    plot_markers_simple(Actual_Sleep_Times_Pre(:,2),[],[],'r');
    hline = refline([0 jerkthresh]);
    hline.Color = 'r';
    title('PRE JERK- actual sleep times labeled')
    pubify_figure_axis
    
    subplot(3,2,4)
    plot(POST_jerk(:,1),POST_jerk(:,2)),xlabel('time (s)'),ylabel('Pre_jerk (summed jerk (m/s^3)')  %this plot worked
    axis tight
    plot_markers_simple(Actual_Sleep_Times_Post(:,1),[],[],'g');
    plot_markers_simple(Actual_Sleep_Times_Post(:,2),[],[],'r');
    hline = refline([0 jerkthresh]);
    hline.Color = 'r';
    pubify_figure_axis
    title('POST JERK- actual sleep times labeled')
    
    subplot(3,2,5)
    plot(PRE_EMG(:,1),PRE_EMG(:,2)), xlabel('time (s)'),ylabel('EMG-PRE (uV)')
    axis tight
    plot_markers_simple(Actual_Sleep_Times_Pre(:,1),[],[],'g');
    plot_markers_simple(Actual_Sleep_Times_Pre(:,2),[],[],'r');
    hline = refline([0 EMG_thresh]);
    hline.Color = 'r';
    pubify_figure_axis
    title('PRE EMG- actual sleep times labeled')
    
    subplot(3,2,6)
    plot(POST_EMG(:,1),POST_EMG(:,2)), xlabel('time (s)'),ylabel('EMG-POST (uV)')
    axis tight
    plot_markers_simple(Actual_Sleep_Times_Post(:,1),[],[],'g');
    plot_markers_simple(Actual_Sleep_Times_Post(:,2),[],[],'r');
    hline = refline([0 EMG_thresh]);
    hline.Color = 'r';
    title('POST EMG- actual sleep times labeled')
    pubify_figure_axis
end
%% saving actual Sleep to mouse folder

directory=strsplit(pwd,'\'); %labeling mouse and day based off of folder name
dets=strsplit(directory{end},'_'); %may need to change this on your computer
name=dets{1};
newname= sprintf('%s-%s.mat', name, "Sleep_Times_Pre");
save(newname,'Actual_Sleep_Times_Pre');
newname2= sprintf('%s-%s.mat', name, "Sleep_Times_Post");
save(newname2,'Actual_Sleep_Times_Post');
save('EMGthresh.mat','EMG_thresh');

%% Save figure of actual sleep times to Sleep Classification folder
cd('E:\Lindsey\LRRK2_MLi2\Post_Processed\SleepClassification')
saveas(figure(1000),[name '.emf'])
cd(root_folder)

