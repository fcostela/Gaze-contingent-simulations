function checkPixelSize
% Present a 200x200 pixel white square on the Screen, so that you can
% measure it and determine the pixel/cm ratio.
%
% Usage: checkPixelSize



%Open window 
whichScreen=max(Screen('Screens'));
window=Screen('OpenWindow',whichScreen,[0 0 0]);
HideCursor

%Get window centre
windowsize=Screen('Rect',window);    % window-coordinates, e.g. [0 0 1024 768]
xcenter=round(windowsize(3)/2); % center of window
ycenter=round(windowsize(4)/2);
squareSize = 200;

Screen('FillRect',window,[255 255 255], [xcenter - round(squareSize/2), ycenter - round(squareSize/2), xcenter + round(squareSize/2), ycenter + round(squareSize/2)]);
text = 'Measure the length of one of the sides in cm. Then press space.';
Screen('DrawText', window, text, 10, 10, [255 255 255]);
Screen('flip',window);

pause(25);
sca;
%[answer, anstime]=get_key(KbName('space'), 1);  % wait for spacebar

Screen('CloseAll')
clear mex
%measurement = input(sprintf('Now input the measured size in cm (corresponding to %d pixels) and press return: ',round(squareSize)));
%fdisp(sprintf('The ratio is %f cm/pixel, or %f pixels/cm.', measurement/squareSize, squareSize/ measurement));