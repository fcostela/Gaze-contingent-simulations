% MorphDemoMovie
% Hacked from PTB spinning teapot demo
% MorphDemo -- Demonstrates use of "moglmorpher" for fast morphing
% and rendering of 3D shapes. See "help moglmorpher" for info on
% moglmorphers purpose and capabilities.
% 
% This demo will load two morpheable shapes from OBJ files and then
% morph them continously into each other
%
% moglmorpher('ForceGPUMorphingEnabled', 0);

moviename= 'JULIE_14a_c.mov'; % path to movie
global win;

CellStep=16;    % grain of tesselation
sig1=45;        % starting size of bubble
MaxMag=3;       % starting magnification of bubble's peak
GlobalScale=0.03; % scaling factor for openGL

AssertOpenGL;% Is the script running in OpenGL Psychtoolbox?

screenid=max(Screen('Screens')); % choose highest screen # if multi-screen
Screen('Preference','SkipSyncTests',1); % skip synch tests

InitializeMatlabOpenGL(0,1); % initialize
 
[win , winRect] = Screen('OpenWindow', screenid, 0, [], [], []); % open screen
HideCursor;   


movie=Screen('OpenMovie', win, moviename); % open movie and start reading fames
Screen('PlayMovie', movie, 1, 1, 1); % play at standard size and speed, with sound

KbName('UnifyKeyNames'); % same response keys across platforms
rightKey = KbName('RightArrow'); % arrow response keys adjust bubble params
leftKey = KbName('LeftArrow');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
escKey = KbName('ESCAPE'); % restore defaults

texid = Screen('GetMovieImage', win, movie); % grab 1st movie frame (to set up size parameters)
[m n] = Screen('WindowSize', texid); % size of source movie frame in pixels
[gltexid gltextarget] = Screen('GetOpenGLTexture', win, texid); %operate on texture in video graphics

[X Y]=meshgrid([0:CellStep:m],[0:CellStep:n]); % create mesh for magnification surface
xC=X(:); % convert to vectors
yC=Y(:);
xA3=-(xC'-m/2) ;
yA3=yC'-n/2 ;
tri = delaunay(xA3,yA3); % generate triangular mesh for magnification suface
objs{1}.texcoords = [xC(:)'; yC(:)']; % parameters of magnification surface
objs{1}.quadfaces=[];
objs{1}.normals=[];
objs{1}.vertices=[xA3; yA3; ones(1,length(xA3))];
objs{1}.faces=tri'-1;  

x1=objs{1}.vertices(1,:); % source vertices for image projection
y1=objs{1}.vertices(2,:);

sObj=objs{1}; % create source and destination objects
objs{2}=objs{1};

Screen('BeginOpenGL', win);
glBindTexture(gltextarget, gltexid);% Setup texture mapping for our face texture:
glEnable(gltextarget);
glTexEnvfv(GL.TEXTURE_ENV,GL.TEXTURE_ENV_MODE,GL.MODULATE);    % Choose texture application function: It shall modulate the light reflection properties of the the objects surface:

moglmorpher('reset');% Reset moglmorpher:
moglmorpher('ForceGPUMorphingEnabled', 0);
for i=1:size(objs,2);% Add the OBJS to moglmorpher for use as morph-shapes:
    meshid(i) = moglmorpher('addMesh', objs{i});
end

 ar=winRect(4)/winRect(3);% Get the aspect ratio of the screen, we need to correct for non-square pixels if we want undistorted displays of 3D objects:

glEnable(GL.LIGHT0);% Enable the first local light source GL.LIGHT_0. Each OpenGL implementation is guaranteed to support at least 8 light sources. 
glEnable(GL.LIGHTING);

glMatrixMode(GL.PROJECTION);% Set projection matrix: This defines a perspective projection,corresponding to the model of a pin-hole camera - which is a goodapproximation of the human eye and of standard real world cameras -- well, the best aproximation one can do with 3 lines of code ;-)

gluPerspective(25.0,1/ar,0.1,200.0);% Field of view is +/- 25 degrees from line of sight. Objects close than 0.1 distance units or farther away than 200 distance units get clipped away, aspect ratio is adapted to the monitors aspect ratio:

glMatrixMode(GL.MODELVIEW);% Setup modelview matrix: This defines the position, orientation and looking direction of the virtual camera:

glLoadIdentity;

glPointSize(1.0);% Set size of points for drawing of reference dots
glColor3f(0,0,0);
glLineWidth(1.0);% Set thickness of reference lines:

glPolygonOffset(0, -5);% Add z-offset to reference lines, so they do not get occluded by surface
glEnable(GL.POLYGON_OFFSET_LINE);

Screen('EndOpenGL', win);% Finish OpenGL setup and check for OpenGL errors:

ifi = Screen('GetFlipInterval', win);% Retrieve duration of a single monitor flip interval: Needed for smooth animation.

vbl=Screen('Flip', win);% Initially sync us to the VBL:

waitframes = 2;

% error('HELLO!');
t = GetSecs;% Animation loop: Run until mouse press or one minute has elapsed...
while ((GetSecs - t) < 240)

    [mx, my, buttons]=GetMouse(screenid); % current mouse location (or eye if gaze-contingent)
    mx1=-(mx-(winRect(3)/2));
    my1=((winRect(4)/2)-my);
    
    [keyIsDown,timeSecs,keyCode] = KbCheck;         % check if user adjusts settings
    if keyCode(upKey); MaxMag=MaxMag*1.1 ;   end    % increase magnification
    if keyCode(downKey); MaxMag=MaxMag/1.1 ;   end  % reduce magnification
    if keyCode(leftKey); sig1=sig1/1.1 ;   end      % increase magnification area
    if keyCode(rightKey); sig1=sig1*1.1 ;   end     % reduce magnification area
    if keyCode(escKey); sig1=45; MaxMag=3;  end     % restore defaults;


    FlushEvents('keyDown');

    dist1=sqrt((x1-mx1).^2+(y1-my1).^2); % create bubble on mouse (eye) position)
    scalar1=(1+(MaxMag-1).*exp(-(dist1.^2)./(2*sig1.^2)));
    mag=dist1.*scalar1;
    ang1=atan2((y1-my1),(x1-mx1));
    x3=mx1+(mag.*cos(ang1));
    y3=my1+(mag.*sin(ang1));

    sObj.vertices=[-x3;y3;ones(1,length(x3))]; % update triangultion vertices
    meshid(2) = moglmorpher('addMesh', sObj);
        
    texid = Screen('GetMovieImage', win, movie); % read next movie frame
    [gltexid gltextarget] = Screen('GetOpenGLTexture', win, texid);
    Screen('BeginOpenGL', win);

%     tic
%    for p = 1:100   
    glBindTexture(gltextarget, gltexid);
    glEnable(gltextarget);
  
    glScalef(GlobalScale,GlobalScale,GlobalScale);
         moglmorpher('render');
%     end
%     toc
    
    glLoadIdentity;

    gluLookAt(-0, 0, 35, 0, 0, 0, 0, 1, 0);

     glClear(GL.DEPTH_BUFFER_BIT);
 

    Screen('EndOpenGL', win);

    Screen('DrawingFinished', win);
    moglmorpher('computeMorph', [1 0]);
 
    if any(buttons)
        break;
    end
    
    vbl = Screen('Flip', win, vbl + (waitframes - 0.5) * ifi);
end

Screen('CloseAll');% Close onscreen window and release all other ressources:
ShowCursor;

return

