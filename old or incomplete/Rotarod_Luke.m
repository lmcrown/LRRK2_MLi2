%% Rotarod Post-Processing 

% 1. Import excel file and divide data by animal, save that to folder with
% neural data
excelfile='171213.xlsx';

%Root dir will change based on what computer you are getting this from
rootdir='C:\Users\Stephen_Cowen\Desktop\Rotarod';

mydir = uigetdir(rootdir,'Locate the correct cohort directory');
cd(mydir);

%take just the names of trial, mouse name_lane as variable names
sessioninfo=readtable(excelfile,'ReadVariableNames',true, 'Range', 'A12:E32'); %Range gives you a bit square of the data- make sure to adjust the end of this if you have more or less trials
%ideally the format and size of the table in excel should not change

sessioninfo=table2dataset(sessioninfo);

%Pull them individually apartc
L5=[sessioninfo.Trial_, sessioninfo.L5_1];
L6=[sessioninfo.Trial_, sessioninfo.L6_2];
L7=[sessioninfo.Trial_, sessioninfo.L7_3];
L8=[sessioninfo.Trial_, sessioninfo.L8_4];

%Make the data sets for each
L5_data = sessioninfo.L5_1
L6_data = sessioninfo.L6_2
L7_data = sessioninfo.L7_3
L8_data = sessioninfo.L8_4

%Compute Things
L5_mean = mean(L5_data);
L6_mean = mean(L6_data);
L7_mean = mean(L7_data);
L8_mean = mean(L8_data);
L5_med = median(L5_data);
L6_med = median(L6_data);
L7_med = median(L7_data);
L8_med = median(L8_data);
L5_std = std(L5_data);
L6_std = std(L6_data);
L7_std = std(L7_data);
L8_std = std(L8_data);

%Write to a file
res = fopen('171213.txt','w');
fprintf(res,'Means: L5 = %.3f \n \t L6 = %.3f \n \t L7 = %.3f \n \t L8 = %.3f \n', L5_mean, L6_mean, L7_mean, L8_mean);
fprintf(res,'Medians: L5 = %.3f \n \t L6 = %.3f \n \t L7 = %.3f \n \t L8 = %.3f \n', L5_med, L6_med, L7_med, L8_med);
fprintf(res,'Standard Dev: L5 = %.3f \n \t L6 = %.3f \n \t L7 = %.3f \n \t L8 = %.3f \n', L5_std, L6_std, L7_std, L8_std);
fclose(res);

%plot things
plot(L5(:,1),L5(:,2))
hold on
plot(L6(:,1),L6(:,2))
hold on 
plot(L7(:,1),L7(:,2))
hold on 
plot(L8(:,1),L8(:,2))

