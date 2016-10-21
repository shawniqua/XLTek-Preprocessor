function bucket = xtp_insertEpoch(bucket, startdate, enddate)

% adjusts epochs for missing segment.
% EXAMPLE: bucket = xtp_insertEpoch(bucket, startdate, enddate)
%CHANGE CONTROL
% VER DATE      PERSON          CHANGE
% 1.0 11/1/08   S. Williams     Created.

datefmt = 'mm/dd/yyyy HH:MM:SS';
startd = datenum(startdate,datefmt);
endd = datenum(enddate,datefmt);
numepochs = size(bucket{1},1);

bucket{1} = datenum(bucket{1}, datefmt);
bucket{2} = datenum(bucket{2}, datefmt);

insindex = find(bucket{1} > startd,1,'first');
if isempty(insindex)
    insindex = numepochs+1;
else
    if bucket{1}(insindex) <= endd
        fprintf(1,'ERROR: this segment overlaps with segment %d. No can do, kiddo!\n',insindex);
        return;
    end
    bucket{1}(insindex+1:numepochs+1) = bucket{1}(insindex:numepochs);
    bucket{2}(insindex+1:numepochs+1) = bucket{2}(insindex:numepochs);
end

bucket{1}(insindex) = startd;
bucket{2}(insindex) = endd;

%retranslate to date strings
bucket{1} = datestr(bucket{1}, datefmt);
bucket{2} = datestr(bucket{2}, datefmt);

end