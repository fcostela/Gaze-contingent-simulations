function g = Erf2D(dimensions,rolloffWidth,center)
% Makes a 2D Erf function, analogous to a 2D gaussian, making a shape that
% resembles a mountain plateau - rounded at the edges, but eventually goes
% to 0 or 1 (the range). I refer to the rolloffWidth as the distance it
% takes to go between 0 and 1, aka the sharpness of the edge. Cutoff is
% then the 50% point of the function.
%
% dimensions: a single number that represents the width that can contain
% the entire function including the rolloff.
%
% rolloffWidth: the distance to go from the 0.01 level to the 0.99 level,
% aka the blurriness of the edges. 1 is perfectly sharp edges.
%
% center: 2-element array, the numerical center of the x and y coordinates
%
% Example: g = Erf2D(200,40,[80 80]); surf(g);

% 
% cutoff = (dimensions/2 - rolloffWidth/2);
% [x,y]=meshgrid(-0.5*dimensions:(0.5*dimensions-1),-0.5*dimensions:(0.5*dimensions-1));
%  x  = x - (center(1) -0.5*dimensions);
%  y  = y - (center(2) -0.5*dimensions);
% 
% d = sqrt(x.^2 + y.^2);
% g = -0.5 * erf((d-cutoff) ./ (rolloffWidth/3.6)) + 0.5;


maxdim = max(dimensions);
cutoff = (maxdim/2 - rolloffWidth/2);
xrange = linspace(-0.5*maxdim,(0.5*maxdim)-1, dimensions(2));
yrange = linspace(-0.5*maxdim,(0.5*maxdim)-1, dimensions(1));

[x,y]=meshgrid(xrange,yrange);
 x  = x - (center(2) -0.5*dimensions(2));
 y  = y - (center(1) -0.5*dimensions(1));

d = sqrt(x.^2 + y.^2);
g = -0.5 * erf((d-cutoff) ./ (rolloffWidth/3.6)) + 0.5;


%% Uncomment these lines to get an illustration of what the function looks
% % like.
%  figure; surf(g); view(0,90); axis square
%  sampleRow = round(maxdim(1)/2);
%  figure; plot(g(sampleRow,:));