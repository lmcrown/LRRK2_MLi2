function [Mouse_info]=Get_Mouse_Session_Info(mousedir)

if nargin<1
    mousedir=pwd;
end
cd(mousedir)
Ses=load('Session_Info.mat');

bits=fileparts(mousedir);
Mouse_name=bits(end-2:end);
for irow=1:Rows(Ses.Session_Info.drugs)
    if Ses.Session_Info.drugs.Mouse(irow)==Mouse_name
        Drug=Ses.Session_Info.drugs.GotDrug(irow);
    else 
        continue
    end
end
Mouse_info.Recordingday=Ses.Session_Info.Recordingday;
Mouse_info.TypeDay=char(Ses.Session_Info.RecordingType);
Mouse_info.date=Ses.Session_Info.date;
Mouse_info.Mouse_name=Mouse_name;
Mouse_info.Drug=Drug;
Mouse_info.TypeMouse=Mouse_name(1);

