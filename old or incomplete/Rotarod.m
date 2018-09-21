%% Rotarod Post-Processing 

% 1. Import excel file and divide data by animal, save that to folder with
% neural data
excelfile='171007.xlsx';

%Root dir will change based on what computer you are getting this from
rootdir='C:\Users\Lindsey Crown\Box Sync\Cowen Laboratory\!Projects\LRRK2_MLi_2\Behavioral Data\Rotarod';

mydir = uigetdir(rootdir,'Locate the correct cohort directory');
cd(mydir);

%take just the names of trial, mouse name_lane as variable names
sessioninfo=readtable(excelfile,'ReadVariableNames',true, 'Range', 'A12:E36'); %Range gives you a bit square of the data- make sure to adjust the end of this if you have more or less trials
%ideally the format and size of the table in excel should not change

sessioninfo=table2dataset(sessioninfo);

%Pull them individually apartc
L3=[sessioninfo.Trial_, sessioninfo.L3_2];
L4=[sessioninfo.Trial_, sessioninfo.L4_4];

%Compute Things
mean(sessioninfo.L3_2)

%plot things
plot(L3(:,1),L3(:,2))
hold on
plot(L4(:,1),L4(:,2))

