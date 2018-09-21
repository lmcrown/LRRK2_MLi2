function [extracted_spindles] = Extract_Events_Wiegand(times,EEG_channels, restrict_times, lo_freq, hi_freq, sr)

%times should be in seconds
%signal should be in uV

%make a little sanity check for the length
%make a times file?
% times=(1:length(LFP_uV))./fs_final;

LFP_t_sec = times; 
spindle_channels = [];
spindle_channels{1,3} = EEG_channels;

% [spindle_channels{1,6}, spindle_channels{1,4}] = filter_wiegand(EEG_channels,lo_freq,hi_freq,sr); %filtered to spindle band
[spindle_channels{1,6}, spindle_channels{1,4}] = filter_wiegand(EEG_channels,lo_freq,hi_freq,sr); %filtered to spindle band

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Then use the temporal component to pick out putative spindles

spin_min_duration = sr*1; %.4s, in samples, at 200Hz %but at 6 cycles for 12hz, it's roughly 500ms
%spin_max_duration = 4000; %2s %maybe do this post-hoc
spin_minimum_inter_interval_period = sr*.05; %300ms
% Values taken from Characterization of Topographically
% Specific Sleep Spindles in Mice by Kim et al. 2014

extracted_spindles = [];

side_times = 2*sr; %number of samples at 2kHz sampling rate to grab on either side of the detected spindle

for iSpindle_channels = 1:Rows(spindle_channels)
    
    extracted_spindles{iSpindle_channels, 1} = spindle_channels(iSpindle_channels,2);
    
    extracted_spindles{iSpindle_channels, 2}.cut_times_ms = [];
    extracted_spindles{iSpindle_channels, 2}.cut_raw_sig = [];
    extracted_spindles{iSpindle_channels, 2}.cut_filt_sig = [];
    
    extracted_spindles{iSpindle_channels, 2}.raw_times_ms = [];
    extracted_spindles{iSpindle_channels, 2}.raw_sig = [];
    extracted_spindles{iSpindle_channels, 2}.raw_filt_sig = [];
    
    extracted_spindles{iSpindle_channels, 2}.start_time_ms = [];
    extracted_spindles{iSpindle_channels, 2}.end_time_ms = [];
    
    if ~isempty(restrict_times)
        %% As moving the mouse between periods created huge artifacts...
        % this restricts the std to JUST SLEEP PERIODS...
        just_sleep_chan = [];
        for iSleep = 1:Rows(sleep_above_times)
            just_sleep_chan = [just_sleep_chan; spindle_channels{iSpindle_channels,6}(sleep_above_times(iSleep,1):sleep_above_times(iSleep,2))];
        end
        mean_chan = nanmean(just_sleep_chan);
        std_chan = nanstd(just_sleep_chan);
        
    else
        mean_chan = nanmean(spindle_channels{1,6});
        std_chan = nanstd(spindle_channels{1,6});
        
        sleep_above_times = [1 length(EEG_channels)];
        for iSleep_times = 1:Rows(sleep_above_times)
            current_env_chan_sleep_chunk = spindle_channels{iSpindle_channels,6}(sleep_above_times(iSleep_times,1):sleep_above_times(iSleep_times,2));
            current_filt_chan_sleep_chunk = spindle_channels{iSpindle_channels,4}(sleep_above_times(iSleep_times,1):sleep_above_times(iSleep_times,2));
            current_raw_chan_sleep_chunk = spindle_channels{iSpindle_channels,3}(sleep_above_times(iSleep_times,1):sleep_above_times(iSleep_times,2));
            
            %% Thresholding
            lower_spin_thresh = (std_chan*2);
            upper_spin_thresh = (std_chan*6);
            
            %% Our normal way of detecting oscillatory events
            [spin_above_times, ~] = find_intervals(current_env_chan_sleep_chunk, upper_spin_thresh, lower_spin_thresh, ...
                spin_min_duration, spin_minimum_inter_interval_period);
                        
            if isempty(spin_above_times)
                continue
            end
            
            spin_above_times = spin_above_times + sleep_above_times(iSleep_times,1);
            
            %% Sometimes the spindle times hit the end of the recording
            IZ = spin_above_times(:,2)+side_times < length(spindle_channels{1,3});
            spin_above_times = spin_above_times(IZ,:);
            
            for iSee = 1:Rows(spin_above_times)
                
                %% Putative spindle
                putative_spindle = spindle_channels{iSpindle_channels,3}(spin_above_times(iSee,1):spin_above_times(iSee,2));
                
                if (spin_above_times(iSee,1)-side_times) <= 0 %can't occur less than a second into sleep
                    continue
                end
                
                %% 4 seconds as an upper duration limit
                if length(putative_spindle) > 6*sr
                    continue
                end
                
%                 %% sometimes this filter picks up large transient fluctuations -
%                 % to prevent this:
%                 if max(putative_spindle) >= 4000 |...
%                         min(putative_spindle) <= -4000
%                     continue
%                 end
                
%                 % Must have spectral specifity
%                 spec_freqs = linspace(5,25,50);
%                 spectral_spec = 10*log10(pmtm(putative_spindle,[],spec_freqs,sr));
%                 [x, spectral_check] = max(spectral_spec);
%                 spectral_check = spec_freqs(spectral_check);
%                 if spectral_check <= 10 || spectral_check >= 16
%                     continue
%                 else
%                     extracted_spindles{iSpindle_channels,2}.spect = [extracted_spindles{iSpindle_channels,2}.spect; {spectral_spec}];
%                     extracted_spindles{iSpindle_channels,2}.spect_check = [extracted_spindles{iSpindle_channels,2}.spect_check; spectral_check];
%                 end
                
                %%%%%%%%%%%%%%%%
                cut_raw_sig = spindle_channels{iSpindle_channels,3}(spin_above_times(iSee,1):spin_above_times(iSee,2));
                cut_lengthy_times = LFP_t_sec(spin_above_times(iSee,1):spin_above_times(iSee,2));
                cut_times_ms = (cut_lengthy_times-cut_lengthy_times(1))*1000; %ms
                cut_filt_sig = spindle_channels{iSpindle_channels,4}(spin_above_times(iSee,1):spin_above_times(iSee,2));
                
                %%
                extracted_spindles{iSpindle_channels, 2}.cut_times_ms = [extracted_spindles{iSpindle_channels,2}.cut_times_ms; {cut_times_ms'}];
                extracted_spindles{iSpindle_channels, 2}.cut_raw_sig = [extracted_spindles{iSpindle_channels,2}.cut_raw_sig; {cut_raw_sig}];
                extracted_spindles{iSpindle_channels, 2}.cut_filt_sig = [extracted_spindles{iSpindle_channels, 2}.cut_filt_sig; {cut_filt_sig}];
                
                %%%%%%%%%%%%%%%%%
                raw_sig = spindle_channels{iSpindle_channels,3}(spin_above_times(iSee,1)-side_times:spin_above_times(iSee,2)+side_times);
                raw_lengthy_times = LFP_t_sec(spin_above_times(iSee,1)-side_times:spin_above_times(iSee,2)+side_times);
                raw_times_ms = (raw_lengthy_times-raw_lengthy_times(1))*1000; %ms
                raw_filt_sig = spindle_channels{iSpindle_channels,4}(spin_above_times(iSee,1)-side_times:spin_above_times(iSee,2)+side_times);
                
                %%
                extracted_spindles{iSpindle_channels, 2}.raw_times_ms = [extracted_spindles{iSpindle_channels,2}.raw_times_ms; {raw_times_ms'}];
                extracted_spindles{iSpindle_channels, 2}.raw_sig = [extracted_spindles{iSpindle_channels,2}.raw_sig; {raw_sig}];
                extracted_spindles{iSpindle_channels, 2}.raw_filt_sig = [extracted_spindles{iSpindle_channels, 2}.raw_filt_sig; {raw_filt_sig}];
                
                %%%%%%%%%%%%%%%%%
                start_time_ms = LFP_t_sec(spin_above_times(iSee,1))*1000;
                end_time_ms = LFP_t_sec(spin_above_times(iSee,2))*1000;
                                
                extracted_spindles{iSpindle_channels, 2}.start_time_ms = [extracted_spindles{iSpindle_channels, 2}.start_time_ms; start_time_ms];
                extracted_spindles{iSpindle_channels, 2}.end_time_ms = [extracted_spindles{iSpindle_channels, 2}.end_time_ms; end_time_ms];
                %%%%%%%%%%%%%%%%%
            end
        end
    end
end