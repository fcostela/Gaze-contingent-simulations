function y = saccadefun(t, xf)

y = abs(xf(1).*(1-exp(-((t./xf(2)).^xf(3)))));
end