function timingInfo = playMovieWithScotoma(win, scotomaTex, el, moviefilename, eyetrackoutputfile, latencyTestMode)
Screen('Preference', 'TextRenderer', 0);
esc=KbName('ESCAPE');
if ~exist('latencyTestMode')
    latencyTestMode = 0;
end
% if latencyTestMode
%     moviefilename = '/Users/MacScribe/Dropbox/Artificial scotoma/JULIE_14a_c.mov';
%     moviefilename = '/Volumes/pelilab/Images & Videos/Videos/TV with LV/Compressed Clips/JULIE_14a_c.mov';
%     moviefilename = '/Volumes/pelilab/Images & Videos/Videos/TV with LV/Compressed Clips/Cloud_9a_c.mov';
%     moviefilename = '/Users/woodslab/Desktop/Defocus Video Clips/Cloud_9a_c 2.mov';
%     moviefilename = '/Users/danielsaunders/Free norm - video clips/Cloud_9a.mov';
% moviefilename = '/Users/woodslab/Temporary support/JULIE_18a.mov';
% moviefilename = '/Users/woodslab/Temporary support/JULIE_18a_090_25.mov';
% moviefilename = '/Users/woodslab/Temporary support/EASTE_2a.mov';
moviefilename = '/Users/woodslab/Desktop/uncompressed_norming_clips/FREED_16a.mov';
% moviefilename = '/Users/woodslab/Desktop/uncompressed_norming_clips/Cloud_9a.mov';
% moviefilename = '/Users/woodslab/Temporary support/EASTE_2a_090_25.mov';
loopMovie = 1;

% else
%     loopMovie = 0;
% end
fontColor = [255 255 255];
font = 'Helvetica';
fontSize =300;
Screen('TextFont',win, font);
Screen('TextSize',win, fontSize);
Screen('TextStyle', win, 1); % Bold

vbl = Screen('Flip', win);
[movie movieduration fps imgw imgh] = Screen('OpenMovie', win, moviefilename); % Open movie file, get a handle to the movie

Screen('PlayMovie', movie, 1, loopMovie, 1); % start playback
f = 0;
t = GetSecs;

tempEdfFile = sprintf('arts%02d.edf',floor(rand*100));
Eyelink('Openfile', tempEdfFile);
Eyelink('startrecording');
WaitSecs(0.1);
Eyelink('Message', 'SYNCTIME'); % Mark the start of the trial in the edf file.

eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
if eye_used == el.BINOCULAR; % if both eyes are tracked
    eye_used = el.LEFT_EYE; % use left eye
end
if latencyTestMode
    eyeMovementThreshold = 0;
else
    eyeMovementThreshold = 50;
end

timingInfo.loopStart = [];
timingInfo.eyeSampleTime = [];
timingInfo.drawStartTime = [];
timingInfo.drawEndTime = [];
timingInfo.flipStart = [];
timingInfo.flipEnd = [];
timingInfo.postFlipTime = [];

eyetrackRecord.x = [];
eyetrackRecord.y = [];
eyetrackRecord.t = [];
scotomaX = -1000; scotomaY = -1000;
eyetrackRecord.missing = [];
waitForImage = 0;
% Loop through the frames of the movie
eyetrackSamplesPerFrame = 0;
allSamplesPerFrame = [];
imageIndex = 1;
ison = false;

while(1)
    timingInfo.loopStart = [timingInfo.loopStart GetSecs];
    error=Eyelink('CheckRecording');
    if(error~=0)
        Error('CheckRecording failed.');
    end
    
    % Get the next frame of the movie
    [tex pts] = Screen('GetMovieImage', win, movie, waitForImage);
    if tex<0 % Run out of frames of the movie, so quit the loop
        break;
    end;
    
    if tex>0 % There was a new frame available
        if exist('movieFrame')
            Screen('Close', movieFrame);
        end
        movieFrame = tex;
    end
    
    % Draw the existing frame whether or not it is available (will act as
    % the background for the scotoma)
    srcRect = Screen(movieFrame,'Rect');
    destRect = Screen(win,'Rect');
    %     % The 1.185 factor is for anamorphic stretching, which we are assuming
    %     % all our videos have (that is, their width in pixels is a little less
    %     % than it should be)
        aspectRatio = (RectWidth(srcRect)*1.185)/RectHeight(srcRect);
%     aspectRatio = (RectWidth(srcRect)*1)/RectHeight(srcRect);
    % This code makes sure the video fills as much of the screen as
    % possible, and displays at its proper aspect ratio.
    if aspectRatio < 16/9
        destRect(3) = destRect(4)*aspectRatio;
    elseif aspectRatio > 16/9
        destRect(4) = destRect(3)/aspectRatio;
    end
    destRect = CenterRect(destRect,Screen(win, 'Rect'));
    % Draw the frame on the screen
    Screen('FillRect',win,[0 0 0]);
%%%    Screen('DrawTexture', win, movieFrame, srcRect,destRect);
    
        WaitSecs(0.009);  % This line to test whether adding a delay here
    %     can reduce the latency. It can! 
    newEyelinkData = false;
    % Get the gaze location.w
    % If in dummy mode, use the mouse position.
    if Eyelink('isconnected') == el.dummyconnected
        timingInfo.eyeSampleTime = [timingInfo.eyeSampleTime GetSecs];
        [x,y,button] = GetMouse(win);
        missing = 0;
        newEyelinkData = true;
    else
        if Eyelink( 'NewFloatSampleAvailable') > 0
            % get the sample in the form of an event structure
            timingInfo.eyeSampleTime = [timingInfo.eyeSampleTime GetSecs];
            evt = Eyelink( 'NewestFloatSample');
            if eye_used ~= -1 % do we know which eye to use yet?
                % if we do, get current gaze position from sample
                x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                y = evt.gy(eye_used+1);
                t = evt.time;
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
        timingInfo.drawStartTime = [timingInfo.drawStartTime GetSecs];
%         [x,y,buttons] = GetMouse;
%         if any(buttons) || (missing && latencyTestMode)
%             Screen('FillRect',win,[255 255 255]);
%         else
            
            if ison && latencyTestMode
                Screen('FillRect',win, [255 255 255],[0 0 2560 20]);  % Put a white bar at the top of the monitor on every other frame to mark the beginning of the refresh
            end
            eyetrackSamplesPerFrame = eyetrackSamplesPerFrame + 1;
            if tex>0 % There was a new frame available
                allSamplesPerFrame = [allSamplesPerFrame; eyetrackSamplesPerFrame];
                eyetrackSamplesPerFrame = 0;
                % Release the memory for this frame.
                %  Screen('Close', tex);
            end
            x = x;
            y = y;
            eyetrackRecord.x = [eyetrackRecord.x x];
            eyetrackRecord.y = [eyetrackRecord.y y];
            eyetrackRecord.t = [eyetrackRecord.t t];
            eyetrackRecord.missing = [eyetrackRecord.missing missing];
            
            % Apply some stabilization: don't move the scotoma if the
            % subject
            % is blinking, and don't move it if the new gaze position is less
            % than 10 pixels away (indicating probable microsaccades)
            if ~missing
                offset = sqrt((x-scotomaX)^2 + (y-scotomaY)^2);
                if offset > eyeMovementThreshold && offset < 10000
                    scotomaX = x;
                    scotomaY = y;
                end
            end
            
            % Draw the scotoma (by copying it from the texture onto the screen)
            maskOffScrnRect = Screen(scotomaTex,'Rect');
            scotomaRect=CenterRectOnPoint(maskOffScrnRect,scotomaX,scotomaY); % place scotoma rect on current mouse or eye poition
% %                                 drawScotoma(win,x,y);
            
            %              for i = 1:30
        %%%Screen('DrawTexture', win, scotomaTex,maskOffScrnRect,scotomaRect);
            %              end
            
            if latencyTestMode
%                 Screen('DrawText', win, sprintf('%.0f',scotomaX), 0, 0, fontColor);
                DrawFormattedText(win, sprintf('%4.0f, %.0f',scotomaX, scotomaY), 0, 0, fontColor);
            end
            
            timingInfo.drawEndTime = [timingInfo.drawEndTime GetSecs]; 
        drawCross(win, 1280, 720, 50)
        
        [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed]=Screen('Flip', win);
        timingInfo.flipStart = [timingInfo.flipStart VBLTimestamp];
        timingInfo.flipEnd = [timingInfo.flipEnd FlipTimestamp];
        timingInfo.postFlipTime = [timingInfo.postFlipTime GetSecs];
        ison = ~ison;
    end
    
    % This line, when uncommented, overlays information about the movie clip
    %     Screen('DrawText', win, sprintf('%s src: %d x %d dest ratio: %.2f', filename, srcRect(3), srcRect(4), RectWidth(destRect)/RectHeight(destRect)), 20, 1200, [255, 255, 255]);
    %
    %     if tex > 0 % New frame was availabel.
    %         imageArray=Screen('GetImage', win);
    %         imwrite(imageArray, sprintf('screencap%04d.jpg',imageIndex),'JPEG','Quality',100);
    %         imageIndex = imageIndex+1;
    %     end
    % % tic
    % Also stop if the escape key is pressed
    [keyIsDown,secs,keyCode]=KbCheck;
    if (keyIsDown==1 && keyCode(esc))
        save(eyetrackoutputfile, 'moviefilename','eyetrackRecord');
        Eyelink('StopRecording');
        Screen('CloseMovie', movie); % close movie reader
        Eyelink('ReceiveFile');
        return;
        %        error('Escape pressed');
    end
    f = f+1;
end;
Eyelink('StopRecording');

%disp(sprintf('Number of frames shown: %d Framerate: %.2f',f,f/(GetSecs-t)));
Screen('CloseMovie', movie); % close movie reader

% Save the eyelink data, within a struct, to a .mat file.
save(eyetrackoutputfile, 'moviefilename','eyetrackRecord');


end

function drawCross(win, x, y, crossDiameter)
if ~exist('crossDiameter')
    crossDiameter = 15;
end
colour = [255 255 0];
penwidth = 4;
Screen('Drawline',win, colour, x, y-(crossDiameter/2), x, y+(crossDiameter/2), penwidth);
Screen('Drawline',win, colour, x-(crossDiameter/2), y, x+(crossDiameter/2), y, penwidth);
end