function [Adjusted_Pre, Adjusted_Post, adjusted_bounds]=Adjust_to_Middle_Sleep(EPOCHS,Actual_Sleep_Times_Pre, Actual_Sleep_Times_Post,Sleep_Period_min)

if nargin<4
    Sleep_Period_min=100;
end
if nargin<3
    f=find_files('*Sleep_Times_Post*');
    load(f{1});
end

if nargin<2
    ff=find_files('*Sleep_Times_Pre*');
    load(ff{1});
end

if nargin<1
    fff=find_files('*EPOCHS*');
    load(fff{1});
end

%%
PreMin=EPOCHS.PREsleep_t_sec/60;
if PreMin<Sleep_Period_min
    disp('Yo you have less than your middle amount of sleep you want')
end
Up_down_min=Sleep_Period_min/2;
mid_t_sec=EPOCHS.PREsleep_t_sec/2;


PostMin=EPOCHS.POSTsleep_t_sec/60;
if PostMin<Sleep_Period_min
    disp('Yo you have less than your middle amount of sleep you want')
end

upper_bound_pre=mid_t_sec+(60*Up_down_min);
lower_bound_pre=mid_t_sec-(60*Up_down_min);

Adjusted_Pre=nan(size(Actual_Sleep_Times_Pre));
for iRows=1:Rows(Actual_Sleep_Times_Pre)
    if  Actual_Sleep_Times_Pre(iRows,1)> lower_bound_pre && Actual_Sleep_Times_Pre(iRows,2) < upper_bound_pre
        Adjusted_Pre(iRows,:)=Actual_Sleep_Times_Pre(iRows,:);
    end
    if Actual_Sleep_Times_Pre(iRows,1) < lower_bound_pre && Actual_Sleep_Times_Pre(iRows,2) < upper_bound_pre
        Adjusted_Pre(iRows,1)=lower_bound_pre;
        Adjusted_Pre(iRows,2)=Actual_Sleep_Times_Pre(iRows,2);
    end
    if Actual_Sleep_Times_Pre(iRows,1)> lower_bound_pre && Actual_Sleep_Times_Pre(iRows,2)> upper_bound_pre
        Adjusted_Pre(iRows,1) = Actual_Sleep_Times_Pre(iRows,1);
        Adjusted_Pre(iRows,2) = upper_bound_pre;
    end
     if  Actual_Sleep_Times_Pre(iRows,2)< lower_bound_pre || Actual_Sleep_Times_Pre(iRows,1) > upper_bound_pre
        Adjusted_Pre(iRows,:)=[nan,nan];
    end
end

%%
PostMin= EPOCHS.PostSleepMins/2;
mid_t_sec=EPOCHS.POSTsleep_t_sec+(60*PostMin);


upper_bound_post=mid_t_sec+(60*Up_down_min);
lower_bound_post=mid_t_sec-(60*Up_down_min);


Adjusted_Post=nan(size(Actual_Sleep_Times_Post));
for iRows=1:Rows(Actual_Sleep_Times_Post)
    if  Actual_Sleep_Times_Post(iRows,1)> lower_bound_post && Actual_Sleep_Times_Post(iRows,2) < upper_bound_post
        Adjusted_Post(iRows,:)=Actual_Sleep_Times_Post(iRows,:);
    end
    if Actual_Sleep_Times_Post(iRows,1) < lower_bound_post && Actual_Sleep_Times_Post(iRows,2) < upper_bound_post
        Adjusted_Post(iRows,1)=lower_bound_post;
        Adjusted_Post(iRows,2)=Actual_Sleep_Times_Post(iRows,2);
    end
    if Actual_Sleep_Times_Post(iRows,1)> lower_bound_post && Actual_Sleep_Times_Post(iRows,2)> upper_bound_post
        Adjusted_Post(iRows,1) = Actual_Sleep_Times_Post(iRows,1);
        Adjusted_Post(iRows,2) = upper_bound_post;
    end
     if  Actual_Sleep_Times_Post(iRows,2)< lower_bound_post || Actual_Sleep_Times_Post(iRows,1) > upper_bound_post
        Adjusted_Post(iRows,:)=[nan,nan];
    end
end

adjusted_bounds.upper_bound_pre=upper_bound_pre;
adjusted_bounds.upper_bound_post=upper_bound_post;

adjusted_bounds.lower_bound_post=lower_bound_post;
adjusted_bounds.lower_bound_pre=lower_bound_pre;