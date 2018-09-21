function INTAN_Post_Process_LRRK2_MLi2_LC_nodins(plot_it)

if nargin<1
    plot_it=true;
end
%%
root_folder=pwd;
f=find_files('*.rhd*');
 IF = INTAN_Read_RHD_file_LC('info.rhd'); %IF will contain meta data on the Intan session
%going to need the below function to get info data

% [IF]=INTAN_Read_RHD2000_file(f{1});
%IF now has data that you could likely gleen later on, different but
%similar to before
fs_initial = IF.frequency_parameters.amplifier_sample_rate;
bit2uV= IF.bit_to_uvolt_conversion; % i dont see this listed so you might have to hardcode it hear
%  bit2uV= 0.195; %looked it up/sounds right
% fs_initial=12500; This is the default but you should always have it check
fs_final=1000; %pick what you want it to be for the LFP
emgfs=1000; %What you choose to make the EMG - EMG filter wiegand filters between 70 and 249
decimation_factor_LFP=ceil(fs_initial/fs_final);
decimation_factor_EMG=ceil(fs_initial/emgfs);
%check for stuff that you will need- you have to move all of these into the
%intan folder before you run this

%  if (isempty(dir('board-DIN-08.dat')) | isempty(dir('board-DIN-09.dat')) | isempty(dir('board-DIN-10.dat'))) ==1
%      
% end


%going to need to set it up so that you can just say ok I dont get position
%data- lets move on

% assert(~isempty(dir('*.pos')),'no pos file')
% assert(~isempty(dir('info.rhd')),'no rhd file')

assert(~isempty(dir('CTT*.xlsx')),'need channel tranlation table')
chantrans=dir('CTT*.xlsx');
EVT = [];
%% LOAD THE CHANNEL TRANSLATION TABLE
CTT=LOAD_chan_trans_table_MLi2(chantrans.name);
[CTT]=check_impedance(IF, CTT);
ix=~isundefined(CTT.MouseNum); %to solve the undefined problem that will come up later if you have 3 mice instead of 4
CTT=CTT(ix,:);
save('CTT','CTT');%emily wrote this- checks impedance, adds to CTT then gives logical for if its a good channel
%% POSITION DATA
% d = dir('*.pos');
% if isempty(d)
%     error('Could not find position file')
% else
%     pos_file = d(1).name;
% end
% pos_frame_times_intan_file = 'board-DIN-09.dat';
% unique_code_pos_intan_file = 'board-DIN-08.dat';
% strobe_pos_intan_file = 'board-DIN-10.dat';
% 
% %position sync times
% if ~exist('EVT.mat')
%     EVT.intan_pos_frame_recids = INTAN_Extract_Transitions( pos_frame_times_intan_file ); fprintf('.');
%     EVT.intan_pos_unique_code_recids = INTAN_Extract_Transitions( unique_code_pos_intan_file ); fprintf('.');
%     EVT.intan_pos_clock_recids = INTAN_Extract_Transitions( strobe_pos_intan_file ); fprintf('.');
%     
%     save('EVT.mat','EVT');
% else
%     load('EVT.mat')
% end
% 
% try
%     % Allied Vision Tech for the Manta Camera.
%     [~,POS] = AVT_Process_Tracking_Log_4_animals(pos_file, EVT.intan_pos_frame_recids./fs_initial);
%     
%     % Calculate running speed from the pos data.
%     SPEED = nan(Rows(POS),4);
%     pixpercm = 5.88; %pixels per cm in box- measured by Emily
%     for iMouse = 1:4
%         try
%             newPOS = POS(:,[end 2*(iMouse-1)+1 2*(iMouse-1)+2]);  %time, x coordinate, y coordinate
%             SPEED(:,iMouse) = Speed_from_xy(newPOS(:,1:3),19, pixpercm); %this should now give cm per second, the x axis should be seconds
%         catch
%             disp('nans present in the data')
%         end
%     end
% %     SPEED=smoothdata(SPEED,'movmean',50); %smooth data with moving average
%     SPEED(:,5)= POS(:,9); %adding time in seconds to speed datasave(fullfile(pwd,'POS.mat'),'POS','SPEED');
% catch
%     disp('May be weird number of animals so the POS doesn''t work- this must be fixed');
% end

%% LOAD INTAN TIME FILE

if ~exist('LFP_t_sec.mat')
    LFP_t_sec = INTAN_Load_Time('time.dat'); %JP says this could act funny if for some reason the number of samples is different between mice (can happen)
    %might want to make sure same length as non-downsampled LFP
    save('LFP_t_sec','LFP_t_sec');
end
load('LFP_t_sec.mat')

%% Make unique mouse folders and divide and save individual POS and speed data into them

Mice=unique(CTT.MouseNum);
goodMiceIX=~isundefined(Mice); %if the CTT doesn't have entries for every row for mouse name it will have "undefiend" as a unique entry that will crash the program later at makedir
 Mice=Mice(goodMiceIX);
directory=strsplit(pwd,'\');
dets=strsplit(directory{5},'_');
for ielement=1:length(dets)
    if  strfind(dets{ielement},'Day')
        day=dets{ielement};
    end
end
%POS col is specific to box- make sure you have this assigned to correct
%mouse, this was a problem before because if file name wasn't in box order
%you lost correct pos and speed order- became issue when blinding was a
%thing
% BOXA=[POS(:,1) POS(:,2) POS(:,9)];
% BOXB=[POS(:,3) POS(:,4) POS(:,9)];
% BOXC=[POS(:,5) POS(:,6) POS(:,9)];
% BOXD=[POS(:,7) POS(:,8) POS(:,9)];
% 
% [~,ia]=unique(char(CTT.MouseNum),'first','rows');

for imouse= 1:numel(Mice)
    name=[char(Mice(imouse)) day];
    if ~exist(name,'dir')
        mkdir(name)
    end
    
%     for iindex=1:numel(ia)
%         if   isundefined( CTT.MouseNum(ia(iindex)))==1 %trying to deal with fact that if there is no mouse in a box its all nans and the name will be undefiend
%             disp('thinking there are less than 4 mice')
%             continue %is this the right thing to do?
%         end

%         if Mice(imouse)==CTT.MouseNum(ia(iindex))
%             MouseBox=CTT.Port(ia(iindex));
%         end
%         Speed_specific(:,1)=SPEED(:,5);
%         if char(MouseBox)=='A'
%             POS_specific= BOXA;
%             Speed_specific(:,2)=SPEED(:,1);
%         end
%         if char(MouseBox)=='B'
%             POS_specific= BOXB;
%             Speed_specific(:,2)=SPEED(:,2);
%         end
%         if char(MouseBox)=='C'
%             POS_specific= BOXC;
%             Speed_specific(:,2)=SPEED(:,3);
%         end
%         if char(MouseBox)=='D'
%             POS_specific= BOXD;
%             Speed_specific(:,2)=SPEED(:,4);
%         end
%        
%         %         namespecific=['POS_' name];
%         save(fullfile([pwd '/' name],['POS_' name '.mat']),'POS_specific');
%         save(fullfile([pwd '/' name],['SPEED_' name '.mat']),'Speed_specific');
%     end
    
end
%% gather the EMG/LFP data, downsample and save with name of region in individual mouse folder
%7/10/2018 fixed this because was saving the same file (i think) over and
%over- correlations were the same on stuff,now its more concise and not the
%case!
EMG_time_decimated=single(decimate(LFP_t_sec,decimation_factor_EMG)); %decimate the time to paste on to LFP and EMG
LFP_time_decimated=single(decimate(LFP_t_sec,decimation_factor_LFP)); %decimate the time to paste on to LFP and EMG

for irow=1:Rows(CTT)
    if (CTT.IsEMG(irow)==1 || CTT.IsLFP(irow)==1) && CTT.ImpGood(irow)==1
        file=[];
        newname=[];
        if CTT.IntanHSPin_(irow)<10
            original_filename =sprintf('amp-%s-00%d.dat',CTT.Port(irow), CTT.IntanHSPin_(irow)); % Get the name of the file to locate in dir
        else
            original_filename =sprintf('amp-%s-0%d.dat',CTT.Port(irow), CTT.IntanHSPin_(irow));
        end
        chan_name=strsplit(original_filename, '.');
        chan_name=chan_name{1}(end-4:end);
        file=strcat(pwd,'\', original_filename); %full path of the file
        name=strcat(char(CTT.MouseNum(irow)),day);
        newname = sprintf('%s/%s-%s-%d-%s.mat', name, CTT.MouseNum(irow), CTT.Region{irow}, CTT.IntanCh(irow),day); %moved this up here, so will generate for every iteration but should only actually save for below conditions

        if CTT.IsEMG(irow)==1 && ~exist(fullfile(root_folder,newname))
            EMG= INTAN_Read_DAT_file(file, decimation_factor_EMG);
            EMG_uV(:,2)=single(EMG*bit2uV);
            EMG_uV(:,1)=EMG_time_decimated;
            save(fullfile([pwd '/' newname]),'EMG_uV','original_filename', 'fs_initial', 'decimation_factor_EMG', 'emgfs')
            fprintf('%s saved \n',newname)
        end
        
        if CTT.IsLFP(irow)==1 && ~exist(fullfile(root_folder,newname))
            LFP= INTAN_Read_DAT_file(file, decimation_factor_LFP);
            LFP_uV(:,2)=single(LFP*bit2uV);
            LFP_uV(:,1)=LFP_time_decimated;
            save(fullfile([pwd '/' newname]),'LFP_uV','original_filename', 'fs_initial', 'decimation_factor_LFP', 'fs_final')
            fprintf('%s saved \n',newname)
        end
    end
end


%% GET SLEEP TIMES- EPOCH TIMES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%need to take data form the excel file and turn it into LFP timepoints such
%that lines can be drawn on plots and epoch times can be defined
cd(root_folder)
Epoch_times = char(find_files('*EpochTimes*'));
EPOCHS=Epoch_Times(root_folder,Epoch_times);
save('EPOCHS','EPOCHS')
%note: this crashes if the file is open because there will be 2 copies of
%Epoch times, one with a $ that is the open one

% SAVE THE FILES TO INDIVIDUAL MOUSE FOLDERS

ffiles=find_files('*Day*');
for ifile=1:length(ffiles)
    if isdir(ffiles{ifile})==1 %i want to say if its a directory
        cd(ffiles{ifile})
        save('EPOCHS','EPOCHS')
        cd ..
    end
end
cd(root_folder)

%% MOVEMENT DATA- IMU

cd(root_folder)
possibleports=char(unique(CTT.Port));
AUX_files = find_files('*aux*AUX*');
for iport=1:length(possibleports)
    AUXs=[];
    jerk=[];
    %possible ports iport
    Auxmouse=dir(sprintf('aux-%s-AUX*.dat',possibleports(iport)));
    for iAUX=1:length(Auxmouse)
        auxnum=str2double(Auxmouse(iAUX).name(10));
        AUX= INTAN_Read_AUX_file(Auxmouse(iAUX).name);
        AUXs(:,auxnum+1)=single(decimate(AUX,ceil(fs_initial/fs_final))); %decimated X Y Z values
        AUXs(:,1)=decimate(LFP_t_sec,ceil(fs_initial/fs_final));  %decimated time
        turn2jerk=AUXs(:,auxnum+1)*37.4e-6 ; %from JPs- this turns to volts
        turn2jerk=turn2jerk/.3468; %supposidly turns it into gs
        turn2jerk=turn2jerk *9.81; %make it into m/s2
        jerk(:,auxnum+1)=abs(diff(turn2jerk))'; %now theoretically in units of m/s3 aka jerk
        jerk(:,1)=AUXs(1:end-1,1); %time, has to be -1 because its a diff
        
    end
    jerk(:,5)=jerk(:,2)+jerk(:,3)+jerk(:,4); %now you have the summed jerk like JP did
    %possible smooth this in the way that the speed data was smoothed?
    
%     if   ~isundefined(unique(CTT.MouseNum(CTT.Port==possibleports(iport))))%trying to deal with fact that if there is no mouse in a box its all nans and the name will be undefiend
        % just added this because when there isn't a mouse it comes up
        % undefined and then crashes here 8/6/2018
        mouse=char(unique(CTT.MouseNum(CTT.Port==possibleports(iport))));
        mousefold=[mouse day];
        save(fullfile([pwd '/' mousefold '/' 'AUXs_downsamp_port' possibleports(iport)]),'AUXs')
        save(fullfile([pwd '/' mousefold '/' 'jerk_port' possibleports(iport)]),'jerk')
        fprintf('.%d',auxnum)
%     end
    %jerk will still have a value becaues the aux is still be recorded from
    %the headstage that is just handing there unconnected- so its fine it
    %still calculates, i just wont save it- obvuously would be more
    %efficient to insated of looping through all ports to just have it
    %reference the CTT
end

%% EMG filter
Mice=unique(CTT.MouseNum);
goodMiceIX=~isundefined(Mice); %if the CTT doesn't have entries for every row for mouse name it will have "undefiend" as a unique entry that will crash the program later at makedir
 Mice=Mice(goodMiceIX);
directory=strsplit(pwd,'\');
dets=strsplit(directory{5},'_');
for ielement=1:length(dets)
    if  strfind(dets{ielement},'Day')
        day=dets{ielement};
    end
end

cd(root_folder)

for ifold=1:numel(Mice)
    fname=[char(Mice(ifold)) day];
    Mouse_folder=fullfile([pwd '/' fname]);
    cd(Mouse_folder)
    ffile=find_files('*EMG_*');
    filteredEMGs=[];
    for iEMG=1:length(ffile)
        EMG_tofilt=load(ffile{iEMG});
        filteredEMGs(:,1)=EMG_tofilt.EMG_uV(:,1);
%         [amp_filt_sig, ~] = emg_filter_wiegand(double(EMG_tofilt.EMG_uV(:,2)),emgfs);
       [amp_filt_sig]= emg_filter_wsmoothing(double(EMG_tofilt.EMG_uV(:,2)), emgfs); %filters, envelope
       filteredEMGs(:,iEMG+1)=amp_filt_sig;
    end
    save('filteredEMGs','filteredEMGs');
    cd ..
end

%% DRUG INFORMATION
drugs=table('Size',[numel(Mice) 2],'VariableTypes', {'categorical','logical'});
drugs.Properties.VariableNames={'Mouse','GotDrug'};

[C,ia]=unique(char(CTT.MouseNum),'first','rows');

drugs(:,1)=table(CTT.MouseNum(ia));
drugs(:,2)=table(CTT.GotDrug(ia));

%% Make Session_Info file
cd(root_folder)

Session_Info.date= EPOCHS.Date;
Session_Info.Recordingday=day;
Session_Info.RecordingType=EPOCHS.RecordingType;
Session_Info.CTT= CTT;
Session_Info.drugs= drugs; %I want to get this info
%i probably also want cohort number
save('Session_Info','Session_Info')
for ifold=1:numel(Mice)
    fname=[char(Mice(ifold)) day];
    Mouse_folder=fullfile([pwd '/' fname]);
    cd(Mouse_folder)
    save('Session_Info','Session_Info')
    cd ..
end
%SAVE THIS INTO INDIVIDUAL MOUSE FOLDER
%%  PLOT LFP data
%This needs to be fixed
% cd(root_folder)
% if plot_it==true
%     
%     check_position %shows position data in boxes to be sure camera didnt cut anything off
%     
%     summaryplots_ECoG(root_folder)  
%     
% %     summaryplots_position(true, root_folder)
% end

%%
% cd(root_folder)
% fdirs=dir('*Day*')
% for idir=1:length(fdirs)
%     if fdirs(idir).isdir==1
%         