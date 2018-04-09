function size = visualAngleToCm(angle,distanceFromMonitor)
% Take a visual angle, convert into a size on the monitor in cm based on
% distanceFromMonitor. checkPixelSize can be useful for converting between
% cm and pixels.
%
% Usage: size = visualAngleToCm(angle,distanceFromMonitor)

if nargin < 2
    distanceFromMonitor = 100;
end
% size is in cm

angle = angle / (180/pi);
angle = angle / 2; 
size = 2 * (tan(angle) * distanceFromMonitor);