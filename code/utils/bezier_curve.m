function [B] = bezier_curve(P0,P1,P2,w1,t)
% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 08, 2017
%
% Calculate bezier the coordinates of a bezier curve given the control
% points (P0,P1,P2), the weight of control point P1 w1 and the curve parameter t
% input:
% - Control points (P0,P1,P2) can be point coordinates[x,y] or scalar
% - w1 is the weight of control point P1
% - t is the parameter of the curve and it is only defined for the interval
% [0,1] 
den = (1-t)^2+2*(1-t)*t*w1+t^2;
B =((1-t)^2*P0+2*(1-t)*t*P1*w1+t^2*P2)/den;
end