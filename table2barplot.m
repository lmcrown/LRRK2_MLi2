function [datamatrix]=table2barplot(variable,mousecategories_in_table)

%input a variable (likely from the table) like percent time sleeping or
%somethng
%mouse categories should be another variable from that table that has the
%classification of the mouse - ie LRRK or WT, drug no drug

%each ROW must be mouse and there must be one single variable you are
%looking at and want to bar plot

%output is data_matrix that has  nans to make it an even matrix that you
%can then make a plot with, for example Plot_Mean_SEM_All_Points_LC


JustLRRKix=mousecategories_in_table=='L';
JustWTix=mousecategories_in_table=='W';

variable(JustLRRKix)
variable(JustWTix)

diffamount=abs(length(variable(JustWTix))-length(variable(JustLRRKix)));
if sum(JustWTix)>sum(JustLRRKix)
    LRRKpercent= vertcat(variable(JustLRRKix),nan(diffamount,1));
    WTpercent=variable(JustWTix);
end

if sum(JustLRRKix)>sum(JustWTix)
    WTpercent= vertcat(variable(JustWTix),nan(diffamount,1));
    LRRKpercent=variable(JustLRRKix);
end

if sum(JustWTix)==sum(JustLRRKix)
    LRRKpercent=variable(JustLRRKix);
    WTpercent=variable(JustWTix);
end

datamatrix=[LRRKpercent,WTpercent];
