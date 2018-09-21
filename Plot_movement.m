IX= POS_specific(:,3)> 1.7e4 & POS_specific(:,3)< 1.78e4
newpos=POS_specific(IX,:);

%area of interest
figure

for i= 1:length(IX)
    plot(newpos(i,1),newpos(i,2),'.b')
    xlim([min(POS_specific(:,1)) max(POS_specific(:,1))])
ylim([min(POS_specific(:,2)) max(POS_specific(:,2))])
    pause(.01)
end


%whole thing
figure

for i= 1:length(IX)
    plot(POS_specific(i,1),POS_specific(i,2),'.b')
    xlim([min(POS_specific(:,1)) max(POS_specific(:,1))])
ylim([min(POS_specific(:,2)) max(POS_specific(:,2))])
    pause(.01)
end