function LRRK2_directoryitterate_PostProcess(Analysis_function,root_data_directory,startdir,plot_it)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<4
    plot_it=true;
end
if nargin<3
    startdir=1;
end
if nargin<2
    root_data_directory=pwd;
end
if nargin<1
    Analysis_function=@INTAN_Post_Process_LRRK2_MLi2_LC;
end

cd(root_data_directory);

all_dirs = dir('*Day*');
for iDir = startdir:length(all_dirs)
    fprintf('running in %s \n',all_dirs(iDir).name);
    cd([root_data_directory '\' char(all_dirs(iDir).name)])
    innerdir= dir('*Day*');
    try  % not entirely sure this works- but this is trying to figure out what to do if there is no data in there
    if isdir(innerdir.name)==1
        cd(innerdir.name)
        Analysis_function(plot_it);
        cd ..
    end
    catch
        continue
    end
    cd ..
end
msgbox('All done')
cd(all_dirs(iDir).name)
dir2 = dir();
good_ix = [];

for ii = 1:length(dir2)
    if dir2(ii).isdir && ~any(strfind(dir2(ii).name,'.') )
        good_ix = [good_ix, ii];
    end
end
dir2 = dir2(good_ix);

for iDir2 = 1:length(dir2)
    if isdir(dir2(iDir2).name)
        cd(['E:\Lindsey\SD_data\Packaged_Data\' char(all_dirs(iDir).name) '\' char(dir2(iDir2).name)]) % in case the function didnt run on the last file
        %             cd(dir2(iDir2).name)
        Dset = Analysis_function(); % Run the function (assumes it saves all of the relevant data and images).
        save(fullfile(specific_results_directory,[all_dirs(iDir).name dir2(iDir2).name ]) ,'Dset')
        cd ..
    else
        continue
    end
    cd ..
end

end
