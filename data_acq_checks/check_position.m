function check_position
%%% issue: this still requires intan data- must make so doesnt require

fs_initial=12500;

d = dir('*.pos');
if isempty(d)
    error('Could not find position file')
else
    pos_file = d(1).name;
end
pos_frame_times_intan_file = 'board-DIN-09.dat'; %%%issue

intan_pos_frame_recids = INTAN_Extract_Transitions( pos_frame_times_intan_file ); fprintf('.');

[~,POS] = AVT_Process_Tracking_Log_4_animals(pos_file, intan_pos_frame_recids./fs_initial);

Boxnum=['A' 'B' 'C' 'D'];
% Plot the position and speed for each mouse.
figure 
for ibox=1:4
    subplot(2,2,ibox)
    newPOS = POS(:,[end 2*(ibox-1)+1 2*(ibox-1)+2]);
    newPOS(:,1) = newPOS(:,1)/fs_initial;
    plot(newPOS(:,2)/3600,newPOS(:,3),'.','MarkerSize',.5)
    title(['Box ' Boxnum(ibox)])
end

    xlabel('pixels')