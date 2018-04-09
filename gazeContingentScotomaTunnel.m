function gazeContingentScotomaTunnel(participantID, videoOrder)
% Play a set of movies with artificial gaze-contingent scotoma
% superimposed. We detect when a saccade is in progress,
% and uses the existing eyetracking data from the saccade to predict where
% the eye will be at a certain point in the future (thus compensating for
% system latency).
%
% Input:
% participantID:    The id of the participant, to put in the output filenames.
% videoOrder:       a list of videos to play, by video ids (1-200)
%
% Output: 
% A file in the eyetrackData folder, containing records of the eyetracking
% data, the prediction, and the timing. Also potentially an edf file.
%
% Usage: gazeContingentScotoma(participantID, videoOrder)

Eyelink('Shutdown');
Eyelink('Initialize');
if ~exist('participantID')  participantID = ''; end;
if ~exist('videoOrder')
    videoOrder = 1;
end
% videoRoot = '/Volumes/pelilab/Images & Videos/Videos/TV with LV/Compressed Clips/';  % Where all the videos are located
% videoRoot = '/Users/danielsaunders/Free norm - video clips/';
dummymode = 0; % In this mode, we don't access the eyetracker, but rather get a simulated gaze location from the mouse coordinates.
gceParams.predictionOff = 0;
if gceParams.predictionOff   % In this mode, we never try to predict saccades in flight.
    resp = input('Prediction for this run is off. Is that ok? (y/n)','s');
    if resp ~= 'y'
        return;
    end
end

% These parameters control how much time to allow between the end of
% eyetrack data collection and calling the flip. If it's too small, we'll
% start missing flip deadlines. Currently optimized for a particular 120Hz
% CRT setup.
gceParams.inSaccadeBuffer = 4.7/1000;
gceParams.outOfSaccadeBuffer = 3.5/1000; %4.8/1000;

% Setting the drawFunctionHandle to this is what lets the gaze contingent
% engine draw the proper thing (i.e. the movie frame and the scotoma
% overlay)
drawFunctionHandle = @videoScotomaDrawFunction2;

% Set up the output stuff
exptName = 'scotomaPred';
baseFileName = nameOutputFile(exptName, participantID);
eyetrackOutputFolder = 'eyetrackData/';

% Set up more parameters
screenDistance = 95; % Distance from eyes to monitor n cm
pixelsPerCm =  26.7; % For the MultiSync monitor at 1024x768 % 43.5; % Obtained by checkPixelSize
scotomaDegrees = 5; % size of scotoma in degrees of visual angle, including the ramps
% scotomaDegrees = 12; % size of scotoma in degrees of visual angle, including the ramps
scotomaPixels = visualAngleToCm(scotomaDegrees,screenDistance) * pixelsPerCm;
rampProportion = 0.3;  % the width of one blurry edge (ramp from transparency) as a proportion of the total width or height (it will scale to both)
% Note that a lot of the ramp will still look pretty
% opaque or transparent (the width is the distance
% from 0.01 to 0.99 opacity), so it may not look as
% wide as you expect.
scotomaRatio = 1.22; % Ratio of the width to the height

% use spiral targets?
res=input('Use spiral calibration targets? (y/n) >','s');
if strcmp(res,'y')
   spiralCal=true;
else
   spiralCal=false;
end

try
    HideCursor;
    % Get the names of the videos we will be showing
    % %     videoNames = ls([videoRoot '*.mov']);
    % %     videoNames = strread(videoNames,'%s','delimiter','\t');
    
    if strfind(pwd,'MacScribe')
         videoNames = {'/Users/MacScribe/Dropbox/Artificial scotoma/APPAL_7a_c 2.mov'};
    elseif strfind(pwd,'woodslab')
       videoNames = {'/Users/woodslab/Dropbox/Artificial scotoma/APPAL_7a_c 2.mov'};
    else
        videoNames = {'/Users/woodslab/Dropbox/Artificial scotoma/APPAL_7a_c 2.mov'};
    end
    
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
    EyelinkInit();
    el=EyelinkInitDefaults(win);
    if spiralCal
        el.callback = [];  %%% This line, when uncommented, has the effect of switching the setup and calibration display code
                           %%% over to manual, e.g. drawn using m files rather than the callbacks,
                           %%% as is necessary for having animated spirals for calibration targets.
        % Set parameters for spiral calibration targets
        el.spiralParamB = 0.15; % The higher this is, the looser the spiral
        el.targetWidth = 150;   % In pixels
        el.spiralSpeed = 1;     % Number of complete rotations per second
        el.slideSpeed = 400;
    end
    
    if ~EyelinkInit(dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    
    
    
    % Calibrate the eye tracker (if not in dummy mode)
    if Eyelink('isconnected') ~= el.dummyconnected
        EyelinkDoTrackerSetup(el);
    end
    drawFunctionData.loopMovie = 1;  % LOOP MOVIE
    % Main trial loop
    for i = 1:length(videoOrder)
        % Make the scotoma texture.
        drawFunctionData.scotomaTex = makeErfScotomaTex(win, round([scotomaPixels, scotomaPixels*scotomaRatio]), scotomaPixels*rampProportion);
        drawFunctionData.moviefilename = videoNames{videoOrder(i)};
        
        % Drift correction
%         if Eyelink('isconnected') ~= el.dummyconnected
%             EyelinkDoDriftCorrection(el);
%         end
        eyetrackFileName = [eyetrackOutputFolder baseFileName ' ' sprintf('%03d',i) '.mat'];
        
        playGazeContingentTrial(drawFunctionHandle, drawFunctionData, gceParams, win, el, eyetrackFileName);
 
        Screen('Close',drawFunctionData.scotomaTex);
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



