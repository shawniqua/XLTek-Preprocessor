% xtp_datestr.m     converts integers to date string
%
% This function, given an integer representing number of seconds from an
% origin point in time, and given the origin itself, converts the number to
% a date in string format. The origin must be a date in the format
% specified by the global variable XTP_DATE_FORMAT (typically
% 'MM/DD/YYYY HH:MM:SS'). This is also the format for the output string.
%

function newdate = xtp_datestr(dateInSeconds, origin)

default_date_string = 'mm/dd/yyyy HH:MM:SS';

newdatenum = datenum(origin, default_date_string) + double(dateInSeconds / (3600*24));
newdate = datestr(newdatenum, default_date_string);

end