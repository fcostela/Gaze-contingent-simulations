xcenter = 512;
firstSaccadeTolerance = 80;
eyetrackList = ceil(rand(1,30)*length(eyetrackRecords));
% eyetrackList = 1:length(eyetrackRecords);
for j = 1:length(eyetrackList)
    i = eyetrackList(j);
    disp(sprintf('First saccade time:\t%d\tFirst saccade dir:\t%d\tTarget dir:\t%d',eyetrackRecords(i).firstSaccadeTime, eyetrackRecords(i).firstSaccadeDir, eyetrackRecords(i).targetDir));
    xs = eyetrackRecords(i).xs;
    ts = eyetrackRecords(i).ts;
    figure; plot(ts-ts(1), xs);
    hold on; plot(ts-ts(1), xcenter, 'k'); plot(ts-ts(1), xcenter - firstSaccadeTolerance, 'r'); plot(ts-ts(1), xcenter + firstSaccadeTolerance, 'r');
    set(gca,'YLim',[0 1024]); set(gca,'XLim',[0 ts(end)-ts(1)]);
    title(num2str(i));
end