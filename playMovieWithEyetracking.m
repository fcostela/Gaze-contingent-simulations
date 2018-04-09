function playMovieWithEyetracking(win, el, moviefilename, eyetrackoutputfile)
esc=KbName('ESCAPE');

vbl = Screen('Flip', win);
[movie movieduration fps imgw imgh] = Screen('OpenMovie', win, moviefilename); % Open movie file, get a handle to the movie
Screen('PlayMovie', movie, 1, 0, 1); % start playback
f = 0;
t = GetSecs;

Eyelink('startrecording');
WaitSecs(0.1);
Eyelink('Message', 'SYNCTIME'); % Mark the start of the trial in the edf file.
  
eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
if eye_used == el.BINOCULAR; % if both eyes are tracked
    eye_used = el.LEFT_EYE; % use left eye
end

eyetrackRecord.x = [];
eyetrackRecord.y = [];
eyetrackRecord.missing = [];

% Loop through the frames of the movie
while(1)
    error=Eyelink('CheckRecording');
    if(error~=0)
        Error('CheckRecording failed.');
    end
    
    % Get the next frame of the movie
    [tex pts] = Screen('GetMovieImage', win, movie);
    if tex<=0 % Run out of frames of the movie, so quit the loop
        break;
    end;
   
    srcRect = Screen(tex,'Rect');
    destRect = Screen(win,'Rect');
    % The 1.185 factor is for anamorphic stretching, which we are assuming
    % all our videos have (that is, their width in pixels is a little less
    % than it should be)
    aspectRatio = (RectWidth(srcRect)*1.185)/RectHeight(srcRect); 
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
    Screen('DrawTexture', win, tex, srcRect,destRect);
    vbl=Screen('Flip', win);
    % This line, when uncommented, overlays information about the movie clip 
    %     Screen('DrawText', win, sprintf('%s src: %d x %d dest ratio: %.2f', filename, srcRect(3), srcRect(4), RectWidth(destRect)/RectHeight(destRect)), 20, 1200, [255, 255, 255]);

    % Get the gaze location.
    % If in dummy mode, use the mouse position.
    if Eyelink('isconnected') == el.dummyconnected
        [x,y,button] = GetMouse(win);
        missing = 0;
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
            end
        end
    end
    eyetrackRecord.x = [eyetrackRecord.x x];
    eyetrackRecord.y = [eyetrackRecord.y y];
    eyetrackRecord.missing = [eyetrackRecord.missing missing];

    % Release the memory for this frame.
    Screen('Close', tex); 

    % Also stop if the escape key is pressed
    [keyIsDown,secs,keyCode]=KbCheck;
    if (keyIsDown==1 && (keyCode(esc)))
        break;
    end
    f = f+1;
end;
Eyelink('StopRecording');

disp(sprintf('Number of frames shown: %d Framerate: %.2f',f,f/(GetSecs-t)));
Screen('CloseMovie', movie); % close movie reader

% Save the eyelink data, within a struct, to a .mat file.
save(eyetrackoutputfile, 'moviefilename','eyetrackRecord');