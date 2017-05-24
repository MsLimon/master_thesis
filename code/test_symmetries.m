% Developed by Marta Timon
% University of Freiburg, Germany
% Last Update: May 23, 2017

%load the Iline_data
Iline_data = load('intensity_line.dat'); 
x = Iline_data(:,1);
f = Iline_data(:,2);
f_plus = 0.5 * (f + flip(f)); 
f_minus = 0.5 * (f - flip(f)); 

plot(x,f);

% f_plus_norm = 0; 
% f_minus_norm = 0; 
%  for k = 2:length(f)-1 
%     f_plus_norm = f_plus_norm + (f_plus(k)^2 * (x(k+1)-x(k-1))*0.5);
%     f_minus_norm = f_minus_norm + (f_minus(k)^2 * (x(k+1)-x(k-1))*0.5);
%  end
%  f_plus_norm = sqrt(f_plus_norm); 
%  f_minus_norm = sqrt(f_minus_norm); 
%  m = f_plus_norm / (f_plus_norm + f_minus_norm);
 
 m = norm(f_plus) / (norm(f_plus) + norm(f_minus));
 
