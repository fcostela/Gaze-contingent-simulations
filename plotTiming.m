if length(timingInfo.flipStart) > 200
    b = 3:200;
else
    b = 3:length(timingInfo.flipStart);
end
% b = 3:1009;
% b = 501:550;
d = [];
% d(:,1) = timingInfo.loopStart(b) - timingInfo.flipStart(b-1);
d(:,1) = timingInfo.predictionStartTime(b) - timingInfo.postFlipTime(b-1);  % Time gathering eyelink samples before deciding to draw
d(:,2) = timingInfo.drawStartTime(b) - timingInfo.predictionStartTime(b);
d(:,3) = timingInfo.drawEndTime(b) - timingInfo.drawStartTime(b);  % Time to draw it
d(:,4) = timingInfo.flipStart(b) - timingInfo.drawEndTime(b); % Time between calling flip and the actual flip occurrence
d(:,5) = timingInfo.postFlipTime(b) - timingInfo.flipStart(b); % Time for the flip to actually occur
d= d * 1000;

barh(d,1,'stacked');
colormap(jet)
grid on;
grid minor;
set(gca,'layer','top')
set(gca,'GridLineStyle','-');
set(gca,'YDir','reverse');
axis tight
% legend('Flip execution','Drawing background and receiving eye position','Drawing simulated scotoma', 'Blocked on Screen(''flip'')', 'Flip execution','Location','NorthEastOutside')
legend('Gaze collection' ,'Prediction time','Drawing frame', 'Blocking on flip', 'Flip time','Location','NorthEastOutside')
title('Blah')
xlabel('Time since previous flip start (ms)');
set(gca,'FontSize',16)
 set(gca,'YTick',[])
 set(gcf,'Position',[605         118        1149         824]);