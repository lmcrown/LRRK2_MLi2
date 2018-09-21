function MLi2_Do_All_the_Post_PostProcessing_Things(mousedir)

if nargin<1
    mousedir=pwd;
end
%LRRK2_MLi2_quickfix_function_Itterator(Analysis_function, function_input,startdir)
%Assumes working with Post Processed data

%Check for jerk artifacts before doing sleep analysis- this won't do
%anything if it hasn't found something bad
cd(mousedir)
MLi2_Single_Mouse_Itterator(@MLi2_exclude_jerk_artifact) %default is perform on just that mouses folder as pwd
% MLi2_exclude_jerk_artifact(mousefolder, jerkthresh, plotit)
cd(mousedir)
%Find Sleep
MLi2_Single_Mouse_Itterator(@MLi2_Find_Sleep)
% [Actual_Sleep_Times_Pre, Actual_Sleep_Times_Post] = MLi2_Find_Sleep(mousedir, length_for_sleep_sec, min_interinterval_sec,speedthresh,jerkthresh,plotit)
%after find sleep be sure you like the pictures saved in post processed
%sleep classfication folder
cd(mousedir)
%ReReference
MLi2_Single_Mouse_Itterator(@MLi2_Rereference)
% [ReRef]=MLi2_Rereference
cd(mousedir)
%Find Spindles
%This one is meant to be run as an analysis
% [Spindle]=MLi2_Find_Spindles(lowerthresh_std, upperthresh_std,lowlimit_fq,highlimit_fq, eeg_chan, plot_it)
%Be sure to make notes in Meta Data excel File as you go