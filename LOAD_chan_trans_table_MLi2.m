
function CTT= LOAD_chan_trans_table_MLi2(trans_table_file)
% loads the channel translation table from an excel spreadsheet
% Lindsey doin this instead of INTAN_Load_Channel_Trans_Table.m for new table
% on 12/18/2017


CTT= readtable(trans_table_file,'ReadVariableNames',true);
CTT.IsLFP=logical(CTT.IsLFP); %turn these into logicals
CTT.IsEMG=logical(CTT.IsEMG); %4/14 this is weird- below i had put a way to make it into logicals because it was being imported as a cell but likes like a char
% if class(CTT.IsEMG)=='cell'
%     CTT.IsEMG=logical(cell2mat(CTT.IsEMG));
% else
%     CTT.IsEMG=logical(CTT.IsEMG);
% end

CTT.MouseNum=categorical(CTT.MouseNum);
CTT.Region=CTT.Region;
CTT.Port=categorical(CTT.Port);
CTT.IntanHSPin_=int16(CTT.IntanHSPin_);
CTT.IntanCh=int16(CTT.IntanCh);
CTT.GotDrug=logical(CTT.GotDrug);