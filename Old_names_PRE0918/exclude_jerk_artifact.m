

function MLi2_exclude_jerk_artifact(mousefolder, jerkthresh, plotit)

% function will input jerk from mouse folder, check if the sum of any of
% the coordinates is higher than usual. If so, it will plot all of them,
% ask you to choose which plots are good or bad, ask if the whole thing is
% bad or a portion of it is bad, and if only a portion, it will ginput
% where it starts and turn all remaining values into naans. 


if narg<3
    plotit=1;
end

if narg<2
    jerkthresh=1;
end

if narg<1
    mousefolder=pwd;
end

cd(mousefolder)

find_jerk=FindFiles('*jerk*');
string=char(find_jerk);
if ispc
    jerk_name=strsplit(string,'\');
    jerk_name=jerk_name{6};
end
if ismac
    jerk_name=strsplit(string,'/');
    jerk_name=jerk_name{7};
end
load(find_jerk{1});


sumofone=sum(jerk(:,2));
sumoftwo=sum(jerk(:,3));
sumofthree=sum(jerk(:,4));

if sumofone>(1*10^7) || sumoftwo>(1*10^7) || sumofthree > (1*10^7)
    
    figure
    subplot(3,1,1)
    plot(jerk(:,1),jerk(:,2));
    subplot(3,1,2)
    plot(jerk(:,1),jerk(:,3));
    subplot(3,1,3)
    plot(jerk(:,1),jerk(:,4));
    
    answer = inputdlg('Are all jerks okay? 1 for yes, 0 for no.');
    answer=char(answer);
    
    if answer =='1'
        jerk(:,5) = jerk(:,2)+jerk(:,3)+jerk(:,4);
    elseif answer=='0' 
        answer1= inputdlg ('how many jerks are not okay?');
        answer1=char(answer1);
        if answer1=='1'
            answer2= inputdlg('which one is not okay?');
            answer2=char(answer2);
            answer3= inputdlg('press 0 if entire jerk is bad, press 1 if you would like to use ginput');
            answer3=char(answer3);
            if answer3=='0' && answer2=='1'
                jerk(:,5)=jerk(:,3)+jerk(:,4);
            elseif answer3=='0' && answer2=='2'
                jerk(:,5)=jerk(:,2)+jerk(:,4);
            elseif answer3=='0' && answer2=='3'
                jerk(:,5)=jerk(:,2)+jerk(:,3);
            end
            if answer3=='1' && answer2=='1'
                figure
                plot(jerk(:,1),jerk(:,2));
                [x,y]=ginput(1);
                for i=1:length(jerk)
                    if jerk(i,1)>x
                        jerk(i,2)=0;
                    end
                end
                jerk(:,5)= jerk(:,2)+jerk(:,3)+jerk(:,4);
            elseif answer3=='1' && answer2=='2'
                figure
                plot(jerk(:,1),jerk(:,3));
                [x,y]=ginput(1);
                for i=1:length(jerk)
                    if jerk(i,1)>x
                        jerk(i,3)=0;
                    end
                end
                jerk(:,5)= jerk(:,2)+jerk(:,3)+jerk(:,4);
            elseif answer3=='1' && answer2=='3'
                figure
                plot(jerk(:,1),jerk(:,4));
                [x,y]=ginput(1);
                for i=1:length(jerk)
                    if jerk(i,1)>x
                        jerk(i,4)=0;
                    end
                end
                jerk(:,5)= jerk(:,2)+jerk(:,3)+jerk(:,4);
            end
        elseif answer1=='2'
            answer2=inputdlg('which one is okay?');
            answer2=char(answer2);
            if answer2=='1'
                figure
                plot(jerk(:,1),jerk(:,3))
                [x,y]=ginput(1);
                for i=1:length(jerk)
                    if jerk(i,1)>x
                        jerk(i,3)=0;
                    end
                end
                figure
                plot(jerk(:,1),jerk(:,4));
                [w,z]=ginput(1);
                for f=1:length(jerk)
                    if jerk(f,1)>w
                        jerk(f,4)=0;
                    end
                end
                jerk(:,5)=jerk(:,2)+jerk(:,3)+jerk(:,4);
            elseif answer2=='2'
                figure
                plot(jerk(:,1),jerk(:,2))
                [x,y]=ginput(1);
                for i=1:length(jerk)
                    if jerk(i,1)>x
                        jerk(i,2)=0;
                    end
                end
                figure
                plot(jerk(:,1),jerk(:,4));
                [w,z]=ginput(1);
                for f=1:length(jerk)
                    if jerk(f,1)>w
                        jerk(f,4)=0;
                    end
                end
                jerk(:,5)=jerk(:,2)+jerk(:,3)+jerk(:,4);
            elseif answer2=='3'
                figure
                plot(jerk(:,1),jerk(:,2))
                [x,y]=ginput(1);
                for i=1:length(jerk)
                    if jerk(i,1)>x
                        jerk(i,2)=0;
                    end
                end
                figure
                plot(jerk(:,1),jerk(:,3));
                [w,z]=ginput(1);
                for f=1:length(jerk)
                    if jerk(f,1)>w
                        jerk(f,3)=0;
                    end
                end
                jerk(:,5)=jerk(:,2)+jerk(:,3)+jerk(:,4);
            end
        elseif answer1=='3'
            answer4=inputdlg('do you want to ginput? Press 1 for yes and 0 for no');
            answer4=char(answer4);
            if answer4=='1'
                figure
                plot(jerk(:,1),jerk(:,2));
                [x,y]=ginput(1);
                for i=1:length(jerk)
                    if jerk(i,1)>x
                        jerk(i,2)=0;
                    end
                end
                figure
                plot(jerk(:,1),jerk(:,3));
                [w,z]=ginput(1);
                for i=1:length(jerk)
                    if jerk(i,1)>w
                        jerk(i,3)=0;
                    end
                end
                figure
                plot(jerk(:,1),jerk(:,4));
                [a,b]=ginput(1);
                for i=1:length(jerk)
                    if jerk(i,1)>a
                        jerk(i,4)=0;
                    end
                end
                jerk(:,5)=jerk(:,2)+jerk(:,3)+jerk(:,4);
                for l=1:length(jerk)
                    if jerk(l,5)==0
                        jerk(l,5)=nan;
                    end
                end
            elseif answer4== '0'
                jerk(:,5)=nan;
            end
            
        end
        
    end
    
end


save(jerk_name,'jerk');
%plot to make sure threshold still works
if plotit==1
    figure
    plot(jerk(:,1),jerk(:,5));
    hline = refline([0 jerkthresh]);
    hline.Color = 'r';
end

