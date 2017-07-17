clc
clear all
for k = 1:50
	example_generate_samples_normal;
    frame = getframe(gcf);
	M(k) = frame;
end

% figure
% movie(M,10)
myVideo = VideoWriter('./videos/normalDistTruncatedY_125.avi');
myVideo.FrameRate = 6;  % Default 30
open(myVideo);
writeVideo(myVideo, M);
close(myVideo);