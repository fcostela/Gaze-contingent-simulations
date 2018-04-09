function textScreen(win, message)
% Display a message on the screen, until any keyis pressed.

bgColor = [255 255 255]; % white
fontColor = [0 0 0]; % black
fontSize = 40;
wrapat = 80;
font = 'Helvetica';

Screen('TextFont',win, font);
Screen('TextSize',win, fontSize);

Screen('FillRect',win, bgColor);

message = sprintf('%s\n\nPress space to continue.',message);
DrawFormattedText(win, message, 'center', 'center', fontColor, wrapat);

Screen('Flip', win);

[secs keyCode] = KbWait;
if keyCode(KbName('Escape')) 
    sca; 
    error('Pressed Escape'); 
end;
while KbCheck; end;
FlushEvents('keyDown');

