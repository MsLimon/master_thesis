% clc
% clear all

pd = cell(1,2);
% distribution corresponding to the misalignment on x
pd{1} = makedist('normal','mu',0,'sigma',0.2);
% truncate x distribution (alignment structures only allow the laser to move backwards)
% pd{1} = truncate(pd{1},-1,0);
% distribution corresponding to the misalignment on y
pd{2} = makedist('normal','mu',0,'sigma',0.5);
% truncate y distribution (we have symmetry about the x axis)
% pd{2} = truncate(pd{2},-2,0);
% select number of samples
n = 5000;
% % correlation matrix
% correlation = [1 0;0 1];
% % generate the samples
% samples = lhsgeneral(pd,correlation,n);
samples = montecarlo(pd,n);
% plot histogram
hist3(samples,[10,10]);
xlabel(' x misalignment / um') % x-axis label
ylabel('y misalignment / um') % y-axis label
keySet = [125,200,500,1000,2000,5000];
valueSet = [200,120,300,700,1500,4000];
axisHeight = containers.Map(keySet,valueSet);
axis([-1.7,1.7,-1.7,1.7,0,axisHeight(n)]); %height: 1000samples: 700, 500samples:300, 200samples:120, 125samples:100
set(gcf,'renderer','opengl');
set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');