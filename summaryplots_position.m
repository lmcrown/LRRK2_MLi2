function summaryplots_position(plot_it, root_folder)
%need mouse folders to access and grab information from
%will need EEG, POS data, SPEED data, JERK and EMG, basically assumes all
%post-processing is complete
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
% first check to be sure the folders are there, then open and be sure they
% have the right stuff in there
for imouse=1:numel(Mice)
    assert(isdir([ Mice{imouse} day]),'folder does not exist for one or more mice')
    try cd([Mice{imouse} day])
    catch
        error('probably not postprocessed, cant cd to mouse folder')
    end
    if ~exist('jerk.mat','file')==2
        sprintf('no jerk data for %s',Mice(imouse))
    continue
    end
    cd(root_folder)
end

if plot_it==true
    cd(root_folder)
    
    for ifold=1:numel(Mice)
        cd(root_folder)
        cd([Mice{ifold} day])
        try
            load('AUXs_downsamp.mat')
            figure(ifold*10);
            subplot(3,2,1)
            plot(AUXs(:,1),AUXs(:,2))
            title([Mice{ifold}])
            ylabel('X')
            subplot(3,2,3)
            plot(AUXs(:,1),AUXs(:,3))
            ylabel('Y')
            subplot(3,2,5)
            plot(AUXs(:,1),AUXs(:,4))
            ylabel('Z')
            xlabel('Time')
            
            clear AUXs
            
        catch
            disp('No processed AUX files for this mouse')
        end
        try
            load('E_M_G_time.mat')
            figure(ifold*10);
            subplot(3,2,2)
            plot(newEMG(:,1),newEMG(:,2))
            title('filtered EMG1')
            ylabel('abs uV')
            subplot(3,2,4)
            plot(newEMG(:,1),newEMG(:,3))
            title('filtered EMG2')
            ylabel('abs uV')
            xlabel('Time')
            
        catch
            disp('No processed EMGs')
        end
        
        try
            load(char(find_files('SPEED*')))
            figure(ifold*10);
            subplot(3,2,6)
            title('Speed')
            plot(Speed_specific(:,1),Speed_specific(:,2))
            xlabel('Time')
            ylabel('Speed')
        catch
            disp('no Speed Data')
        end
    end
end