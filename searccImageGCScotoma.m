% Program to examine the impact of central or peripheral scotomas on visual search in
% natural images. 
% observer searches for object and clicks mouse on it
% eye tracker used to record eye movements and/or to maintain gaze
% contingent, central or peripheral artificial scotoma.

clear all;
sName=input('Subject''s Initials: ', 's');                     % subject initials
gcScotoma=input('Gaze Contingent Scotoma (0 - No 1 - Yes): ');                     % subject initials
eyeTracking=input('Record Gaze (0 - No 1 - Yes): ');                     % subject initials

whichScreen=max(Screen('Screens'));            % display # for stimuli
fixSize=64;                      % size of fixation line (pixels)
meanLum=127;                    % mean display level 
scotomaStd=[256 128 64 32 -32 -64 -128 -256]*gcScotoma; % size of scotoma - positive for central, negaive for peripheral
scotomaRadial=[0 0 0 0 0 0 0 0]; % radial scotoma 0=no 1=yes
xOff=0; % no correction of mouse position on multiple displays...  
nTrials=length(scotomaStd);

ListenChar(2);                                                              % turn off echoing keypresses in MatLab

testSName=sName;

try     
     if eyeTracking; % set up and calibrate eye tracker
        if (Eyelink('Initialize') ~= 0)	return; % check eye tracker is live
            fprintf('Problem initializing eyelink\n');
        end;
        xOff=0;
        [window winRect] = Screen('OpenWindow', whichScreen, 127, []); % open simple window for eye track calibration

        el=EyelinkInitDefaults(window); % initialize eye tracker default settings
        if ~EyelinkInit(1)
            fprintf('Eyelink Init aborted.\n');
            cleanup;  % cleanup function
            return;
        end
        el.calibrationtargetsize=5; % increase calibration target size (default is 2.5% of screen size)        
        Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
        EyelinkDoTrackerSetup(el);
     
        eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
        if eye_used == el.BINOCULAR; % if both eyes are tracked
           eye_used = el.LEFT_EYE; % use left eye
        end
        Screen('Close', window);
     end

    HideCursor;
    Screen('Preference','SkipSyncTests', 1); % set up experimental screen with alpha blending etc (eye tracker does not accept this mode yet)
    Screen('Preference','VisualDebugLevel', 1);
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible'); % request 32 bit per pixel for high res contrast
    [window winRect] = PsychImaging('OpenWindow', whichScreen, meanLum);
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    [scrnWidth, scrnHeight]=Screen('WindowSize', window); % screen co-ordinates
    fixX=Randi(scrnWidth);
    fixY=Randi(scrnHeight);
    fixCoords=SetRect(0,0,fixSize,fixSize);
    fixRect=CenterRectOnPoint(fixCoords,fixX, fixY); % rect coorrdinates for stimuli and fixation point

    Screen(window,'TextSize',20);                           % write message on screen to observer
    Screen(window,'TextFont','Arial');
    textToObserver=sprintf('Screen Parameters %d by %d pixels at %3.2f Hz. Click Mouse to start, then search for target an click mouse on it', winRect(3)-winRect(1),winRect(4)-winRect(2), Screen('FrameRate',window));
    Screen('DrawText', window, textToObserver, 100, 100, 0, 128);

    screen(window,'FillOval',[255 255 0],fixRect);
 
    Screen(window, 'Flip');
    
    [mx,my,buttons] = GetMouse; % wait for mouse button press and release to start experiment
    while any(buttons) % if already down, wait for release
        [mx,my,buttons] = GetMouse;
    end
    while ~any(buttons) % wait for press
        [mx,my,buttons] = GetMouse;
    end
    while any(buttons) % wait for release
        [mx,my,buttons] = GetMouse;
    end    

    for condNo=1:nTrials

        if abs(scotomaStd(condNo))>0 % there is a scotoma
            gmcScotoma=1;
            if scotomaRadial(condNo) % radial scotoma
                maskSize=2*[scrnHeight scrnWidth]; % twice the hight and width of the screen
                noiseIm=real(ifft2(fft2(rand(maskSize(1), maskSize(2))).*makeFilter(2,1,1,1,[maskSize(1), maskSize(2)])));
                noiseIm=noiseIm-min(noiseIm(:));
                noiseIm=255*noiseIm/max(abs(noiseIm(:)));
                gaussScotoma=noiseIm; % fill with white noise                
%                 gaussScotoma=rand(maskSize(1), maskSize(2), 2) * meanLum; % fill with white noise
                [X,Y]=meshgrid(-maskSize(2)/2:-maskSize(2)/2+maskSize(2)-1,-maskSize(1)/2:-maskSize(1)/2+maskSize(1)-1);                      % 2D matrix of radial distances from centre
                radDist=(X.^2+Y.^2).^0.5;                                                                                   % radial distance from centre
                angDist=atan2(-Y, X);                                                               % orientation filter - angular dist
                sintheta = sin(angDist); 
                costheta = cos(angDist);
                ds = sintheta * cosd(scotomaStd(condNo)) - costheta * sind(scotomaStd(condNo));                                 % Difference in sine
                dc = costheta * cosd(scotomaStd(condNo)) + sintheta * sind(scotomaStd(condNo));                                 % Difference in cosine
                dtheta = abs(atan2(ds,dc));                                                         % Absolute angular distance
                scotomaProfile=exp((-dtheta.^2) / (2 * (pi/4).^2)).*(1-Gaussian2D(32, [maskSize(1)/2 maskSize(2)/2], [maskSize(1) maskSize(2)]));
                gaussScotoma(:,:,2)=255*scotomaProfile;
            else % circular scotoma
                if scotomaStd(condNo)<0 % peripheral scotoma - large mask
                    maskSize=2*[scrnHeight scrnWidth]; % twice the hight and width of the screen
                    noiseIm=real(ifft2(fft2(rand(maskSize(1), maskSize(2))).*makeFilter(2,1,1,1,[maskSize(1), maskSize(2)])));
                    noiseIm=noiseIm-min(noiseIm(:));
                    noiseIm=255*noiseIm/max(abs(noiseIm(:)));
                    gaussScotoma=noiseIm; % fill with white noise                
%                     gaussScotoma=rand(maskSize(1), maskSize(2), 2) * meanLum; % simulated scotoma parameters
                    gaussScotoma(:,:,2)=255*(1-(Gaussian2D(abs(scotomaStd(condNo)), [maskSize(1)/2 maskSize(2)/2], [maskSize(1) maskSize(2)])));
                else % central scotoma - small mask
                    maskSize(1)=round(scotomaStd(condNo)*6); % truncate at +/- 3 stdevs
                    maskSize(2)=round(scotomaStd(condNo)*6); % truncate at +/- 3 stdevs
                    noiseIm=real(ifft2(fft2(rand(maskSize(1), maskSize(2))).*makeFilter(2,1,1,1,[maskSize(1), maskSize(2)])));
                    noiseIm=noiseIm-min(noiseIm(:));
                    noiseIm=255*noiseIm/max(abs(noiseIm(:)));
                    gaussScotoma=noiseIm; % fill with white noise                
%                     gaussScotoma=rand(maskSize(1), maskSize(2), 2) * meanLum; % simulated scotoma parameters
                    gaussScotoma(:,:,2)=255*Gaussian2D(scotomaStd(condNo), [maskSize(1)/2 maskSize(2)/2], [maskSize(1) maskSize(2)]);
                end
            end
            maskTex=Screen('MakeTexture', window, gaussScotoma);
            maskOffScrnRect=SetRect(0,0,maskSize(2),maskSize(1));
            maskOnScrnRect=CenterRect(maskOffScrnRect,winRect);
        else
            gmcScotoma=0; % no scotoma this condition
        end
       
 expIm=imread('/Users/danielsaunders/Pictures/Carmanah-Valley-Vancouver-Island-British-Columbia-Canada.jpg'); % some image to show
 
            expImSize=size(expIm); % image size
            scaleFactor=min(scrnHeight/expImSize(1), scrnWidth/expImSize(2)); % how much to reduce image to fit on screen without stretching
            expIm=imresize(expIm, scaleFactor); % scale image up or down to fill screen

            stimTex=Screen('MakeTexture', window, expIm);
            expImSize=size(expIm); % image size after scaling to fill screen
            offScreenRect=[0 0 expImSize(2) expImSize(1)]; % offscreen co-ordinates of search image
            onScreenRect=CenterRect(offScreenRect,winRect); % rect coorrdinates for stimuli and fixation point

            if eyeTracking; % start recording
                edfFile='demo.edf';
                Eyelink('Openfile', edfFile)
                Eyelink('StartRecording');  
                Eyelink('Message', 'SYNCTIME'); % mark zero-plot time in data file

                eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
                if eye_used == el.BINOCULAR; % if both eyes are tracked
                    eye_used = el.LEFT_EYE; % use left eye
                end
            end

            if gmcScotoma==0; % if no scotoma, only draw the image once, not every frame
                Screen('DrawTexture', window, stimTex,offScreenRect,onScreenRect); % put image on screen
                Screen('Flip',window);                                      % flip to buffered image
            end
            scotomaXLast=0;   % set default mouse/scotoma centre to screen centre
            scotomaYLast=0;
            tic;
            buttons=0;  % clear button presses
            while all(buttons==0) % while buttons not pressed, keep getting mouse position
                [mouseX, mouseY, buttons]=GetMouse; % get mouse position and buttons
                Screen('DrawTexture', window, stimTex,offScreenRect,onScreenRect); % put image on screen
                if gmcScotoma==1  % gaze/mouse-contingent scotoma at last moment before positioning the occluder, get latest eye position    
                    if eyeTracking; % start recording
                        error=Eyelink('CheckRecording'); % check that Eyelink is still recording
                        if(error~=0); break; end

                        if Eyelink('NewFloatSampleAvailable') > 0; % get the sample in the form of an event structure
                            evt = Eyelink('NewestFloatSample');
                            if eye_used ~= -1 % do we know which eye to use yet?
                                eyeX = evt.gx(eye_used+1);  % if we do, get current gaze position from sample
                                eyeY = evt.gy(eye_used+1);% +1 as we're accessing MATLAB array
                                if eyeX~=el.MISSING_DATA && eyeY~=el.MISSING_DATA && evt.pa(eye_used+1)>0; % do we have valid data and is the pupil visible?
                                    scotomaX=eyeX;
                                    scotomaY=eyeY;
                                end % if valid data
                            end % if recorded eye known
                        end % if new data sample
                    else % not eye tracking - use mouse
                        scotomaX=mouseX;
                        scotomaY=mouseY;                        
                    end % if eye tracking
                    
                    if scotomaX>scrnWidth; scotomaX=scrnWidth;end
                    if scotomaX<0; scotomaX=0;end
                    if scotomaY>scrnHeight; scotomaY=scrnHeight;end
                    if scotomaY<0; scotomaY=0;end

                    maskOnScrnRect=CenterRectOnPoint(maskOffScrnRect,scotomaX+xOff,scotomaY); % place scotoma rect on current mouse or eye poition
                    Screen('DrawTexture', window, maskTex,maskOffScrnRect,maskOnScrnRect);
                end       
                cursorOnScrnRect=CenterRectOnPoint(fixCoords,mouseX+xOff,mouseY); % place scotoma rect on current mouse or eye poition
                Screen(window,'FillOval',[255 0 0],cursorOnScrnRect);
                Screen('Flip',window);                                      % flip to buffered image

             end % trial over when mouse button pressed
             toc; % duration of trial

             if eyeTracking; % stop recording
                Eyelink('StopRecording');
                Eyelink('CloseFile');
                etDataFilePath=sprintf('%sCond%dTrial%dETData.edf', testSName, condNo, trialCountRecord(condNo)+1); % write image file path
                Eyelink('ReceiveFile',edfFile, etDataFilePath);
             end

            if buttons(3); break; end
            
            Screen('Close', stimTex);
            Priority(0);                % return to low priority

        if(gmcScotoma);  Screen('Close', maskTex); end
        if buttons(3); break; end
    end

 if eyeTracking; % start recording
     Eyelink('ShutDown');
 end

Screen('CloseAll');
ShowCursor;
ListenChar(1);                                                              % turn on echoing keypresses in MatLab

catch
    Screen('CloseAll');     % safe escape mode to prevent nasty crash
    Priority(0);
    ShowCursor;
    ListenChar(1);
    rethrow(lasterror);
end


