function highContrastDot
    screenNumber=max(Screen('Screens'));

    % Open a double buffered fullscreen window.
    [w, wRect]=Screen('OpenWindow',screenNumber);

    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    gray=GrayIndex(screenNumber); % returns as default the mean gray value of screen

    % Set background color to gray:
    backgroundcolor = black;
hidecursor
    ison = true;
    x = 0;
    tic;
    while 1
    [mx, my, buttons]=GetMouse;
              Screen('FillRect', w, black);
      if ison
          Screen('FillOval', w, white, [20 20 30 30]);
          ison =false;
      else
          Screen('FillOval', w, black, [20 20 30 30]);
          ison = true;
      end
      
      Screen('Flip', w);
              % Abort demo on keypress our mouse-click:
        if KbCheck | find(buttons) % break out of loop
            break;
        end;
        x = x+1;
    end
    showcursor
    Screen('CloseAll');
    toc
    disp(x);
 
