%% LRRK2_LOAD_AND_LABEL_ALL_CHANNELS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Grab locations of datlfp files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root_folder = pwd;
lfp_folder = [pwd '\LFP'];
postprocess_folder = [pwd '\PostProcess'];

File_name = ['Condition_' num2str(iCondition) '_Mouse_' num2str(iMice_folders) '_Day_' num2str(iDay_folders) '_' num2str(sr) 'Hz_' ];
% HPC_File_name = ['Condition_' num2str(iCondition) '_Mouse_' num2str(iMice_folders) '_Day_' num2str(iDay_folders) '_' num2str(PP_sr) 'Hz_' ];
TS_File_name = ['Condition_' num2str(iCondition) '_Mouse_' num2str(iMice_folders) '_Day_' num2str(iDay_folders)  '_' num2str(sr) 'Hz_' ];
EMG_File_name = ['Condition_' num2str(iCondition) '_Mouse_' num2str(iMice_folders) '_Day_' num2str(iDay_folders) '_' num2str(sr) 'Hz_' ];
AUX_File_name = ['Condition_' num2str(iCondition) '_Mouse_' num2str(iMice_folders) '_Day_' num2str(iDay_folders)  '_' num2str(sr) 'Hz_' ];

%% Make a postprocessing folder for this particular day
if ~exist(postprocess_folder,'dir')
    mkdir(postprocess_folder)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Channel translation table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(root_folder);

d = dir( fullfile('.','Channel_translation*.xlsx'));
ch_translation_full_path_fname = fullfile(pwd, d(1).name);

[num,txt,raw] = xlsread(ch_translation_full_path_fname);
%txt is name of what it is- would be good to label things with- seems to
chantab=readtable(ch_translation_full_path_fname,'ReadVariableNames',true);  %make sure you have most up-to-date excel file
chantab=table2dataset(chantab);
Intannum=chantab.IntanCh_(chantab.IsLFP_ == 1);
%"Location col is regions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Grab times and datlfp files
cd(lfp_folder);
LFP_files = find_files('*.datlfp');

LFP_files = natsort(LFP_files); %%for some reason loads LFP_Ch_10 before LFP_Ch_1 - why the hell should I have to do this, stupid Matlab
if Cols(LFP_files) > Rows(LFP_files)
    LFP_files = LFP_files';
end
cd ..
%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load time file

LFP_t_sec = INTAN_Load_Time('time_LFP.dat');

% There were some issues with the time_LFP file not being created in the correct format?
if new_animal_data == 0
    cd(lfp_folder)
    
    LFP_t_sec = INTAN_Load_Time('time_LFP.dat');%,2000,length(test_file));
    
    if LFP_t_sec(end)/60/60 > 10 | LFP_t_sec(end)/60/60 < 1
        warning('ERROR! TIME.DAT FILE INCORRECT!')
        
        test_file = find_files('*.datlfp');
        fid = fopen(test_file{2}, 'r');
        test_file = fread(fid, inf, 'int16');
        fclose(fid);
        
        
    end
    
    cd(Current_dir)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(lfp_folder);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gain = .195; %CONVERTS TO MICROVOLTS

%% Only pick out spindle channels

Intannum=chantab.IntanCh_(chantab.IsLFP_ == 1);
Location_intan=chantab.Location(chantab.IsLFP_ == 1);

EMG_channels = chantab.IntanCh_(strcmp(chantab.Location(:),'EMG'));
spindle_channels = chantab.IntanCh_(strcmp(chantab.Location(:),'EEGwire_ant')...
    | strcmp(chantab.Location(:),'EEGwire_post')...
    | strcmp(chantab.Location(:),'ECoG_ant')...
    | strcmp(chantab.Location(:),'ECoG_post')...
    | strcmp(chantab.Location(:),'ECoG_mid'));

EMGix=false(size(Intannum));
for i=1:Rows(EMG_channels)
    ix=(Intannum==EMG_channels(i));
    EMGix=EMGix|ix;
end
Spinix=false(size(Intannum));
for i=1:Rows(spindle_channels)
    ix=(Intannum==spindle_channels(i));
    Spinix=Spinix|ix;
end

LFPs=find_files('*.datlfp');
Spinchans={};

s=strsplit(pwd,'\');
File_name=char(s{4});

if ~isempty(spindle_channels)
    for iLFP_spindles = 1:numel(lfp_folder)
        % Load the LFP data.
        if Spinix(iLFP_spindles)==1
            fid = fopen(LFPs{iLFP_spindles}, 'r');
            Spin_chan = fread(fid, inf, 'int16');
            fclose(fid);
            Spin_chan= Spin_chan *gain;
            cd(postprocess_folder);
            cellfile=[File_name, 'spindle_channel_number_', num2str(iLFP_spindles), '_region_', Location_intan(iLFP_spindles), '-v1'];
            save(horzcat(cellfile{:}),'Spin_chan');
            cd(lfp_folder);
        end
    end
end

%% doesnt work
if ~isempty(EMG_channels)
    for iLFP_EMG = 1:numel(lfp_folder)
        % Load the LFP data.
        if EMGix(iLFP_EMG)==1
            fid = fopen(LFPs{iLFP_EMG}, 'r');
            EMG_chan = fread(fid, inf, 'int16');
            fclose(fid);
            EMG= EMG *gain;
            cd(postprocess_folder);
            cellfile=[File_name, 'EMG_channel_number_', num2str(iLFP_EMG), '_region_', Location_intan(iLFP_EMG), '-v1'];
            save(horzcat(cellfile{:}),'EMG_chan');
            cd(lfp_folder);
        end
    end
end


cd .


%% Find the EMG electrodes
% (use the fissure only for theta/delta ratio)
spind_channels = [];
spind_channels = strcmp(channels,'EMG');
EMG_chans = logical(spind_channels);
spind_channels = LFP_files(EMG_chans);
spind_channels(:,2) = channels(EMG_chans);

if ~isempty(spind_channels)
    
    for iLFP_EMG = 1:Rows(spind_channels)
        if resave_ds_files == 0
            
            cd(Summary_directory); load([EMG_File_name 'EMG_channel_number_' num2str(iLFP_EMG)]); cd(lfp_folder);
        elseif resave_ds_files == 1
            
            cd(lfp_folder)
            spind_channels{Rows(spind_channels),6} = [];
            fid = fopen(spind_channels{iLFP_EMG}, 'r');
            spind_channels{iLFP_EMG,3} = fread(fid, inf, 'int16');
            fclose(fid);
            spind_channels{iLFP_EMG,3} = spind_channels{iLFP_EMG,3}*gain;
            spind_channels{iLFP_EMG,4} = decimate(double(spind_channels{iLFP_EMG,3}),PP_sr/sr);
            [spind_channels{iLFP_EMG,5},~] = emg_filter_wiegand(spind_channels{iLFP_EMG,4},sr);
            
            %% Integrate over 3s windows
            b = (1/sr)*ones(1,sr);
            a = 1;
            spind_channels{iLFP_EMG,6} = filter(b, a, spind_channels{iLFP_EMG,5});
            
            cd(Summary_directory); save([EMG_File_name 'EMG_channel_number_' num2str(iLFP_EMG)],'EMG_channels','-v7.3'); cd(lfp_folder);
        end
    end
end
%     cd(postprocess_folder); save([EMG_File_name 'EMG_channels'],'EMG_channels'); cd(lfp_folder);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INERTIAL MEASUREMENT
% Find the AUX channels

% sampled at 20kHz
cd(root_folder)
AUX_channels = [];
AUX_files = find_files('*aux*AUX*');

% GRAVITY_BIAS(1) = 47700; %Animal X zero-g bias
% GRAVITY_BIAS(2) = 55100; %Animal Y zero-g bias
% GRAVITY_BIAS(3) = 44900; %Animal Z zero-g bias
%
% SENSITIVITY(1) = -9200; %Animal X sensitivity
% SENSITIVITY(2) = 1850; %Animal Y sensitivity
% SENSITIVITY(3) = 8270; %Animal Z sensitivity

for iAux = 1:length(AUX_files)
    if resave_ds_files == 0
        cd(Summary_directory); load([AUX_File_name 'AUX_channel_number_' num2str(iAux)]); cd(root_folder);
    elseif resave_ds_files == 1
        cd(root_folder)
        AUX_channels{iAux,1} = AUX_files{iAux};
        AUX_channels{iAux,2} = INTAN_Read_AUX_file(AUX_files{iAux});
        AUX_channels{iAux,2} = decimate(double(AUX_channels{iAux,2}),20000/sr); %downsample
        AUX_channels{iAux,3} = AUX_channels{iAux,2}*37.4e-6; %first conversion turns it into volts (.1-2.45V)
        AUX_channels{iAux,3} = AUX_channels{iAux,3}/.3468; %this converts it into g's (where 1g = 9.81m/s^2)
        AUX_channels{iAux,3} = AUX_channels{iAux,3}*9.81; %turns this into m/s^2
        %%%%%%%
        %try either hi-pass filter or detrend with change points
        %     AUX_channels{iAux,3} = AUX_channels{iAux,3}-mean(AUX_channels{iAux,3}); % to get rid of gravitational bias and drift
        %     AUX_channels{iAux,4} = abs(AUX_channels{iAux,3});
        %     AUX_channels{iAux,5} = SmoothVector(AUX_channels{iAux,4},sr/4);
        %%%%%%%
        AUX_channels{iAux,4} = [nan; diff(AUX_channels{iAux,3})]; %it is now in m/s^3
        AUX_channels{iAux,6} = abs(AUX_channels{iAux,4}); %units = jerk, or |m/s^3|
        
        %     current_save = AUX_channels(iAux,2);
        cd(Summary_directory); save([AUX_File_name 'AUX_channel_number_' num2str(iAux)],'AUX_channels','-v7.3'); cd(root_folder);
    end
end

% Y = detrend(AUX_channels{1,3},'linear',BP);

% cd(postprocess_folder); save([File_name 'AUX_channels'],'AUX_channels'); cd(root_folder);
%         AUX_channel_sum = nansum([AUX_channels{1,5}'; AUX_channels{2,5}'; AUX_channels{3,5}'])==3;
AUX_channel_sum = nansum([AUX_channels{:,6}],2);

% if sum(AUX_channel_sum) == 0
CHECK_ZERO_AUX = [CHECK_ZERO_AUX; {iMice_folders iDay_folders sum(AUX_channel_sum)}]
% end

% figure; plot(nansum([AUX_channels{:,6}],2)); savefig('AUX_channel_sum'); close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GET EPOCH TIMES
% Load the Excel sheet
% To account for freezing and fuzzing out:
% pick out times for pre-sleep and post-sleep, assign those to a fake
% channel (and make that into a logical channel)

cd([Working_directory '\' Mice_folders{iMice_folders}]); %navigate to the folder
%% Load Epoch times Excel sheet
Epoch_times = find_files('*Epoch*');

    Epoch_times_xcel = find_files('*Epoch*');
    [~,~,raw_epochs] = xlsread(Epoch_times_xcel{1});

    
    day_epochs = raw_epochs(iDay_folders+1,:);
    pre_sleep = day_epochs{5}-day_epochs{4};
    pre_hours = str2num(datestr(pre_sleep,'HH'));
    pre_minutes = str2num(datestr(pre_sleep,'MM'));
    pre_sleep_length = ((pre_hours*60*60)+(pre_minutes*60))*sr; %in samples
    
    post_sleep = day_epochs{14}-day_epochs{13};
    post_hours = str2num(datestr(post_sleep,'HH'));
    post_minutes = str2num(datestr(post_sleep,'MM'));
    post_sleep_length = ((post_hours*60*60)+(post_minutes*60))*sr; %in samples
    
    Epochs = ones(1,length(AUX_channel_sum))*2;
    Epochs(1:pre_sleep_length) = 1;
    Epochs(end-post_sleep_length:end) = 3;
    %
    %     Epochs_oSR = ones(1,length(AUX_channel_sum))*2;
    %     Epochs_oSR(1:pre_sleep_length) = 1;
    %     Epochs_oSR(end-post_sleep_length:end) = 3;
    
    sleep_epochs = Epochs == 1 | Epochs == 3;
    
    cd(Summary_directory);
    for iEpoch_day = [2:6]
        Epoch_timez = [raw_epochs(1,:); raw_epochs(iEpoch_day,:)];
        for iRaw_Epochs = [4 5 7:14]
            Epoch_timez(2,iRaw_Epochs) = cellfun(@(x) str2num(datestr(x,'HH'))*60*60+str2num(datestr(x,'MM'))*60,raw_epochs(iEpoch_day,iRaw_Epochs),'UniformOutput',false);
        end
        Epochs_file_name = ['Condition_' num2str(iCondition) '_Mouse_' num2str(iMice_folders) '_Day_' num2str(iEpoch_day-1) '_epoch_times'];
        if resave_ds_files == 1
            save(Epochs_file_name,'Epoch_timez','-v7.3');
        end
    end
    
elseif isempty(Epoch_times)
    warning('Epoch times not found!!')
    Epochs = nan(1,length(AUX_channel_sum));
end