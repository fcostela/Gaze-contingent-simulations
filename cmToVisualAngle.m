function angle = cmToVisualAngle(size,distanceFromMonitor)
% Take a size on the monitor in cm, convert to a visual angle using
% distanceFromMonitor. checkPixelSize can be useful for converting between
% cm and pixels.
%
% Usage: angle = cmToVisualAngle(size,distanceFromMonitor)

if nargin < 2
    distanceFromMonitor = 65;
end
% size is in cm

angle = atan((size/2) / distanceFromMonitor);
angle = angle * 2;
angle = angle * (180 / pi); % convert from radians to degrees
