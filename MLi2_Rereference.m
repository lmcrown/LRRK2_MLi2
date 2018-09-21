function [ReRef]=MLi2_Rereference
miny=-1200;
maxy=1200;

direct=pwd;
mouseday=direct(end-6:end);

ReRef=struct();

fleft=find_files('*ECoG_Left*');
if isempty(fleft)
    Allleft_Ref=nan;
    disp('No Left Hemisphere Data, cannot ReReference')
    return
end
figure
for iref=1:numel(fleft)
    subplot(numel(fleft),1,iref)
    load(fleft{iref});
    plot(LFP_uV(:,1),LFP_uV(:,2))
    ylim([miny maxy]) %adjust if you dont like this but it seems like a reasonable number

    title(['Left Chan' num2str(iref)])
end
answer=inputdlg('All Good?');

if answer{1}=='1'
    for iref=1:numel(fleft)
       load(fleft{iref})
        if iref==1
            Allleft_Ref=LFP_uV;
        end
        if iref>1
            load(fleft{iref})
            Allleft_Ref(:,2)=Allleft_Ref(:,2)+LFP_uV(:,2);
        end
    end
    Allleft_Ref(:,2)=Allleft_Ref(:,2)./numel(fleft); 
    ReRef.Info.Left='all';
end
if answer{1}=='0'
    answer2=inputdlg('How many Channels do you want to use?');
    if answer2{1}=='1'
        answer3=inputdlg('Which channel will you take?');
        chan=str2double(answer3{1});
        RE=load(fleft{chan});
        Allleft_Ref=RE.LFP_uV;
        ReRef.Info.Left=fleft{chan};
    elseif answer2{1}=='2'
        answer4=inputdlg('Which channel will you exclude?');
        chan2=str2double(answer4{1});
        nitter=1;
        for ichan=1:length(fleft)
            if ichan ~= chan2
               P=load(fleft{ichan});
               Reff=P.LFP_uV;
               if nitter==1
                   Allleft_Ref=Reff;
               end
               if nitter>1
               Allleft_Ref(:,2)=Allleft_Ref(:,2)+ Reff(:,2);
               end
               nitter=nitter+1;
            end
        end
        Allleft_Ref(:,2)=Allleft_Ref(:,2)./2;
        ReRef.Info.Left=['not' answer4{1}];
    end
end

ReRef.Allleft= Allleft_Ref;

fright=find_files('*ECoG_Right*');
if isempty(fright) %it might be the case that you don't have any
    Alllright_Ref=nan;
    disp('No Right Hemisphere Data, cannot ReReference')
    return
end
figure
for iref=1:numel(fright)
    subplot(numel(fright),1,iref)
    load(fright{iref});
    plot(LFP_uV(:,1),LFP_uV(:,2))
    ylim([miny maxy])
    title(['Right Chan' num2str(iref)])
end
answer=inputdlg('All Good?');
if answer{1}=='1'
    for iref=1:numel(fright)
        load(fright{iref})
        if iref==1
            Allright_Ref=LFP_uV;
        end
        if iref>1
            load(fright{iref})
            Allright_Ref(:,2)=Allright_Ref(:,2)+LFP_uV(:,2);
        end
    end
    Allright_Ref(:,2)=Allright_Ref(:,2)./numel(fright);
    ReRef.Allright=Allright_Ref;
    ReRef.Info.Right='all';
end

if answer{1}=='0'
    answer2=inputdlg('How many Channels do you want to use?');
    if answer2{1}=='1'
        answer3=inputdlg('Which channel will you take?');
        chan=str2double(answer3{1});
        REF=load(fright{chan});
        Allright_Ref=REF.LFP_uV;
        ReRef.Info.Right=fright{chan};
    elseif answer2{1}=='2'
        answer4=inputdlg('Which channel will you exclude?');
        chan2=str2double(answer4{1});
        nitter=1;
        for ichan=1:length(fright)
            if ichan ~= chan2
               P=load(fright{ichan});
               Reff=P.LFP_uV;
               if nitter==1
                   Allright_Ref=Reff;
               end
               if nitter>1
               Allright_Ref(:,2)=Allright_Ref(:,2)+ Reff(:,2);
               end
               nitter=nitter+1;
            end
        end
        Allright_Ref(:,2)=Allright_Ref(:,2)./2;
        ReRef.Info.Right=['not' answer4{1}];
    end
end


ReRef.Allright=Allright_Ref;

save([mouseday '_Reref'],'ReRef')
