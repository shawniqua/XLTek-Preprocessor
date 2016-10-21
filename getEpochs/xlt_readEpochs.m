% xlt_readEpochs.m
%
% This function reads a list of start times & end times into a 2 column cell array.
% times are assumed to be in the following format: 'mm/dd/yyyy HH:MM:SS'
%
% EXAMPLE: epochList = xlt_readEpochs ([filename])
%   if the filename argument is left blank, the user is prompted to select
%   it via a GUI window.
%

% Change Log:
% Ver Date      Person      Change
% 1.0 10/24/08  S. Williams Created
%

function epochList = xlt_readEpochs (filename)

% if no filename is given to start, open a ui to get it.
if nargin < 1
    [fname, pathname, filterindex] = uigetfile('*.txt', 'Please select a file to read.');
    filename = [pathname fname];
end

[fid,message] = fopen(filename, 'rt');
if fid == -1
    disp(message)
    epochList = [];
    return
end
message = ['Reading file ' filename '...'];
disp(message);

epochList = textscan(fid, '%19c %19c');
if feof(fid)
    message = 'File read complete.';
else
    message = ['ERROR: Unable to read all data from this file. Stopped at ' num2str(ftell(fid))];
end
disp(message);
fclose(fid);

end


