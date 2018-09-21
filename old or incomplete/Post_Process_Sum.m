

AVT_Process_Tracking_Log_4_animals  % Process the tracking

INTAN_Post_Process_LRRK2_MLi2 %downsample and process the intan data

%check for stuff that you will need- you have to move all of these into the
%intan folder before you run this

assert(~isempty(dir('board-DIN-08.dat')),'DIN-8  missing')
assert(~isempty(dir('board-DIN-09.dat')),'DIN-9  missing')
assert(~isempty(dir('board-DIN-10.dat')),'DIN-10  missing')


assert(~isempty(dir('*.pos')),'no pos file')
assert(~isempty(dir('info.rhd')),'no rhd file')

assert(~isempty(dir('Channel_translation_table*.xlsx')),'need channel tranlation table')






%next needed is the LFP data

%need to read in chan translation table
downsample_factor=500;
EMG_1='amp-B-000.dat';
EMG_2='amp-B-002.dat';

ECOGmidB=

EMG1=INTAN_Read_DAT_file(EMG_1);
EMG2=INTAN_Read_DAT_file(EMG_2);

figure
subplot(6,2,9)
plot(Spin_chan)

subplot(6,2,4)
plot(EMG2(1:50:end)')

