function highContrastScreen
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
      if ison
          Screen('FillRect', w, white);
          ison =false;
      else
          Screen('FillRect', w, black);
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
 
