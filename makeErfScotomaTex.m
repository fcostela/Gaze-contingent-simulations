function scotomaTex = makeErfScotomaTex(win, dimensions, rolloffWidth)

if length(dimensions) == 1    dimensions(2) = dimensions(1); end;
maskSize(1)=dimensions(1); 
maskSize(2)=dimensions(2); 
noiseIm=real(ifft2(fft2(rand(maskSize(1), maskSize(2))).*makeFilter(2,1,1,1,[maskSize(1), maskSize(2)])));
noiseIm=noiseIm-min(noiseIm(:));
noiseIm=255*noiseIm/max(abs(noiseIm(:)));
erfScotoma=noiseIm; % fill with white noise
 
erfScotoma(:,:,2)=255*Erf2D(dimensions, rolloffWidth, [maskSize(1)/2 maskSize(2)/2]);

scotomaTex=Screen('MakeTexture', win, erfScotoma);

% 
% noiseIm=real(ifft2(ones(maskSize(1), maskSize(2)).*makeFilter(2,1,1,1,[maskSize(1), maskSize(2)])));
% noiseIm=noiseIm-min(noiseIm(:));
% noiseIm=255*noiseIm/max(abs(noiseIm(:)));
% 
% 
% noiseIm=real(ifft2(fft2(rand(maskSize(1), maskSize(2)))));
% noiseIm=noiseIm-min(noiseIm(:));
% noiseIm=255*noiseIm/max(abs(noiseIm(:)));

% freqDomain = ones(maskSize(1), maskSize(2)).*makeFilter(2,1,1,0.5,[maskSize(1), maskSize(2)]);
% % freqDomain = fft2(rand(maskSize(1), maskSize(2))).*makeFilter(2,1,1,1,[maskSize(1), maskSize(2)]);
% f = real(fftshift(freqDomain));
%  figure; surf(f(1:10:end,1:10:end)); view([0 90])
% noiseIm=real(ifft2(freqDomain));
% noiseIm=noiseIm-min(noiseIm(:));
% noiseIm=255*noiseIm/max(abs(noiseIm(:)));
% % figure; imagesc(noiseIm); colormap(gray)
%  figure; surf(noiseIm(100:10:(end-100),100:10:(end-100))); view([0 90])
