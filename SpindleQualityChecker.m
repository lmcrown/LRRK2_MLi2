 plot_it=true;

lowlimit_fq  = 7; %This is in litterature and then later I can say actually i just want 8-14 Hz or so
highlimit_fq = 16;
upperthresh_std=4.5;
lowerthresh_std=1.5;

LRRK2_MLi2_Mouse_Itterator(@LRRK2Mli2_Find_Spindles)

% eeg_chan='*ECoG_Left_Mid*.mat';

[Spindle]=LRRK2Mli2_Find_Spindles(lowerthresh_std, upperthresh_std,lowlimit_fq,highlimit_fq, eeg_chan, plot_it);



%% now need to weed them out- actually I'm gonna make a seperate thing for this
%         %% 2 seconds as an upper duration limit (JP had it as 4)
%         if length(putative_spindle) > 2*LFP.fs_final
%             continue
%         end
%         
%         %% sometimes this filter picks up large transient fluctuations -
%         % to prevent this: dont let the amplitude be crazy
%         if max(putative_spindle) >= 500 ||...
%                 min(putative_spindle) <= -500
%             continue
%         end
%         
%         %% Must have spectral specifity - throwing out greater than 16 and less than 7
%         %    figure;
%         [pxx, frex]=pmtm(putative_spindle(:,2),[],spec_freqs,LFP.fs_final);
%         [pks,ix]=findpeaks(pxx);
%         %     peakpow=max(pks)
%         peakfrex=frex(ix);
%         %maybe something that must be higher than powers around it??
%         
%         if peakfrex >= 15 || peakfrex <= 7
%             continue
%         end
%         
%         %%%%%%%%%%%%%%%% Save all the dets about this bad boy
%         
%         
%         
%         figure
%         plotinterval=ECOG(:,1)> spin_above_times(ispin,1)-1 & ECOG(:,1)<spin_above_times(ispin,2)+1;
%         
%         subplot(3,1,1)
%         yyaxis left
%         plot(ECOG(plotinterval,1),ECOG(plotinterval,2),'k')
%         hold on
%         plot(ECOG(plotinterval,1),filt_sig(plotinterval),'b')
%         vline(min(ECOG(spinintervalIX,1)))
%         vline(max(ECOG(spinintervalIX,1)))
%         axis tight
%         
%         yyaxis right
%         plot(smoothed_power(plotinterval,1),smoothed_power(plotinterval,2),'r')  % now 1= 1 second and this should be easy to estimate Hz from
%         
%         refline(0,lower_spin_thresh)
%         refline(0,upper_spin_thresh)
%         
%         ylabel('uV')
%         xlabel('Time(s)')
%         title(sprintf('Duration %2.2f secs',spinlength))
%         
%         subplot(3,1,2)
%         Spectrogram_spindle_LC(ECOG(plotinterval,2), LFP.fs_final, 3:0.2:20, 'wavelet');
%         
%         subplot(3,1,3)
%         %         findpeaks(pmtm(ECOG(spinintervalIX,2),[],spec_freqs,LFP.fs_final))
%         findpeaks(pmtm(ECOG(spinintervalIX,2),[],4:20,LFP.fs_final))
%     end
%     
%     
%     
%     %% how do I want to go about saving these?
% end
% %%
% %     extracted_spindles{iSpindle_channels, 2}.cut_times_ms = [extracted_spindles{iSpindle_channels,2}.cut_times_ms; {cut_times_ms'}];
% %     extracted_spindles{iSpindle_channels, 2}.cut_raw_sig = [extracted_spindles{iSpindle_channels,2}.cut_raw_sig; {cut_raw_sig}];
% %     extracted_spindles{iSpindle_channels, 2}.cut_filt_sig = [extracted_spindles{iSpindle_channels, 2}.cut_filt_sig; {cut_filt_sig}];
% %
% %     %%%%%%%%%%%%%%%%%
% %     raw_sig = spindle_channels{iSpindle_channels,3}(spin_above_times(iSee,1)-side_times:spin_above_times(iSee,2)+side_times);
% %     raw_lengthy_times = LFP_t_sec(spin_above_times(iSee,1)-side_times:spin_above_times(iSee,2)+side_times);
% %     raw_times_ms = (raw_lengthy_times-raw_lengthy_times(1))*1000; %ms
% %     raw_filt_sig = spindle_channels{iSpindle_channels,4}(spin_above_times(iSee,1)-side_times:spin_above_times(iSee,2)+side_times);
% 
% %%
% %     extracted_spindles{iSpindle_channels, 2}.raw_times_ms = [extracted_spindles{iSpindle_channels,2}.raw_times_ms; {raw_times_ms'}];
% %     extracted_spindles{iSpindle_channels, 2}.raw_sig = [extracted_spindles{iSpindle_channels,2}.raw_sig; {raw_sig}];
% %     extracted_spindles{iSpindle_channels, 2}.raw_filt_sig = [extracted_spindles{iSpindle_channels, 2}.raw_filt_sig; {raw_filt_sig}];
% %
% %     %%%%%%%%%%%%%%%%%
% %     start_time_ms = LFP_t_sec(spin_above_times(iSee,1))*1000;
% %     end_time_ms = LFP_t_sec(spin_above_times(iSee,2))*1000;
% %
% %     if isempty(Epoch_times)
% %         spindle_epoch = nan;
% %     else
% %         spindle_epoch = mode(Epochs(spin_above_times(iSee,1):spin_above_times(iSee,2)));
% %     end
% %
% %     extracted_spindles{iSpindle_channels, 2}.start_time_ms = [extracted_spindles{iSpindle_channels, 2}.start_time_ms; start_time_ms];
% %     extracted_spindles{iSpindle_channels, 2}.end_time_ms = [extracted_spindles{iSpindle_channels, 2}.end_time_ms; end_time_ms];
% %     extracted_spindles{iSpindle_channels, 2}.spindle_epoch = [extracted_spindles{iSpindle_channels, 2}.spindle_epoch; spindle_epoch];
% %     %%%%%%%%%%%%%%%%%
% %     % identify pre or post sleep here
% % end