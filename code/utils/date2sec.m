function [s] = date2sec(days,hours,minutes,seconds)
% convert a time lapse specified in days,hours,minutes and seconds in
% seconds
s = seconds + minutes * 60 + hours * 3600 + days * 86400;
end