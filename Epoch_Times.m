function [EPOCHS]=Epoch_Times(root_folder,Epoch_times)

cd(root_folder)
%Epoch_Times should be the excelfile with the times in it
% requires that you have LFP_t_sec and that you have completed epoch times
% sheet

 epochs=readtable(Epoch_times);

%     Epoch_times_xcel = find_files('*Epoch*');
%     [~,~,raw_epochs] = xlsread(Epoch_times_xcel{1});
%     %below is the very annoying way I am going about finding the Day
    dets=strsplit(root_folder,'\'); 
    dets2=strsplit(dets{5},'_');
    for idet=1:length(dets2)
        if strfind(dets2{idet},'Day')
            Daynum= dets2{idet}(end);
        end
    end
  
%   epochs.RecordingDay=num2str(epochs.RecordingDay);
  for iday=1:Rows(epochs.RecordingDay)
        
      if isequal(epochs.RecordingDay(iday),str2double(Daynum))
          PreSleep_mins=epochs.Presleep_Minutes(iday);
          Task_mins=epochs.Task_Minutes(iday);
          PostSleep_mins=epochs.POSTSleep_Minutes(iday);
          Date=epochs.Date(iday);
          Type=epochs.TypeRecording(iday);
      end
  end
  
    EPOCHS.PreSleepMins=PreSleep_mins;
    EPOCHS.PostSleepMins=PostSleep_mins;
    EPOCHS.Task_Mins=Task_mins;
    EPOCHS.Day=Daynum;
    EPOCHS.Date=Date;
    EPOCHS.RecordingType=Type;
 
load('LFP_t_sec.mat')
end_PREsleep_t_sec= LFP_t_sec(1)+(EPOCHS.PreSleepMins*60);
end_POSTsleep_t_sec= LFP_t_sec(end)-(EPOCHS.PostSleepMins*60);

EPOCHS.PREsleep_t_sec=end_PREsleep_t_sec;
EPOCHS.POSTsleep_t_sec=end_POSTsleep_t_sec;
    
    save('EPOCHS','EPOCHS')
    %also check the date with the file name date to double check
    
    %% BELOW IS JPs code
    %% Load Epoch times Excel sheet
% Epoch_times = find_files('*Epoch*');
% if ~isempty(Epoch_times)
%     cd([Working_directory '\' Mice_folders{iMice_folders} '\' Epoch_times{1}])
%     Epoch_times_xcel = find_files('*Epoch*');
%     [~,~,raw_epochs] = xlsread(Epoch_times_xcel{1});
%     if Cols(raw_epochs) < 10
%         Epoch_times = [];
%     end
%     
%     day_epochs = raw_epochs(iDay_folders+1,:);
%     pre_sleep = day_epochs{5}-day_epochs{4};
%     pre_hours = str2num(datestr(pre_sleep,'HH'));
%     pre_minutes = str2num(datestr(pre_sleep,'MM'));
%     pre_sleep_length = ((pre_hours*60*60)+(pre_minutes*60))*sr; %in samples
%     
%     post_sleep = day_epochs{14}-day_epochs{13};
%     post_hours = str2num(datestr(post_sleep,'HH'));
%     post_minutes = str2num(datestr(post_sleep,'MM'));
%     post_sleep_length = ((post_hours*60*60)+(post_minutes*60))*sr; %in samples
%     
%     Epochs = ones(1,length(AUX_channel_sum))*2;
%     Epochs(1:pre_sleep_length) = 1;
%     Epochs(end-post_sleep_length:end) = 3;
%     %
%     %     Epochs_oSR = ones(1,length(AUX_channel_sum))*2;
%     %     Epochs_oSR(1:pre_sleep_length) = 1;
%     %     Epochs_oSR(end-post_sleep_length:end) = 3;
%     
%     sleep_epochs = Epochs == 1 | Epochs == 3;
%     
%     cd(Summary_directory);
%     for iEpoch_day = [2:6]
%         Epoch_timez = [raw_epochs(1,:); raw_epochs(iEpoch_day,:)];
%         for iRaw_Epochs = [4 5 7:14]
%             Epoch_timez(2,iRaw_Epochs) = cellfun(@(x) str2num(datestr(x,'HH'))*60*60+str2num(datestr(x,'MM'))*60,raw_epochs(iEpoch_day,iRaw_Epochs),'UniformOutput',false);
%         end
%         Epochs_file_name = ['Condition_' num2str(iCondition) '_Mouse_' num2str(iMice_folders) '_Day_' num2str(iEpoch_day-1) '_epoch_times'];
%         if resave_ds_files == 1
%             save(Epochs_file_name,'Epoch_timez','-v7.3');
%         end
%     end
%     
% elseif isempty(Epoch_times)
%     warning('Epoch times not found!!')
%     Epochs = nan(1,length(AUX_channel_sum));
% end