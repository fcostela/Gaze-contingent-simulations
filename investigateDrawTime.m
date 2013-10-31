function investigateDrawTime(a)
g = a.drawEndTime(2:end)-a.flipStart(1:end-1);
figure; myhistc(g*1000,2:0.1:6)