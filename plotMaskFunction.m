function plotMaskFunction(x, cutoff, rolloffWidth)
% 

figure;
y = 0.5 * erf((x-cutoff) / (rolloffWidth/4.6)) + 0.5;
plot (x,y);