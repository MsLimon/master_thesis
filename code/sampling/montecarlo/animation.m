clc
clear all
for k = 1:50
	generate_samples;
    frame = getframe(gcf);
	M(k) = frame;
end

% figure
% movie(M,10)
myVideo = VideoWriter('./videos/MonteCarloNormalDist_5000.avi');
myVideo.FrameRate = 6;  % Default 30
open(myVideo);
writeVideo(myVideo, M);
close(myVideo);