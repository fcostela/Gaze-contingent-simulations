function timingInfo = artificialScotomaDemo(participantID, videoOrder)
if ~exist('participantID')  participantID = ''; end;
if ~exist('videoOrder')
    videoOrder =   Shuffle(1:200);
end;
videoRoot = '/Volumes/pelilab/Images & Videos/Videos/TV with LV/Compressed Clips/';
% videoRoot = '/Users/danielsaunders/Free norm - video clips/';
dummymode = 1; % In this mode, we don't access the eyetracker, but rather get a simulated gaze location from the mouse coordinates.
latencyTestMode = 0; % In this mode, there are numerals in the top left of the screen, it plays one specific video in a loop,
                     % jitter reduction is disabled, and when tracking is
                     % lost the screen goes white.

if latencyTestMode
    exptName = 'latency';
else
    exptName = 'scotoma';
end
eyetrackOutputFolder = 'eyetrackData/';

screenDistance = 95; % Distance from eyes to monitor n cm
pixelsPerCm = 43.5; % Obtained by checkPixelSize
scotomaDegrees = 20; % size of scotoma in degrees of visual angle, including the ramps
% scotomaDegrees = 12; % size of scotoma in degrees of visual angle, including the ramps
scotomaPixels = visualAngleToCm(scotomaDegrees,screenDistance) * pixelsPerCm;
rampProportion = 0.3;  % the width of one blurry edge (ramp from transparency) as a proportion of the total width or height (it will scale to both)
                       % Note that a lot of the ramp will still look pretty
                       % opaque or transparent (the width is the distance
                       % from 0.01 to 0.99 opacity), so it may not look as
                       % wide as you expect.
                       
scotomaRatio = 1.22; % Ratio of the width to the height

try
    HideCursor;
    % Get the names of the videos we will be showing
% %     videoNames = ls([videoRoot '*.mov']);
% %     videoNames = strread(videoNames,'%s','delimiter','\t');

    videoNames = {'Cheese'};
Screen('Preference', 'SkipSyncTests', 0);
    Screen('Preference', 'Verbosity', 2);
    KbName('UnifyKeyNames');
    
    % Open a graphics window on the main screen
    meanLum=127;                    % mean display level 
    whichScreen=max(Screen('Screens'));
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible'); % request 32 bit per pixel for high res contrast
    win = PsychImaging('OpenWindow', whichScreen, meanLum);
    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);   
     
    % Initialize eyelink
    el=EyelinkInitDefaults(win);
    baseFileName = nameOutputFile(exptName, participantID);
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
    
    % Main trial loop
    for i = 1:length(videoOrder)
        scotomaTex = makeErfScotomaTex(win, round([scotomaPixels, scotomaPixels*scotomaRatio]), scotomaPixels*rampProportion);

        % Drift correction 
        if Eyelink('isconnected') ~= el.dummyconnected
           EyelinkDoDriftCorrection(el);
        end
        eyetrackFileName = [eyetrackOutputFolder baseFileName ' ' sprintf('%03d',i) '.mat'];
        timingInfo = playMovieWithScotoma(win, scotomaTex, el, 'cheese', eyetrackFileName, latencyTestMode); 
%         timingInfo = playMovieWithScotoma(win, scotomaTex, el, videoNames{videoOrder(i)}, eyetrackFileName, latencyTestMode); 
%         disp(allSamplesPerFrame');
        Screen('Close',scotomaTex);
        textScreen(win, 'Get ready for the next movie clip.');
    end
    
    cleanup;

catch myerr
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if it's open.
    cleanup;
    commandwindow;
    disp(sprintf('ERROR: %s', myerr.message));
    for i = 1:length(myerr.stack)
        disp(sprintf('File %s Line %d', myerr.stack(i).file, myerr.stack(i).line));
    end
end %try..catch.


function name = nameOutputFile(exptName, participantID)
name = sprintf('%s %s %s',exptName, participantID, datestr(now,'yyyy-mm-dd'));


% Cleanup routine for at the end or in case of an error
function cleanup

% finish up: stop recording eye-movements,
% close graphics window, close data file and shut down tracker
% Eyelink('Stoprecording');
% Eyelink('CloseFile');
%Eyelink('Shutdown');

% Close window:
sca;

% Restore keyboard output to Matlab:
ListenChar(0);



