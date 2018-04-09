function dispFrameEvents(a,frame)
disp(sprintf('drawStartTime:\t%.2f',1000*(a.drawStartTime(frame)-a.loopStart(frame))));
disp(sprintf('drawEndTime:\t%.2f',1000*(a.drawEndTime(frame)-a.loopStart(frame))));
disp(sprintf('flipStart:\t%.2f',1000*(a.flipStart(frame)-a.loopStart(frame))));
disp(sprintf('flipEnd:\t%.2f',1000*(a.flipEnd(frame)-a.loopStart(frame))));
disp(sprintf('postFlipTime:\t%.2f',1000*(a.postFlipTime(frame)-a.loopStart(frame))));
disp(sprintf('time to next drawStart:\t%.2f',1000*(a.drawStartTime(frame+1)-a.postFlipTime(frame))));
disp(sprintf('Time between flips:\t%.2f',1000*(a.flipStart(frame+1)-a.flipStart(frame))));

disp(' ');
disp(sprintf('drawStartTime from last flip:\t%.2f',1000*(a.drawStartTime(frame)-a.flipStart(frame-1))));
disp(sprintf('drawEndTime from last flip:\t%.2f',1000*(a.drawEndTime(frame)-a.flipStart(frame-1))));
disp(sprintf('flipStart from last flip:\t%.2f',1000*(a.flipStart(frame)-a.flipStart(frame-1))));
