ANA_dir='E:\Lindsey\LRRK2_MLi2\Analysis_Results\Questions\Find_jerk_for_wake'
alldirs=dir(fullfile(ANA_dir,'*.mat'));
MT = table();
A= [];
count=1;
for ises=1:length(alldirs)
    Dset=load(fullfile(ANA_dir,alldirs(ises).name));
    if Dset.Dset.aborted==true || isempty(Dset.Dset)
        continue
    end
    A(count).ses_count = ises;
%     A(count).MouseName = Dset.Dset.Mouse_info.Mouse_name;
%     A(count).MouseType = Dset.Dset.Mouse_info.TypeMouse;
if strfind(alldirs(ises).name,'L')
    A(count).JerkPOSTL = Dset.Dset.averagejerkPost;
    A(count).JerkPREL = Dset.Dset.averagejerkPre;
%     A(count).TypeDay=Dset.Dset.Mouse_info.TypeDay;
end
if strfind(alldirs(ises).name,'W')
    A(count).JerkPOSTW = Dset.Dset.averagejerkPost;
    A(count).JerkPREW = Dset.Dset.averagejerkPre;
%     A(count).TypeDay=Dset.Dset.Mouse_info.TypeDay;
end
    count=count+1;
end

MT = struct2table(A);
MT.MouseName=categorical(MT.MouseName);
MT.MouseType=categorical(MT.MouseType);
MT.TypeDay=categorical(MT.TypeDay);
%% Percentage of Time Sleeping- since we grab 100 min, this will be total time asleep pre

dsa = MT(:,{'MouseName','MouseType','PercentSleepingPRE'});
ByName = grpstats(dsa,{'MouseName','MouseType'});
% With this table made, now move to plot it
[data_matrix]=table2barplot(ByName.mean_PercentSleepingPRE,ByName.MouseType);
%
% 
% JustLRRKix=ByName.MouseType=='L';
% JustWTix=ByName.MouseType=='W';
% ByName.mean_PercentSleepingPRE(JustLRRKix)
% ByName.mean_PercentSleepingPRE(JustWTix)
% 
% diffamount=abs(length(ByName.mean_PercentSleepingPRE(JustWTix))-length(ByName.mean_PercentSleepingPRE(JustLRRKix)));
% if sum(JustWTix)>sum(JustLRRKix)
%     LRRKpercent= vertcat(ByName.mean_PercentSleepingPRE(JustLRRKix),nan(diffamount,1));
%     WTpercent=ByName.mean_PercentSleepingPRE(JustWTix);
% end
% 
% if sum(JustLRRKix)>sum(JustWTix)
%     WTpercent= vertcat(ByName.mean_PercentSleepingPRE(JustWTix),nan(diffamount,1));
%     LRRKpercent=ByName.mean_PercentSleepingPRE(JustLRRKix);
% end
% 
% if sum(JustWTix)==sum(JustLRRKix)
%     LRRKpercent=ByName.mean_PercentSleepingPRE(JustLRRKix);
%     WTpercent=ByName.mean_PercentSleepingPRE(JustWTix);
% end

data_matrix=[LRRKpercent*100,WTpercent*100];

figure
Error_bars(data_matrix) %plot with dots!!!
 
%% Number of Bouts during PreSleep
dsa = MT(:,{'MouseName','MouseType','NumberBoutsPRE'});
ByName = grpstats(dsa,{'MouseName','MouseType'});
% With this table made, now move to plot it
[data_matrix]=table2barplot(ByName.mean_NumberBoutsPRE,ByName.MouseType); %needs a mean_!!!

figure
Error_bars(data_matrix)
%% Length of Pre Sleep bout

dsa = MT(:,{'MouseName','MouseType','Mean_bout_length_PRE'});
ByName = grpstats(dsa,{'MouseName','MouseType'});
% With this table made, now move to plot it
[data_matrix]=table2barplot(ByName.mean_Mean_bout_length_PRE/60,ByName.MouseType); %needs a mean_!!!

figure
Error_bars(data_matrix)
%% STD of bout length
dsa = MT(:,{'MouseName','MouseType','STD_bout_length_PRE'});
ByName = grpstats(dsa,{'MouseName','MouseType'});
% With this table made, now move to plot it
[data_matrix]=table2barplot(ByName.mean_STD_bout_length_PRE/60,ByName.MouseType); %needs a mean_!!!

figure
Error_bars(data_matrix)
%% Compare Mouse difference in time asleep Post-Pre for boring and RR days
% TypeDay
% PostminusPRE_TimeAsleep

dsa = MT(:,{'MouseName','MouseType','TypeDay','PostminusPRE_TimeAsleep'});
ByName = grpstats(dsa,{'MouseName','MouseType','TypeDay'});
% With this table made, now move to plot it
% now you are going to have 4 plots so previously used function wont work-
% copy pasting the function contents below
ByName.TypeDay=categorical(ByName.TypeDay);

LRRK_BORING_ix= ByName.MouseType=='L' & ByName.TypeDay=='Boring';
WT_BORING_ix= ByName.MouseType=='W' & ByName.TypeDay=='Boring';
LRRK_RR_ix= ByName.MouseType=='L' & ByName.TypeDay=='Rotarod';
WT_RR_ix= ByName.MouseType=='W' & ByName.TypeDay=='Rotarod';

variable=ByName.mean_PostminusPRE_TimeAsleep;

LRRK_BORING=variable(LRRK_BORING_ix);
WT_BORING=variable(WT_BORING_ix);
LRRK_RR=variable(LRRK_RR_ix);
WT_RR=variable(WT_RR_ix);

WT_BORINGG=[WT_BORING;nan(2,1)];
LRRK_RRR=[LRRK_RR; nan(1,1)];
WT_RRR=[WT_RR;nan(2,1)];

datamatrix=[LRRK_BORING/60, WT_BORINGG/60, LRRK_RRR/60, WT_RRR/60];


figure
Error_bars(datamatrix)
