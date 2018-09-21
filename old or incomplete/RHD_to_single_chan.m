
%Check that the data is in the right order before you concat.
%the last number on the file name is going to be in numerical order

%initialize channels to be concat.
files=find_files('*.rhd');
%quickly check that nothing is out of order
for ifile=1:length(files)-1
    num1=files{ifile+1}(end-9:end-4);
    time_next=str2double(num1);
    num2=files{ifile}(end-9:end-4);
    time_now=str2double(num2);
    if time_now>=time_next
        error('Times are possibly out of order-check!')
    end
end
%  INTAN_read_Intan_RHD2000_file_multi(fname)

%  chans = {amplifier_channels.native_channel_name}.'; % creates cell array of names of chans

%%
%first make the names for the dat files you want to output
%name will be found in the file, if you do the normal function first--?
read_Intan_RHD2000_file  %this gives you a GUI
chans = {amplifier_channels.native_channel_name}.';
for ichan=1:length(chans)
    name=chans{ichan};
    chan=fopen([name '.dat'],'w');
    fclose(chan);
end

dats=find_files('*.dat');

for ifile=1:length(files)
    [OUT]=INTAN_read_Intan_RHD2000_file_multi(files{ifile});
    assert(isequal(numel(chans),numel(dats)),'diff number of chan and dats, may not be writing to correct file')
    for ichan=1:length(chans)
        name=chans{ichan};
        chan=fopen([name '.dat'],'a');
        data=OUT.amplifier_data(ichan,:);
        fwrite(chan,data,'int16') % here its only giving me like one number
        fclose(chan);
    end
    clear OUT
end


%to make it the same as in post-processing they need amp- in front of them

%are they correctly in binary? nothing else done to edit them?

%% NEXT UP: AUXs and DINS

%we need board-DIN-08 09 010
%can you get time.dat and info.rhd?
AUX = {aux_input_channels.native_channel_name}.';
