
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIND_SLEEP_PERIODS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND ALL OVERLAPS IN THESE SLEEP MEASURES

cd(postprocess_folder)

smooth_IMU = AUX_channel_sum;

%% Because there's so much variance in the EMG voltages,
% I first find putative sleep times with the IMU and sleep_epochs if available (add POS when possible)
if ~isempty(Epoch_times)
    SLEEP_IX = smooth_IMU < 5 & sleep_epochs' == 1;
else
    SLEEP_IX = smooth_IMU < 5;
end

for iLFP_EMG = 1:Rows(EMG_channels)
    EMG_channels{iLFP_EMG,7} = abs(EMG_channels{iLFP_EMG,6}) < (3*nanstd(EMG_channels{iLFP_EMG,6}(SLEEP_IX))+nanmean(EMG_channels{iLFP_EMG,6}(SLEEP_IX)));
end

EMG_sum = sum(horzcat(EMG_channels{:,7}),2) == Rows(EMG_channels);

if ~isempty(Epoch_times)
    SLEEP_IX = smooth_IMU < 5 & EMG_sum == 1 & sleep_epochs' == 1;
else
    SLEEP_IX = smooth_IMU < 5 & EMG_sum == 1;
end

WAKE_IX = 1-SLEEP_IX; %this is because find_intervals works better when finding stuff above a certain threshold rather than below

%% find_intervals
%if you want to use find_intervals, it's more for finding times "ABOVE" the threshold
%so you need to use this for detecting "wake periods" and then use the below times
wake_thresh = .9;
wake_min_duration = sr*1; %Minimum of 1 seconds of constant moving
wake_minimum_inter_interval_period = sr*60*1; %sr*1; %1s in 200Hz to scratch self, etc. %%THIS CONFUSES ME??!

[wake_above_times, wake_below_times] = find_intervals(WAKE_IX, wake_thresh, [],...
    wake_min_duration, wake_minimum_inter_interval_period);

sleep_above_times = wake_below_times;

% sleep_lengths = sleep_above_times(:,2)-sleep_above_times(:,1);
% sleep_above_times = sleep_above_times(sleep_lengths>sr*

%% Convert SLEEP_IX into something that represents the find_intervals function now
SLEEP_IX = zeros(length(SLEEP_IX),1);
for iConvert = 1:Rows(sleep_above_times)
    SLEEP_IX(sleep_above_times(iConvert,1):sleep_above_times(iConvert,2)) = 1;
end

save('SLEEP_IX','SLEEP_IX');    save('Sleep_above_times','sleep_above_times');
