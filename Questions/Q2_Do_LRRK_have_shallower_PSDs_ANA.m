%% Q2_Do_LRRK_have_shallower_PSDs_ANA

%Picked Middle Left ECOG

% ANA_dir='E:\Lindsey\LRRK2_MLi2\Analysis_Results\Questions\Q2_Do_LRRK_have_shallower_PSDs'
ANA_dir='E:\Lindsey\LRRK2_MLi2\Analysis_Results\Questions\Copy_of_Q2_Do_LRRK_have_shallower_PSDs'
cd(ANA_dir)
alldirs=dir(fullfile(ANA_dir,'*.mat'));
% MT = table();
A= [];
PSD = [];
count=1;
for ises=1:length(alldirs)
    Dset=load(fullfile(ANA_dir,alldirs(ises).name));
    if Dset.Dset.aborted==true || isempty(Dset.Dset)
        continue
    end
        %delete W40 day 7 otherwise it gets mad
    A(count).ses_count = ises;
    A(count).slope = Dset.Dset.slope;
    A(count).avpsd = 10*log10(Dset.Dset.avpsd);
    A(count).MouseName = Dset.Dset.Mouse_info.Mouse_name;
    A(count).MouseType = Dset.Dset.Mouse_info.TypeMouse;
    A(count).DayType = Dset.Dset.Mouse_info.TypeDay;

    PSD(count,:) = Dset.Dset.avpsd';
    
    PSD_x = Dset.Dset.frex;

    count=count+1;
end

%%
MT = struct2table(A);
% MT=table2struct(MT); %this is totally stupid but it turns it into rows and concatonates
%%
MT.MouseName = categorical(MT.MouseName);
MT.MouseType = categorical(MT.MouseType);
mnames = unique(MT.MouseName);
mn_psd = [];
for iMouse = 1:length(mnames)
    IX = MT.MouseName == mnames(iMouse);
    mn_psd(iMouse,:) = mean(PSD(IX,:));
    tmp = MT.MouseType(IX);
    GRP(iMouse) = tmp(1);
end
GRP = categorical(GRP);
LIX = GRP == 'L';
WIX = GRP == 'W';

figure
% plot_confidence_intervals(log(PSD_x),log(mn_psd(LIX,:)),[],'b');
% hold on
% plot_confidence_intervals(log(PSD_x),log(mn_psd(WIX,:)),[],'r');
plot_confidence_intervals(PSD_x,10*log10(mn_psd(LIX,:)),[],'b');
hold on
plot_confidence_intervals(PSD_x,10*log10(mn_psd(WIX,:)),[],'r');



%% Slope
NAMES = unique(MT.MouseName);
NT = table(MT.MouseName,MT.MouseType,MT.slope);
M = grpstats(NT,{'Var1' 'Var2'});
%%
% Mice=
for imouse=1:length(Mice)
for irow=1:Rows(MT)
    if MT(irow).MouseName==Mouse(imouse)
        Mouseslope(imouse)=MT(irow).slope;
        MousePsd(imouse)=MT(irow).avpsd;
    end
end
end

writetable(NT,'PSDslopes.xlsx')
        