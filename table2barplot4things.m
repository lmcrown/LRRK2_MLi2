function [data_matrix]=table2barplot4things(variable,mousecategories1,mousecategories2)

%input a variable (likely from the table) like percent time sleeping or
%somethng
%mouse categories should be another variable from that table that has the
%classification of the mouse - ie LRRK or WT, drug no drug

%each ROW must be mouse and there must be one single variable you are
%looking at and want to bar plot

%output is data_matrix that has  nans to make it an even matrix that you
%can then make a plot with, for example Plot_Mean_SEM_All_Points_LC

LRRK_BORING_ix= mousecategories1=='L' & mousecategories2=='Boring';
WT_BORING_ix= mousecategories1=='W' & mousecategories2=='Boring';
LRRK_RR_ix= mousecategories1=='L' & mousecategories2=='Rotarod';
WT_RR_ix= mousecategories1=='W' & mousecategories2=='Rotarod';

cols{1}=variable(LRRK_BORING_ix);
cols{2}=variable(WT_BORING_ix);
cols{3}=variable(LRRK_RR_ix);
cols{4}=variable(WT_RR_ix);

biggest=max([length(cols{1}),length(cols{2}),length(cols{3}),length(cols{4})]);
data_matrix=[];
for icol=1:length(cols)
    if length(cols{icol})<biggest
       differ= biggest-length(cols{icol});
      data_matrix(:,icol) =[cols{icol}; nan(differ,1)];
    end
    if length(cols{icol})==biggest
        data_matrix(:,icol)=cols{icol}
    end
end
disp('LRRK BORING WT_BORING LRRK_RR WT_RR')

