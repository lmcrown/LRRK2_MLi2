function [smooth_IMU]= IMU(aux_files,times,fs_initial,fs_final)
%assumes you moved aux files into appropriate mouse folder

%% INERTIAL MEASUREMENT
% Find the AUX channels

AUX_files = find_files('*aux*AUX*');

        
            % GRAVITY_BIAS(1) = 47700; %Animal X zero-g bias
            % GRAVITY_BIAS(2) = 55100; %Animal Y zero-g bias
            % GRAVITY_BIAS(3) = 44900; %Animal Z zero-g bias
            %
            % SENSITIVITY(1) = -9200; %Animal X sensitivity
            % SENSITIVITY(2) = 1850; %Animal Y sensitivity
            % SENSITIVITY(3) = 8270; %Animal Z sensitivity
           
            for iAux = 1:length(AUX_files)
                %     if resave_ds_files == 0
                %         cd(Summary_directory);
               AUX= INTAN_Read_AUX_file(AUX_files{iAux});
               AUXs(:,iAux+1)=decimate(AUX,ceil(fs_initial/fs_final)); %decimated X Y Z values
               AUXs(:,1)=decimate(times,ceil(fs_initial/fs_final));  %decimated time
            end
            
            %now you have a 4 col matrix with T X Y Z
            %check by plotting
            figure;
            subplot(3,2,1)
            plot(AUXs(:,1),AUXs(:,2))
            ylabel('X')
            subplot(3,2,3)
            plot(AUXs(:,1),AUXs(:,3))
            ylabel('Y')
            subplot(3,2,5)
            plot(AUXs(:,1),AUXs(:,4))
            ylabel('Z')
            xlabel('Time')
      %%
                %         cd(root_folder);
                %     elseif resave_ds_files == 1
                cd(root_folder)
                AUX_channels{iAux,1} = AUX_files{iAux);
                AUX_channels{iAux,2} = INTAN_Read_AUX_file(AUX_files{iAux});
                AUX_channels{iAux,2} = decimate(double(AUX_channels{iAux,2}),ceil(fs_initial/fs_final)); %downsample
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
                AUX_channels{iAux,6} = abs(AUX_channels{iAux,4});
                %units = jerk, or |m/s^3| %%% this is the number to give a crap about
                
                %     current_save = AUX_channels(iAux,2);
                cd(Summary_directory); save([AUX_File_name 'AUX_channel_number_' num2str(iAux)],'AUX_channels','-v7.3'); cd(root_folder);
            end
        end
        
        % Y = detrend(AUX_channels{1,3},'linear',BP);
        
        % cd(postprocess_folder); save([File_name 'AUX_channels'],'AUX_channels'); cd(root_folder);
        %         AUX_channel_sum = nansum([AUX_channels{1,5}'; AUX_channels{2,5}'; AUX_channels{3,5}'])==3;
        AUX_channel_sum = nansum([AUX_channels{:,6}],2);
        
        % if sum(AUX_channel_sum) == 0
        CHECK_ZERO_AUX = [CHECK_ZERO_AUX; {iMice_folders iDay_folders sum(AUX_channel_sum)}];
    end
