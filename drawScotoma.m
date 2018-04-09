function drawScotoma(win, x, y, scotomaTex)

maskOffScrnRect = Screen(scotomaTex,'Rect');
scotomaRect=CenterRectOnPoint(maskOffScrnRect,x,y); % place scotoma rect on current mouse or eye poition
Screen('DrawTexture', win, scotomaTex,maskOffScrnRect,scotomaRect);

