function g = Gaussian2D(std,center,dimensions)

[x,y]=meshgrid(-0.5*dimensions(1):(0.5*dimensions(1)-1),-0.5*dimensions(2):(0.5*dimensions(2)-1));
 x  = x - (center(1) -0.5*dimensions(1));
 y  = y - (center(2) -0.5*dimensions(2));


% a = 1 / (2*pi*std^2);

g =  exp(-0.5*((x.^2)/(std^2)+(y.^2)/(std^2)));
% figure; surf(g)
