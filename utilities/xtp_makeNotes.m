function outstr = xtp_makeNotes(instruct, oneBigString)
% generates a cell array of strings from a structure. 
% usage: output = xtp_makeNotes(inStruct, [oneBigString])
%
% CHANGE CONTROL
% Ver   Date        Person          Change
% 1.0               S. Williams     Created
% 1.1   04/11/10    S. Williams     Added oneBigString argument to
%                                   optionally convert the output cell to
%                                   one long string interrupted by spaces
%
fieldNames = fieldnames(instruct);
outstr = cell(length(fieldNames),1);
for f = 1:length(fieldNames)
    if isnumeric(instruct.(fieldNames{f}))
        outstr{f} = sprintf('%s: %s',fieldNames{f},num2str(instruct.(fieldNames{f})));
    elseif isstr(instruct.(fieldNames{f}))
        outstr{f} = sprintf('%s: %s',fieldNames{f},instruct.(fieldNames{f}));
    elseif isstruct(instruct.(fieldNames{f}))
        outstr{f} = sprintf('%s: (%d-field struct)', fieldNames{f},length(fieldnames(instruct.(fieldNames{f}))));
    elseif iscell(instruct.(fieldNames{f}))
        outstr{f} = sprintf('%s: (%dx%d cell)',fieldNames{f},size(instruct.(fieldNames{f}),1),size(instruct.(fieldNames{f}),2));
    end
end
if nargin < 2
    oneBigString = 0;
end
if oneBigString
    for c = 2:length(outstr)
        outstr{1} = [outstr{1} '   ' outstr{c}];
    end
    outstr = outstr(1);
end