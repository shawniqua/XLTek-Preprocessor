% xtp_getEpochs.m   select epochs from a list of clean segments
%
% This function, provided a list of timeframes (dosebuckets) & clean segments 
% with their start & end times, generates a list of epochs based on the
% following criteria:
%   epoch size min (default 2) & max (default 5) 
%   space between epochs (default 0s)
%
% output is a 2D cell array, with a column for each dose and row for each 
% 1 hour bucket associated with the dose (usually 1 hour before to 4 hours 
% after the dose, although this is not required)
% each cell contains an N by 2 matrix of epoch start and end times
% epochs(b,d){K,1} = start time of the Kth epoch for the dosebucket
% epochs(b,d){K,2} = end time of the Kth epoch for the dosebucket.
%
% side note: this was created for use with eeg segments recorded & selected
% around doses of medicine given to a patient. however the events of
% interest may be other than actual medication doses.
%
% for simplicity, the dosebuckets and segments should be loaded prior
% to running the script and provided as input arguments:
%   dosebuckets is structure of two fields (dosebuckets.start & dosebuckets.end)
%     each field is an integer array marking the start/end times (in seconds) 
%     of each bucket. columns represent doses, rows represent buckets. Each
%     dose must have the same number of buckets, but they do not
%     necessarily have to have the same duration.
%   segments is an Nx3 integer matrix with the following columns:
%       start time (in seconds)
%       end time (in seconds)
%       acceptable (0 for no or 1 for yes)
%
% EXAMPLE: epochs = xtp_getEpochs(dosebuckets, minlen, maxlen, interval);
%
% Later enhancement: I may add support for a score field, to try different 
% algorithms to optimize the selected epochs (e.g. varying epoch lengths to
% minimize EMG noise)
%
% CHANGE LOG
% Ver Date      Person          Change
% 1.0 10/9/08   S. Williams     Created.
% 1.1 10/17/08  S. Williams     added support for third column of segments 
% 1.2 10/25/08  S. Williams     support for command line entry of min & max
%                               epoch lengths and epochInterval
% 1.3 10/29/08  S. Williams     automatic call to xtp_convertEpochs at the
%                               end eliminates extra command line process
% 1.6 10/31/08  S. Williams     sutomatic call to xtp_convertSegments at
%                               the beginning eliminates extra command line
%                               processing. frogleaped v1.4 and v1.5 due to
%                               additional changes for rollback.

function epochs = xtp_getEpochs(dosebuckets, minEpochLen, maxEpochLen, epochInterval)

segments = xtp_convertSegments();

if nargin < 1
        fprintf(1,'ERROR: not enough arguments. Enter "help xtp_getEpochs" for guidance.\n');
        epochs = [];
        return
else if nargin == 2;
    minEpochLen = input('Please specify the MINIMUM epoch length (in seconds). ');
    maxEpochLen = input('Please specify the MAXIMUM epoch length (in seconds). ');
    epochInterval = input('Please specify the minimum interval between epochs (in seconds). ');
    end
end

numdb = size(dosebuckets.start);
numdoses = numdb(2);
numbuckets = numdb(1);

% timeend = dosebuckets.end(numbuckets, numdoses);

sizesegs = size(segments);
numsegs = sizesegs(1);

for d = 1:numdoses
    for b = 1:numbuckets
        bstart = dosebuckets.start(b,d);
        bend = dosebuckets.end(b,d);
        t = bstart;         % time counter
        K = 1;              % epoch number within the dosebucket
        while t <= (bend - minEpochLen + 1)
            currseg = max(find(segments(:,1) <= t));   % find the most recently started segment for this second
            if ~isempty(currseg)
                if ((segments(currseg,3)==1) && (segments(currseg,2) >= t+minEpochLen))     % if the segment is long enough to fit an epoch in AND the segment is considered acceptable for use
                    tempEpochList(K,1) = t;                 
                    tempEpochList(K,2) = min([segments(currseg,2) t+maxEpochLen bend+1]);
                    t = tempEpochList(K,2) + epochInterval;   % there must be an interval between accepted epochs
                    K = K + 1;
                else        % but if the current segment ends before minEpochLen is satisfied or the segment is not acceptable for use
                    if currseg < numsegs    % and we haven't exhausted the list of segments, 
                        t = segments(currseg+1,1);      % speed time ahead to beginning of the next segment.
                    else    %if we have exhausted the list of segments then just jump ahead to the end of the dosebucket.
                        t = bend+1;
                    end
                end
            else
                t = t + 1;     % if there was no segment starting before the current time, go to the next second & see if there's a new segment starting
            end
        end
        epochs{b,d} = tempEpochList;
        tempEpochList = int32(0);
    end
end

epochs = xtp_convertEpochs(epochs);
end

            

