function MLi2_check_LFP_wReRef

eeg_chan=uigetfile

ff=find_files('*Reref.mat');
 main_signal=eeg_chan;
LFP=load(eeg_chan);


load(ff{1})

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

figure;
plot(ECOG(:,1),ECOG(:,2));

fff=find_files('*Sleep_Times_Post*');
load(fff{1})

for isleep=1:Rows(Actual_Sleep_Times_Post)
vline(Actual_Sleep_Times_Post(isleep,1),'g')
vline(Actual_Sleep_Times_Post(isleep,2),'r')
end

ffff=find_files('*Sleep_Times_Pre*');
load(ffff{1})

for isleep=1:Rows(Actual_Sleep_Times_Pre)
vline(Actual_Sleep_Times_Pre(isleep,1),'g')
vline(Actual_Sleep_Times_Pre(isleep,2),'r')
end