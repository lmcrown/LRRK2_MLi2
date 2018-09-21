ANA_dir='E:\Lindsey\LRRK2_MLi2\Analysis_Results\Questions\Sleep_Analysis_LC'
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
    A(count).Mean_bout_length_PRE = Dset.Dset.bout_length_mean_pre;
    A(count).STD_bout_length_PRE = Dset.Dset.bout_std_pre;
    A(count).MouseName = Dset.Dset.Mouse_info.Mouse_name;
    A(count).MouseType = Dset.Dset.Mouse_info.TypeMouse;
    A(count).TotalSleepTimePRE = Dset.Dset.total_time_asleep_pre;
    A(count).NumberBoutsPRE = Dset.Dset.number_bouts_pre;
count=count+1;
end

MT = struct2table(A);
%%
MT.MouseName=categorical(MT.MouseName);
MT.MouseType=categorical(MT.MouseType);

dsa = MT(:,{'MouseName','Mean_bout_length_PRE','TotalSleepTimePRE','NumberBoutsPRE'});
statarray = grpstats(dsa,'MouseName');

writetable(statarray,'statarray.xlsx')
% splitapply(

%%
MT.MouseName=categorical(MT.MouseName);
MT.MouseType=categorical(MT.MouseType);


%% MEAN SLEEP BOUT TIME
%  Mice=categorical(unique(MT.MouseName));
Mice=unique(MT.MouseName);
Mice=categorical(unique(MT.MouseName));
for imouse=1:numel(Mice)
       
ix=MT.MouseName==Mice(imouse);
Tot_mouse_mean_bout(imouse)=mean(MT.Mean_bout_length_PRE(ix));
Tot_mouse_std_bout(imouse)=std(Tot_mouse_mean_bout);


title(sprintf('Mean Pre Sleep Bout length for mouse %s', char(Mice(imouse))))
end
Mice=unique(MT.MouseName);
figure
barwitherr_Monroe(Tot_mouse_std_bout,Tot_mouse_mean_bout);
% set(gca, 'FontSize',12,'XTick',[1 2 3 4],'XTickLabel',{sprintf('Pre %s', char(Mice))});
set(gca, 'FontSize',12,'XTick',[1 2 3 4 5 6 7],'XTickLabel',{Mice{1} Mice{2} Mice{3} Mice{4} Mice{5} Mice{6} Mice{7}});

ylabel('Mean Time (s)')
legend ('Bout length')

%% STD OF BOUTS
Mice=categorical(unique(MT.MouseName));
for imouse=1:numel(Mice)

ix=MT.MouseName==Mice(imouse);
Tot_std_mean_bout(imouse)=mean(MT.STD_bout_length_PRE(ix));
std_std_bout(imouse)=std(MT.STD_bout_length_PRE(ix));


end
Mice=unique(MT.MouseName);
figure
barwitherr_Monroe(std_std_bout,Tot_std_mean_bout);
% set(gca, 'FontSize',12,'XTick',[1 2 3 4],'XTickLabel',{sprintf('Pre %s', char(Mice))});
set(gca, 'FontSize',12,'XTick',[1 2 3 4 5 6 7],'XTickLabel',{Mice{1} Mice{2} Mice{3} Mice{4} Mice{5} Mice{6} Mice{7}});

ylabel('Mean bout standard deviation (s)')
legend ('Bout std')
%% NUMBER OF SLEEP BOUTS
Mice=categorical(unique(MT.MouseName));
for imouse=1:numel(Mice)

ix=MT.MouseName==Mice(imouse);
NumberBoutsPRE(imouse)=mean(MT.NumberBoutsPRE(ix));
std_numboutsPRE(imouse)=std(MT.NumberBoutsPRE(ix));


end
Mice=unique(MT.MouseName);
figure
barwitherr_Monroe(std_numboutsPRE,NumberBoutsPRE);
% set(gca, 'FontSize',12,'XTick',[1 2 3 4],'XTickLabel',{sprintf('Pre %s', char(Mice))});
set(gca, 'FontSize',12,'XTick',[1 2 3 4 5 6 7],'XTickLabel',{Mice{1} Mice{2} Mice{3} Mice{4} Mice{5} Mice{6} Mice{7}});

ylabel('Mean Number of Bouts')
legend ('Number of Bouts')
%% Total time Asleep
Mice=categorical(unique(MT.MouseName));
for imouse=1:numel(Mice)

ix=MT.MouseName==Mice(imouse);
meantotalsleeptimePRE(imouse)=mean(MT.TotalSleepTimePRE(ix));
stdsleeptimePRE(imouse)=std(MT.TotalSleepTimePRE(ix));


end
Mice=unique(MT.MouseName);
figure
barwitherr_Monroe(stdsleeptimePRE/60,meantotalsleeptimePRE/60);
set(gca, 'FontSize',12,'XTick',[1 2 3 4 5 6 7],'XTickLabel',{Mice{1} Mice{2} Mice{3} Mice{4} Mice{5} Mice{6} Mice{7}});

ylabel('Total Sleep Time (min)')
legend ('Sleep Time')