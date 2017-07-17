clc
clear all
for k = 1:50
	example_generate_samples_uniform
	M(k) = getframe;
end

% figure
% movie(M,10)
myVideo = VideoWriter('uniformDist_1000.avi');
open(myVideo);
writeVideo(myVideo, M);
close(myVideo);