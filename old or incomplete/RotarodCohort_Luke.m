%% Rotarod Post-Processing for full cohort

% 1. Import excel file and divide data by animal, save that to folder with
% neural data
excelfile1='171213.xlsx';
excelfile2='171215.xlsx';
excelfile3='171220.xlsx';
excelfile4='171222.xlsx';


%Root dir will change based on what computer you are getting this from
rootdir='C:\Users\Stephen_Cowen\Desktop\Rotarod';

mydir = uigetdir(rootdir,'Locate the correct cohort directory');
cd(mydir);

%take just the names of trial, mouse name_lane as variable names
sessioninfo1=readtable(excelfile1,'ReadVariableNames',true, 'Range', 'A12:E32'); %Range gives you a bit square of the data- make sure to adjust the end of this if you have more or less trials
sessioninfo2=readtable(excelfile2,'ReadVariableNames',true, 'Range', 'A12:E32');
sessioninfo3=readtable(excelfile3,'ReadVariableNames',true, 'Range', 'A12:E32');
sessioninfo4=readtable(excelfile4,'ReadVariableNames',true, 'Range', 'A12:E32');
%ideally the format and size of the table in excel should not change

sessioninfo1=table2dataset(sessioninfo1);

%Pull them individually apartc
L5_1=[sessioninfo1.Trial_, sessioninfo1.L5_1];
L6_1=[sessioninfo1.Trial_, sessioninfo1.L6_2];
L7_1=[sessioninfo1.Trial_, sessioninfo1.L7_3];
L8_1=[sessioninfo1.Trial_, sessioninfo1.L8_4];

L5_2=[sessioninfo2.Trial_, sessioninfo2.L5_1];
L6_2=[sessioninfo2.Trial_, sessioninfo2.L6_2];
L7_2=[sessioninfo2.Trial_, sessioninfo2.L7_3];
L8_2=[sessioninfo2.Trial_, sessioninfo2.L8_4];

L5_3=[sessioninfo3.Trial_, sessioninfo3.L5_1];
L6_3=[sessioninfo3.Trial_, sessioninfo3.L6_2];
L7_3=[sessioninfo3.Trial_, sessioninfo3.L7_3];
L8_3=[sessioninfo3.Trial_, sessioninfo3.L8_4];

L5_4=[sessioninfo4.Trial_, sessioninfo4.L5_1];
L6_4=[sessioninfo4.Trial_, sessioninfo4.L6_2];
L7_4=[sessioninfo4.Trial_, sessioninfo4.L7_3];
L8_4=[sessioninfo4.Trial_, sessioninfo4.L8_4];

%Make the data sets for each
L5_data1 = sessioninfo1.L5_1;
L6_data1 = sessioninfo1.L6_2;
L7_data1 = sessioninfo1.L7_3;
L8_data1 = sessioninfo1.L8_4;

L5_data2 = sessioninfo2.L5_1;
L6_data2 = sessioninfo2.L6_2;
L7_data2 = sessioninfo2.L7_3;
L8_data2 = sessioninfo2.L8_4;

L5_data3 = sessioninfo3.L5_1;
L6_data3 = sessioninfo3.L6_2;
L7_data3 = sessioninfo3.L7_3;
L8_data3 = sessioninfo3.L8_4;

L5_data4 = sessioninfo4.L5_1;
L6_data4 = sessioninfo4.L6_2;
L7_data4 = sessioninfo4.L7_3;
L8_data4 = sessioninfo4.L8_4;


%Compute Things
L5_mean1 = mean(L5_data1);
L6_mean1 = mean(L6_data1);
L7_mean1 = mean(L7_data1);
L8_mean1 = mean(L8_data1);
L5_mean2 = mean(L5_data2);
L6_mean2 = mean(L6_data2);
L7_mean2 = mean(L7_data2);
L8_mean2 = mean(L8_data2);
L5_mean3 = mean(L5_data3);
L6_mean3 = mean(L6_data3);
L7_mean3 = mean(L7_data3);
L8_mean3 = mean(L8_data3);
L5_mean4 = mean(L5_data4);
L6_mean4 = mean(L6_data4);
L7_mean4 = mean(L7_data4);
L8_mean4 = mean(L8_data4);
L5_med1 = median(L5_data1);
L6_med1 = median(L6_data1);
L7_med1 = median(L7_data1);
L8_med1 = median(L8_data1);
L5_med2 = median(L5_data2);
L6_med2 = median(L6_data2);
L7_med2 = median(L7_data2);
L8_med2 = median(L8_data2);
L5_med3 = median(L5_data3);
L6_med3 = median(L6_data3);
L7_med3 = median(L7_data3);
L8_med3 = median(L8_data3);
L5_med4 = median(L5_data4);
L6_med4 = median(L6_data4);
L7_med4 = median(L7_data4);
L8_med4 = median(L8_data4);
L5_std1 = std(L5_data1);
L6_std1 = std(L6_data1);
L7_std1 = std(L7_data1);
L8_std1 = std(L8_data1);
L5_std2 = std(L5_data2);
L6_std2 = std(L6_data2);
L7_std2 = std(L7_data2);
L8_std2 = std(L8_data2);
L5_std3 = std(L5_data3);
L6_std3 = std(L6_data3);
L7_std3 = std(L7_data3);
L8_std3 = std(L8_data3);
L5_std4 = std(L5_data4);
L6_std4 = std(L6_data4);
L7_std4 = std(L7_data4);
L8_std4 = std(L8_data4);


% %Write to a file
% res = fopen('171213.txt','w');
% fprintf(res,'Means: L5 = %.3f \n \t L6 = %.3f \n \t L7 = %.3f \n \t L8 = %.3f \n', L5_mean, L6_mean, L7_mean, L8_mean);
% fprintf(res,'Medians: L5 = %.3f \n \t L6 = %.3f \n \t L7 = %.3f \n \t L8 = %.3f \n', L5_med, L6_med, L7_med, L8_med);
% fprintf(res,'Standard Dev: L5 = %.3f \n \t L6 = %.3f \n \t L7 = %.3f \n \t L8 = %.3f \n', L5_std, L6_std, L7_std, L8_std);
% fclose(res);

%Write to Excel, note that the labels for day and mouse/mean,med,std will
%need to be filled in
a=          [0, 0, 0, 0, 0;
            0, L5_mean1, L5_mean2, L5_mean3, L5_mean4;
            0, L5_med1, L5_med2, L5_med3, L5_med4;
            0, L5_std1, L5_std2, L5_std3, L5_std4;
            0, L6_mean1, L6_mean2, L6_mean3, L6_mean4;
            0, L6_med1, L6_med2, L6_med3, L6_med4;
            0, L6_std1, L6_std2, L6_std3, L6_std4;
            0, L7_mean1, L7_mean2, L7_mean3, L7_mean4;
            0, L7_med1, L7_med2, L7_med3, L7_med4;
            0, L7_std1, L7_std2, L7_std3, L7_std4;
            0, L8_mean1, L8_mean2, L8_mean3, L8_mean4;
            0, L8_med1, L8_med2, L8_med3, L8_med4;
            0, L8_std1, L8_std2, L8_std3, L8_std4];

outputfilename = 'Cohort5_data.xlsx';
xlswrite(outputfilename, a);

%lines of best fit or improvement ratios
days = [1, 2, 3, 4];
L5_means = [L5_mean1, L5_mean2, L5_mean3, L5_mean4];
L6_means = [L6_mean1, L6_mean2, L6_mean3, L6_mean4];
L7_means = [L7_mean1, L7_mean2, L7_mean3, L7_mean4];
L8_means = [L8_mean1, L8_mean2, L8_mean3, L8_mean4];

p1 = polyfit(days, L5_means, 1);
p2 = polyfit(days, L6_means, 1);
p3 = polyfit(days, L7_means, 1);
p4 = polyfit(days, L8_means, 1);
lincoeff_L5 = p1(1)
lincoeff_L6 = p2(1)
lincoeff_L7 = p3(1)
lincoeff_L8 = p4(1)
%beta0 = [1,1,1];
%logsL5 = nlinfit(days, L5_means, modelfun, beta0)

%plot things
figure

subplot(2,2,1)
plot(L5_1(:,1),L5_1(:,2))
hold on
plot(L6_1(:,1),L6_1(:,2))
hold on 
plot(L7_1(:,1),L7_1(:,2))
hold on 
plot(L8_1(:,1),L8_1(:,2))
title('171213')

subplot(2,2,2)
plot(L5_2(:,1),L5_2(:,2))
hold on
plot(L6_2(:,1),L6_2(:,2))
hold on 
plot(L7_2(:,1),L7_2(:,2))
hold on 
plot(L8_2(:,1),L8_2(:,2))
title('171215')

subplot(2,2,3)
plot(L5_3(:,1),L5_3(:,2))
hold on
plot(L6_3(:,1),L6_3(:,2))
hold on 
plot(L7_3(:,1),L7_3(:,2))
hold on 
plot(L8_3(:,1),L8_3(:,2))
title('171220')

subplot(2,2,4)
plot(L5_4(:,1),L5_4(:,2))
hold on
plot(L6_4(:,1),L6_4(:,2))
hold on 
plot(L7_4(:,1),L7_4(:,2))
hold on 
plot(L8_4(:,1),L8_4(:,2))
title('171222')


f1 = polyval(p1,days);  
f2 = polyval(p2,days);
f3 = polyval(p3,days);
f4 = polyval(p4,days);
figure

subplot(2,2,1)
plot(days,L5_means,'o',days,f1,'-') 
axis([0.5 4.5 30 100])
legend('data','linear fit')
title('L5 Means')

subplot(2,2,2)
plot(days,L6_means,'o',days,f2,'-') 
axis([0.5 4.5 30 100])
legend('data','linear fit')
title('L6 Means')

subplot(2,2,3)
plot(days,L7_means,'o',days,f3,'-') 
axis([0.5 4.5 30 100])
legend('data','linear fit')
title('L7 Means')

subplot(2,2,4)
plot(days,L8_means,'o',days,f4,'-') 
axis([0.5 4.5 30 100])
legend('data','linear fit')
title('L8 Means')

