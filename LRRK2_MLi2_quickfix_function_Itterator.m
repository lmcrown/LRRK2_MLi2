function LRRK2_MLi2_quickfix_function_Itterator(Analysis_function, function_input,startdir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% root_results_directory = 'E:\Lindsey\LRRK2_MLi2\Analysis_Results\Questions';
if nargin < 3
   startdir=1;
end

if nargin < 2
    function_input = [];
end

% plot_things=false; %just for a doing a bunch so the graphics dont crap out
% Dset = [];
    

root_data_directory = 'E:\Lindsey\LRRK2_MLi2\Post_Processed';
% root_results_directory = 'E:\Lindsey\LRRK2_MLi2\Analysis_Results\Questions';

% 
% if ~exist(specific_results_directory,'dir')
%     mkdir(specific_results_directory)
% end

cd(root_data_directory);



all_dirs = dir('Mouse*');
for iDir = startdir:length(all_dirs)
    fprintf('running in %s \n',all_dirs(iDir).name);
%     cd(['E:\Lindsey\SD_data\Packaged_Data\' char(all_dirs(iDir).name)]) % in case the whole rat is skipped
    cd(all_dirs(iDir).name)
    dir2 = dir('*Day*');
    good_ix = [];

    for ii = 1:length(dir2)
        if dir2(ii).isdir && ~any(strfind(dir2(ii).name,'.') )
            good_ix = [good_ix, ii];
        end
    end
    dir2 = dir2(good_ix);
    
    for iDir2 = 1:length(dir2)
        if isdir(dir2(iDir2).name)
%            cd(['E:\Lindsey\SD_data\Packaged_Data\' char(all_dirs(iDir).name) '\' char(dir2(iDir2).name)]) % in case the function didnt run on the last file
            cd(dir2(iDir2).name)
            Analysis_function(); % Run the function (assumes it saves all of the relevant data and images).

%             [Dset] = Analysis_function(function_input); % Run the function (assumes it saves all of the relevant data and images).
%             save(fullfile(specific_results_directory,[all_dirs(iDir).name dir2(iDir2).name ]) ,'Dset')
            cd ..
        else
            continue
        end
    end
    cd ..
end
        msgbox('All done')