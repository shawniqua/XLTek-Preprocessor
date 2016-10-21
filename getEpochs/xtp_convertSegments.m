function segments = xtp_convertSegments(file, origin)
%takes segments in date format and converts them to # seconds since 7/30/07
% EXAMPLE: segments = xtp_convertSegments(file, origin)
% 
% Change Log:
% Ver Date      Person          Change
% --- --------- -----------     ------------------------------------------
% 1.0           S. Williams     Created
% 1.1 12/21/08  S. Williams     Added help text & change log

dateformat = 'mm/dd/yyyy HH:MM:SS';
if nargin < 2
    origin = '07/30/2007 00:00:00';
end
origin = datenum(origin, dateformat);

if nargin < 1
    [filename,pathname,junkinfo] = uigetfile('*.txt','Please select segment list.');
    file = [pathname filename];
    fprintf(1,'Reading segments from file %s...\n', file);
end

[fid, message] = fopen(file);
if fid < 1
    disp(message);
    segments = [];
    return
end

inputlist = textscan(fid, '%19c %19c %d');
if ~feof(fid)
    fprintf(1,'WARNING: did not read entire file. Stopped at %d.\n', ftell(fid));
end

numsegs = size(inputlist{1},1);
segments = zeros(numsegs, 3);
for s = 1:numsegs
    segments(s,1) = (datenum(inputlist{1}(s,:), dateformat) - origin)*3600*24;
    segments(s,2) = (datenum(inputlist{2}(s,:), dateformat) - origin)*3600*24;
    segments(s,3) = inputlist{3}(s);
end
fclose(fid);

end