function [frequencies values idx channels] = xtp_findMax(coh, freqrange, channels, minmax)
% finds frequency at which local max power/coherency occurs.
% usage: [frequencies values idx channels] = findMax(spectrum, freqrange, channels, minmax)
% where spectrum = xtp power or coherency structure
%       freqrange = range of frequencies over which to look for the max
%                   coherency (format: [rangemin rangemax])
%       channels = string 'all' or list of channel numbers, in matrix array 
%                  form, to find the max on (default all)
%       minmax = 'min' to find the nadirs or 'max' to find the peaks (default max)
%
% CHANGE CONTROL
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0               S. Williams     Created
% 1.1   08/01//09   S. Williams     Allow to find the nadir as well as the
%                                   peak. handle input 'all' for channels
if nargin < 4
    minmax = 'max';
    if nargin < 3
        channels = [1:length(coh.output)];
        if nargin < 2
            freqrange = [0 10];
        end
    end
end
if ischar(channels) && strcmpi(channels, 'all')
    channels = 1:length(coh.output);
end
switch coh.info.datatype
    case 'COHERENCY'
        datafield = 'C';
    case 'POWER SPECTRA'
        datafield = 'S';
    otherwise
        datafield = 'S';
end

for chnum = 1:length(channels)
    candidateIndexes = find(coh.output{channels(chnum)}.f>=freqrange(1) & coh.output{channels(chnum)}.f<freqrange(2));
    engine = sprintf('[values(chnum) idx(chnum)] = %s(coh.output{channels(chnum)}.(datafield)(candidateIndexes));',minmax);
    eval(engine);
%     [values(chnum) idx(chnum)] = max(coh.output{channels(chnum)}.(datafield)(candidateIndexes));
    frequencies(chnum) = coh.output{channels(chnum)}.f(candidateIndexes(idx(chnum)));
end % for chnum
end