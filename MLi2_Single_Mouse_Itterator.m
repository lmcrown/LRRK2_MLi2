function MLi2_Single_Mouse_Itterator(Analysis_function, function_input,Mouse)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% root_results_directory = 'E:\Lindsey\LRRK2_MLi2\Analysis_Results\Questions';
if nargin < 3
    Mouse=pwd;
end

if nargin < 2
    function_input = [];
end

root_data_directory = Mouse;

cd(Mouse)

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
        fprintf('running in %s \n',dir2(iDir2).name);
        cd(dir2(iDir2).name)
        Analysis_function(); % Run the function (assumes it saves all of the relevant data and images).
        cd ..
    else
        continue
    end
end
cd ..

msgbox('All done')