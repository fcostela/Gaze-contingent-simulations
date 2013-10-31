d = a.flipStart(2:end)-a.flipStart(1:end-1);
disp(sprintf('Number missed: %d', length(find(d > 0.02))));
disp(sprintf('Proportion missed (out of %d): %.3f', length(d),length(find(d > 0.02))/length(d)));
