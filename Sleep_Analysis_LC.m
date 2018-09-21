function [SleepAnalysis] = Sleep_Analysis_LC (mouse_folder)

% function inputs mouse folder name (e.g. L13Day1) and outputs a
% structure containing 
%-mean & STD sleep bout length/ inter-interval
%plot of means & STDs
%hist of sleep bouts
%total time asleep
%total number of bouts 

%Monroe 2018 edited by Lindsey

%need to begin in day ___ main folder (with all 4 mice)
%assert(~isempty(dir(mouse_folder)),'Mouse_folder_missing')
%cd(mouse_folder);
SleepAnalysis.aborted=false;
Sleep_Period_min=100; %number of minutes to grab from middle
%% load SleepTimes
%load EPOCHS for mouse group 
if nargin<1
    mouse_folder=pwd;
end

f=find_files('*Sleep_Times_Post*.mat');
ff=find_files('*Sleep_Times_Pre*.mat');
if isempty(f) || isempty(ff)
    SleepAnalysis.aborted=true;
    return
end

Post= load(f{1}); 
Pre= load(ff{1});
fff=find_files('*EPOCHS*');
load(fff{1});
% Post.Actual_Sleep_Times_Post;
% Pre.Actual_Sleep_Times_Pre;
if ~isempty(Post.Actual_Sleep_Times_Post) && ~isempty(Pre.Actual_Sleep_Times_Pre)
%if you load Epochs you get PreSleep_t_sec and PostSleep_t_sec, these are
%in LFP time- just going from start to pre sleep and taking the middle 100
%of that and doing likewise for post should work?

[Adjusted_Pre,Adjusted_Post,adjusted_bounds]=Adjust_to_Middle_Sleep(EPOCHS,Pre.Actual_Sleep_Times_Pre, Post.Actual_Sleep_Times_Post,Sleep_Period_min);


[Mouse_info]=Get_Mouse_Session_Info;
%% find means & STDs sleep bout lengths
% for bout length if you have a cut bout then still grab the whole thing
pre_withinboundIX= Pre.Actual_Sleep_Times_Pre< adjusted_bounds.upper_bound_pre & Pre.Actual_Sleep_Times_Pre > adjusted_bounds.lower_bound_pre;
post_withinboundIX= Post.Actual_Sleep_Times_Post< adjusted_bounds.upper_bound_post & Post.Actual_Sleep_Times_Post > adjusted_bounds.lower_bound_post;


for iinterval=1:Rows(Pre.Actual_Sleep_Times_Pre)
    pre_bout_length(iinterval)=Pre.Actual_Sleep_Times_Pre(iinterval,2)-Pre.Actual_Sleep_Times_Pre(iinterval,1);
    if sum(pre_withinboundIX(iinterval))==0
        pre_bout_length(iinterval)=nan;
    end
end
for iinterval=1:Rows(Post.Actual_Sleep_Times_Post)
    post_bout_length(iinterval)=Post.Actual_Sleep_Times_Post(iinterval,2)-Post.Actual_Sleep_Times_Post(iinterval,1);
    if sum(post_withinboundIX(iinterval))==0
        post_bout_length(iinterval)=nan;
    end
end
    
    
Pre_bout_mean_length=nanmean(pre_bout_length);
Pre_bout_std = nanstd(pre_bout_length);

Post_bout_mean_length= nanmean(post_bout_length);
Post_bout_std = nanstd(post_bout_length);

%% find means and STDs inter-sleep-Intervals 

inter_interval_times_pre = Adjusted_Pre(2:end,1) - Adjusted_Pre(1:end-1,2);
mean_iit_pre = nanmean(inter_interval_times_pre);
STD_iit_pre = nanstd(inter_interval_times_pre);

inter_interval_times_post = Adjusted_Post(2:end,1) - Adjusted_Post(1:end-1,2);
mean_iit_post = nanmean(inter_interval_times_post);
STD_iit_post = nanstd(inter_interval_times_post);

%% plot everything 
%mean= [Pre_bout_mean, mean_iit_pre; Post_bout_mean, mean_iit_post];
%std= [Pre_bout_STDs, STD_iit_pre; Post_bout_STDs, STD_iit_post];

find_mean = [Pre_bout_mean_length,  mean_iit_pre; Post_bout_mean_length, mean_iit_post];
find_STD = [Pre_bout_std, STD_iit_pre; Post_bout_std STD_iit_post];
figure; hold;
p=barwitherr_Monroe(find_STD, find_mean);
set(gca, 'FontSize',12,'XTick',[1 2],'XTickLabel',{'Pre', 'Post' });
ylabel('Mean Time (s)')
legend ('Bout length', 'inter-interval periods')
title('Mean Sleep Bout length and Inter-Sleep-Interval Periods')


%% histogram of sleep bout length
figure
subplot(1,2,1)
h=histogram(pre_bout_length,50);
if ismac==1
directory=strsplit(pwd,'/'); %labeling mouse and day based off of folder name
dets=strsplit(directory{7},'_'); %may need to change this on your computer 
name=dets{1};
end
if ispc==1
  directory=strsplit(pwd,'\'); %labeling mouse and day based off of folder name
mouseday=directory{end};%may need to change this on your computer 
name=mouseday;
end
mousedaypre= sprintf('%s-%s', name, 'Pre');
ylabel(mousedaypre)
xlabel('Bout Length (s)')
mousedaypost = sprintf('%s-%s', name, 'Post');
subplot(1,2,2)
histogram(post_bout_length,50)
ylabel(mousedaypost)
xlabel('Bout Length (s)')

%need to add title somehow- which mouse, which day


%% Total number of bouts

tots=pre_withinboundIX(:,1)+pre_withinboundIX(:,2);
number_bouts_Pre= sum(tots>=1);

tots2=post_withinboundIX(:,1)+post_withinboundIX(:,2);
number_bouts_Post= sum(tots2>=1);
%% total time spent sleep 
length_bout=Adjusted_Pre(:,2)-Adjusted_Pre(:,1);
time_asleep_pre_sec=nansum(length_bout); %in seconds

length_bout2=Adjusted_Post(:,2)-Adjusted_Post(:,1);
time_asleep_post_sec=nansum(length_bout2); %in seconds



%% saving everything
if ismac==1
directory=strsplit(pwd,'/'); %labeling mouse and day based off of folder name
dets=strsplit(directory{7},'_'); %may need to change this on your computer 
name=dets{1};
end
if ispc==1
directory=strsplit(pwd,'\'); %labeling mouse and day based off of folder name
mouseday=directory{end};%may need to change this on your computer 
name=mouseday;
end

name_for_file= ['SleepAnalysis' name '.mat'];
SleepAnalysis.MouseName=name;
SleepAnalysis.AdjustedPre=Adjusted_Pre;
SleepAnalysis.AdjustedPost=Adjusted_Post;
SleepAnalysis.bout_length_mean_pre=Pre_bout_mean_length;
SleepAnalysis.bout_length_mean_post=Post_bout_mean_length;
SleepAnalysis.bout_std_pre=Pre_bout_std;
SleepAnalysis.bout_std_post=Post_bout_std;
SleepAnalysis.iit_length_mean_pre=mean_iit_pre;
SleepAnalysis.iit_length_mean_post=mean_iit_post;
SleepAnalysis.iit_std_pre=STD_iit_pre;
SleepAnalysis.iit_std_post=STD_iit_post;
SleepAnalysis.plot=p;
SleepAnalysis.hist_bout_lengths=h;
SleepAnalysis.number_bouts_pre=number_bouts_Pre;
SleepAnalysis.number_bouts_post=number_bouts_Post;
SleepAnalysis.total_time_asleep_pre=time_asleep_pre_sec;
SleepAnalysis.total_time_asleep_post=time_asleep_post_sec;
SleepAnalysis.Sleep_Period_min=Sleep_Period_min;
SleepAnalysis.Mouse_info=Mouse_info;  %so you have all the meta data
save(name_for_file, '-struct' ,'SleepAnalysis');

else
    SleepAnalysis.aborted=true;
end
