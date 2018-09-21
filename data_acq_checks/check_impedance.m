function [CTT]=check_impedance(IF, CTT)

ampinfo=struct2table(IF.amplifier_channels);

for iamp=1:Rows(ampinfo)
    for ichan=1:Rows(CTT)
        if CTT.IntanHSPin_(ichan)<10
            Channelname=[char(CTT.Port(ichan)) '-00' num2str(CTT.IntanHSPin_(ichan))];
        else
            Channelname=[char(CTT.Port(ichan)) '-0' num2str(CTT.IntanHSPin_(ichan))];
        end
        %need to figure what to do if it doesnt find it- maybe have it itterate
        %through the amp info instead---i think i might just do a double for
        %loop
        if Channelname == ampinfo.custom_channel_name{iamp} %convert to categorical so its easier to match to the string, otherwise is cell
            CTT.ImpedancesAfterImplantation(ichan)=ampinfo.electrode_impedance_magnitude(iamp);
        end
    end
end
% OMG Stephens readRHDfile script already has an impedance check in it- but
% I'm removing it so we can do our own and be able to know if something was
% disconnected
% CTT.Impedancesafterimplantation=str2double(CTT.Impedancesafterimplantation);

nrow = size(CTT,1);
CTT.ImpGood = zeros(nrow, 1);
fID=fopen('postprocess_notes.txt','w');
for Imp = 1:length(CTT.ImpedancesAfterImplantation)
    if CTT.ImpedancesAfterImplantation(Imp) <=100000 && CTT.ImpedancesAfterImplantation(Imp)> 0
        CTT.ImpGood(Imp) = 1;
    elseif CTT.ImpedancesAfterImplantation(Imp)> 0 && CTT.ImpedancesAfterImplantation(Imp) >100000
        fprintf('Impedance too high for %s %s - %i \n',CTT.Region{Imp},CTT.Port(Imp),CTT.IntanHSPin_(Imp));
        fprintf(fID,'Impedance too high for %s %s - %i \n',CTT.Region{Imp},CTT.Port(Imp),CTT.IntanHSPin_(Imp));
    end
end
fclose(fID);
CTT.ImpGood=logical(CTT.ImpGood);
        
