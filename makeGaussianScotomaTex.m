function scotomaTex = makeGaussianScotomaTex(win, scotomaStd)

maskSize(1)=round(scotomaStd*6); % truncate at +/- 3 stdevs
maskSize(2)=round(scotomaStd*6); % truncate at +/- 3 stdevs
noiseIm=real(ifft2(fft2(rand(maskSize(1), maskSize(2))).*makeFilter(2,1,1,1,[maskSize(1), maskSize(2)])));
noiseIm=noiseIm-min(noiseIm(:));
noiseIm=255*noiseIm/max(abs(noiseIm(:)));
gaussScotoma=noiseIm; % fill with white noise
%                     gaussScotoma=rand(maskSize(1), maskSize(2), 2) *
%                     meanLum; % simulated scotoma parameters
  gaussScotoma(:,:,2)=255*Gaussian2D(scotomaStd, [maskSize(1)/2 maskSize(2)/2], [maskSize(1) maskSize(2)]);

scotomaTex=Screen('MakeTexture', win, gaussScotoma);


