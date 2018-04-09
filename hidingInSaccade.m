function v = hidingInSaccade
esc=KbName('ESCAPE');

dummymode = 0;
screenDistance = 95; % Distance from eyes to monitor in cm
pixelsPerCm = 43.5; % Obtained by checkPixelSize
scotomaDegrees = 1; % size of scotoma in degrees of visual angle, including the ramps
scotomaPixels = visualAngleToCm(scotomaDegrees,screenDistance) * pixelsPerCm
% Note that a lot of the ramp will still look pretty
% opaque or transparent (the width is the distance
% from 0.01 to 0.99 opacity), so it may not look as
% wide as you expect.

scotomaRatio = 1; % Ratio of the width to the height
v = [];
changeThreshold = 200;
try
    HideCursor;
    
    Screen('Preference', 'SkipSyncTests', 0);
    Screen('Preference', 'Verbosity', 2);
    KbName('UnifyKeyNames');
    
    % Open a graphics window on the main screen
    meanLum=127;                    % mean display level
    whichScreen=max(Screen('Screens'));
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible'); % request 32 bit per pixel for high res contrast
    win = PsychImaging('OpenWindow', whichScreen, meanLum);
    
    % Initialize eyelink
    el=EyelinkInitDefaults(win);
    if ~EyelinkInit(dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    % make sure that we get gaze data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    
    if Eyelink('isconnected') ~= el.dummyconnected
        % Calibrate the eye tracker
        EyelinkDoTrackerSetup(el);
    end
    Eyelink('startrecording');
    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR; % if both eyes are tracked
        eye_used = el.LEFT_EYE; % use left eye
    end
 eyeMovementThreshold = 0;
   
    scotomaX = -1000; scotomaY = -1000;
    while(1)
        
        newEyelinkData = false;
        % Get the gaze location.
        % If in dummy mode, use the mouse position.
        if Eyelink('isconnected') == el.dummyconnected
            [x,y,button] = GetMouse(win);
            missing = 0;
            newEyelinkData = true;
        else
            if Eyelink( 'NewFloatSampleAvailable') > 0
                % get the sample in the form of an event structure
                evt = Eyelink( 'NewestFloatSample');
                if eye_used ~= -1 % do we know which eye to use yet?
                    % if we do, get current gaze position from sample
                    x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                    y = evt.gy(eye_used+1);
                    % do we have valid data and is the pupil visible?
                    if x~=el.MISSING_DATA && y~=el.MISSING_DATA && evt.pa(eye_used+1)>0
                        missing = 0;
                    else
                        missing = 1;
                    end
                    newEyelinkData = true;
                end
                
            end
        end
        
        if newEyelinkData
            Screen('FillRect',win,[0 0 0]);
            if ~missing
                speed = sqrt((x-scotomaX)^2 + (y-scotomaY)^2);
                v = [v speed];
                if speed > eyeMovementThreshold
                    scotomaX = x;
                    scotomaY = y;
                end
            end
            if speed > changeThreshold
                drawDirectLatencyIcon(win,scotomaX,scotomaY,round([scotomaPixels, scotomaPixels*scotomaRatio]),[255 0 0]);
            else
                drawDirectLatencyIcon(win,scotomaX,scotomaY,round([scotomaPixels, scotomaPixels*scotomaRatio]),[255 255 255]);
            end
                
            vbl=Screen('Flip', win);
        end
        % Also stop if the escape key is pressed
        [keyIsDown,secs,keyCode]=KbCheck;
        if (keyIsDown==1 && keyCode(esc))
            error('Escape pressed');
        end
    end
    
    cleanup;
    
catch myerr
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if it's open.
    disp(sprintf('ERROR: %s', myerr.message));
    for i = 1:length(myerr.stack)
        disp(sprintf('File %s Line %d', myerr.stack(i).file, myerr.stack(i).line));
    end
    sca; %cleanup;
    commandwindow;
end %try..catch.



% Cleanup routine for at the end or in case of an error
function cleanup

% finish up: stop recording eye-movements,
% close graphics window, close data file and shut down tracker
Eyelink('Stoprecording');
Eyelink('CloseFile');
Eyelink('Shutdown');

% Close window:
sca;

% Restore keyboard output to Matlab:
ListenChar(0);


function drawDirectLatencyIcon(win, x,y, dimensions,color)
iconRect = CenterRectOnPoint([0 0 dimensions(2) dimensions(1)],x,y);

% drawCross(win, 1000,30);
% drawCross(win,1450,30);
penWidth = 20;
% Screen('DrawLine', win, [255 255 255], x,0,x,1440,penWidth);
% 
% 
Screen('FillOval',win,color,iconRect);
% v = iconRect(2) + (iconRect(4)-iconRect(2))*0.25;
% Screen('DrawLine', win, [0 0 0], iconRect(1),v,iconRect(3),v,penWidth);
% v = (iconRect(2) + iconRect(4))*1/2;
% Screen('DrawLine', win, [0 0 0], iconRect(1),v,iconRect(3),v,penWidth);
% v = iconRect(2) + (iconRect(4)-iconRect(2))*0.75;
% Screen('DrawLine', win, [0 0 0], iconRect(1),v,iconRect(3),v,penWidth);


function drawCross(win,x,y)
cs = 30;
Screen('DrawLine', win, [255 255 255], x-cs,y,x+cs,y);
Screen('DrawLine', win, [255 255 255], x,y-cs,x,y+cs);


