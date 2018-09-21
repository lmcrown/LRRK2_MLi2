function summaryplots_ECoG(root_folder)

if nargin<1
    root_folder=pwd;
end

% assuming post-processing is complete
cd(root_folder)

pieces=strsplit(root_folder,'\');
Mouse_folders= pieces{4};
Mice=strsplit(Mouse_folders,'_');
Daybits=strsplit(pieces{5},'_');
for icell=1:numel(Daybits)
    if contains(Daybits{icell},'Day')==1
        day=Daybits{icell};
    end
end

for imouse=1:numel(Mice)
    assert(isdir([ Mice{imouse} day]),'folder does not exist for one or more mice')
    try cd([Mice{imouse} day])
    catch
        error('probably not postprocessed, cant cd to mouse folder')
    end
    if ~exist('POS*Day*.mat','file')==2 %%%% issues here
        sprintf('no POS data for %s',Mice(imouse))
        continue
    end
    cd(root_folder)
end


cd(root_folder)
clear count
for ifold=1:numel(Mice)
    cd(root_folder)
    cd([Mice{ifold} day])
    if ~isdir('figs')
        mkdir('figs')
    end
    fspeed=find_files('SPEED*.mat'); %now called Speed_specific (has time in first col and speed in second)
    load(fspeed{1});
    ffiles_left=find_files('*ECoG_Left*.mat');
    count=1;
    figure;
    for ifile=1:length(ffiles_left)
        subplot(4,2,count)
        file=load(ffiles_left{ifile});
        EPOCHS=load('EPOCHS.mat');
        plot(file.LFP_uV(:,1),file.LFP_uV(:,2))
        ylabel('uV')
        title(ffiles_left{ifile}(1:end-4))
        vline(EPOCHS.EPOCHS.PREsleep_t_sec,'k','PreSleepEND') %downloaded this from the internet, also allows you to label the line with a third input
        vline(EPOCHS.EPOCHS.POSTsleep_t_sec,'k','PostSleepSTART')
        
        [pxx,fx] = pwelch(file.LFP_uV(:,2),500,250,1:120,file.fs_final);
        subplot(4,2,count+1)
        plot(fx,10*log10(pxx))
        xlabel('Frequency (Hz)')
        ylabel('Power (dB)')
        clear LFP_uV
        count=count+2;
        
        subplot(4,2,7)
        plot(Speed_specific(:,1),Speed_specific(:,2))
        ylabel('Speed')
        xlabel('Time')
    end
    cd('figs')
    savefig([Mice{ifold} day '_Left_ECOG'])
    cd ..
    ffiles_right=find_files('*ECoG_Right*.mat');
    count=1;
    figure;
    for ifile=1:length(ffiles_right)
        subplot(4,2,count)
        othafile=load(ffiles_right{ifile});
        plot(othafile.LFP_uV(:,1),othafile.LFP_uV(:,2))
        ylabel('uV')
        title(ffiles_right{ifile}(1:end-4))
        EPOCHS=load('EPOCHS.mat');
        vline(EPOCHS.EPOCHS.PREsleep_t_sec,'k','PreSleepEND') %downloaded this from the internet, also allows you to label the line with a third input
        vline(EPOCHS.EPOCHS.POSTsleep_t_sec,'k','PostSleepSTART')
        [pxx,fx] = pwelch(othafile.LFP_uV(:,2),500,250,1:120,othafile.fs_final);
        
        subplot(4,2,count+1)
        plot(fx,10*log10(pxx))
        xlabel('Frequency (Hz)')
        ylabel('Power (dB)')
        clear LFP_uV
        count=count+2;
        
        subplot(4,2,7)
        plot(Speed_specific(:,1),Speed_specific(:,2))
        ylabel('Speed')
        xlabel('Time')
    end
    
    cd('figs')
    savefig([Mice{ifold} day '_Right_ECOG'])
    cd ..
end

