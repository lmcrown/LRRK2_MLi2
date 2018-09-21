function [pos_struct, POS] = AVT_Process_Tracking_Log_4_animals(log_file, frame_times_or_recIDs)
% Cowen - added the POS output
if nargin == 0
    error('No input file');
end

infoFile = dir(log_file);
if isempty(infoFile)
    error('File not found')
elseif infoFile.bytes == 0
    error('File empty');
end


HEADLINE = 'Rx	Ry	Gx	Gy	Bx	By	Time (s)'; % Header should be the same in every file
FORMAT = '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f'; %Read as floats to read the null values.
CHUNK = 100000; %Default lines to read at a time. (This is about an hour)

%Define the output structure. Here is a good place to initialize anything
%else you might want to process (eg "Head Direction","In reward zone" etc)
pos_struct = struct('RedA',[],'RedB',[],'RedC',[],'RedD',[],'ElapsedTime',[]);

%Open the file. Check if the header is right.

fid = fopen(log_file);
if 0 % Ignoring for now,but we should change the .pos save function so that proper headings are made.
    if ~strcmp(fgetl(fid),HEADLINE);
        fclose(fid);
        error('File wrong format');
    end
else
    fgetl(fid)
end

%So that we can muck with the tracking in redeal time during the recording,
%we need a way to find out if a channel was never used. Every chunk, we see
%if there are any non-null values for each channel. If there are, they get
%set to true, if not, they will stay as initialized:
redValid = false;
greenValid = false;
blueValid = false;
timeValid = false;

%iterate through file by blocksize.
POS = [];
while ~feof(fid)
    readblock = textscan(fid,FORMAT,CHUNK,'Delimiter','\t','EmptyValue',NaN); %Sorry, Stephen, I didn't see anything about this function being deprecated. Textread maybe you were thinking about?
    if ~isempty(readblock{1})
        tmp = nan(Rows(readblock{1}),length(readblock));
        for ii = 1: length(readblock)
            tmp(:,ii) = readblock{ii};
        end
        POS = [POS; tmp];
        %     ElapsedTime = tmp(:,end);
        %     pos_struct.ElapsedTime = [pos_struct.ElapsedTime,ElapsedTime'];
    end
end
%Close file
fclose(fid);

pos_struct.External_Sync_Times = [];
if nargin > 1
    pos_struct.External_Sync_Times = frame_times_or_recIDs;
    % Synchronize - put intan (or some other) timestamps in data.
    df = Rows(POS) - length(frame_times_or_recIDs);
    if abs(df) < 2
        pos_struct.External_Sync_Times = frame_times_or_recIDs(1:Rows(POS));
        POS(:,end+1) = frame_times_or_recIDs(1:Rows(POS));
    else
        disp(['Likely ERROR as there are ' num2str(df) ' records are in position but there are no corresponding timestamps for those records']);
        disp('Will assume that tracking was running PRIOR to recording and so will count backwards.');
        disp('Should work with unique codes.');
        pos_struct.External_Sync_Times  = frame_times_or_recIDs(end-Rows(POS)+1:end);
        POS(:,end+1) = frame_times_or_recIDs(end-Rows(POS)+1:end);

    end
end
