actualTime = []
for i = 1:1000
    t = GetSecs;
    WaitSecs(0.01);
    actualTime = [actualTime GetSecs-t];
end