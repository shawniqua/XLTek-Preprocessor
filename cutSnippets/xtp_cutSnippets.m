% xtp_cutSnippets.m
%
% This function, given a data structure containing filedata (output from 
% xtp_readXLTfile) and a list of epoch start and end times (or start times
% and durations), returns a matlab structure (snippets)
% with the following fields:
%   snippets.metadata is itself an array of E elements, with the 
%   following structure in each cell:
%    .samprate      sampling frequency
%    .start         start date and time for the epoch
%    .end           end date and time for the epoch
%    .hbnum         headbox number (corresponds to the order in which
%                   channels are listed)
%    .numleads      number of electrode leads in each 
%    .units         voltage units (usually millivolts) in which the eeg
%                   data is recorded
%   snippets.data is a cell array of E elements, each of which contains a 
%                   SxL matrix representing an epoch with S samples and L
%                   electrode leads.
% each cell in epochs.metadata corresponds to a cell in epochs.data.
%
%
% EXAMPLE: snippets = xtp_cutSnippets(filedata, [epochlist], [params])
% NOTE: if epochlist is specified at runtime, it must be declared as a
%       GLOBAL variable!!
%
% Change log:
% Ver Date          Name            Changes
% 1.0 10/17/08      S. Williams     Shell created.
% 2.0 10/24/08                      1. Added metadata.numsamples, 2.removed
%                                   support for addtosnippets (this is
%                                   covered by xtp_aggregate function),
%                                   3.added support for cutting snippets
%                                   according to the epoch list
% 2.1 10/25/08      S. Williams     If nargin < 2 must allow user to enter
%                                   epoch list at runtime. Also issue
%                                   warning if not all epochs represented
%                                   in filedata. Updated to reflect data in
%                                   2nd cell of data field (not 3rd)
% 2.2 02/18/09      S. Williams     accept params as a parameter. convert units 
%                                   if params.units do not match file data (requires 
%                                   version 2.2 of xtp_build_environmet). do 
%                                   not reset status to 1 for every successfully
%                                   found epoch.
% 2.3 05/15/09      S. Williams     manage .info field
% 2.4 05/28/09      S. Williams     debug audit trail of whether units were
%                                   converted
%DON'T FORGET TO UPDATE VERSION NUMBER BELOW!!!


function [snippets status]= xtp_cutSnippets(filedata, epochlist, params)

funcname = 'xtp_cutSnippets';
version = 'v2.4';

global XTP_GLOBAL_PARAMS XTP_CONVERSION_FACTORS

if nargin<3
    params = XTP_GLOBAL_PARAMS;                 
end

snippets = filedata;
% enter/update .info field
snippets.info.datatype = 'TIMESERIES';
snippets.info.generatedBy = funcname;
snippets.info.version = version;
snippets.info.rundate = clock;
snippets.info.source = inputname(1);

%get rid of timestamp info
snippets.data = {snippets.data{2}};
[numsamples numcolumns] = size(snippets.data{1});
snippets.metadata.numsamples = numsamples;

% assess need to convert units
convertUnits = 0;
if isfield(filedata.metadata, 'units') && ~strcmpi(filedata.metadata.units, params.units)
    if params.interactive == 1 
        fprintf('Convert units from %s to %s? ', filedata.metadata.units, params.units);
        convertUnits = strcmpi(input('[Y/N]', 's'),'y');
    else 
        convertUnits = 1;
    end
end

snippets.info.unitConversion = convertUnits;

if convertUnits
    convFrom = find(strcmpi(XTP_CONVERSION_FACTORS.units, filedata.metadata.units), 1, 'first');
    convTo = find(strcmpi(XTP_CONVERSION_FACTORS.units, params.units), 1, 'first');
    convFactor = XTP_CONVERSION_FACTORS.factors(convFrom, convTo);
else
    convFactor = 1;
end

if nargin < 2
    % simply copying over the filedata and reformatting the snippets
    % datastructure is enough
    fprintf(1,'Please identify a list of epochs according to which the snippets should be cut.\n');
    fprintf(1,'(or hit return to keep all data without cutting any).\nRemember, the epoch list should be a ');
    fprintf(1,'GLOBAL variable!\n'); 
    elistname = input('Epoch list variable name (be specific!): ', 's');
    if isempty(elistname)
        return
    end
    mainname = strread(elistname,'%s','delimiter','{.(');
    expn = ['global ' mainname{1}];
    eval(expn)
    expn = ['epochlist = ' elistname];
    eval(expn)
else
    snippets = rmfield(snippets, 'data');
end

metadatafields = fieldnames(filedata.metadata);
numfields = size(metadatafields,1);

numepochs = size(epochlist{1},1);
timelist = cellstr(filedata.data{1});
snippetnum = 1;
status = 1;
for e=1:numepochs
    starttime = epochlist{1}(e,:);
    endtime = epochlist{2}(e,:);
    startindex = find(strcmp(timelist, starttime),1,'first');
    endindex = find(strcmp(timelist, endtime),1,'first');
    endindex = endindex-1;
    snippet = filedata.data{2}(startindex:endindex, 1:numcolumns);
    if isempty(snippet)
        %this epoch not found in the datafile - continue and check for
        %others. mental note to display a warning at the end.
        status = 2;
    else

        snippets.data{snippetnum} = snippet*convFactor;

        % fill in metadata from source metadata
        for field = 1:numfields
            fieldval = filedata.metadata.(metadatafields{field});
            snippets.metadata(snippetnum).(metadatafields{field}) = fieldval;
        end
        % update relevant metadata fields that have changed
        snippets.metadata(snippetnum).start = starttime;
        snippets.metadata(snippetnum).end = endtime;
        snippets.metadata(snippetnum).numsamples = endindex - startindex + 1;
        if convertUnits
            snippets.metadata(snippetnum).units = params.units;
        end
        snippetnum = snippetnum+1;
    end
end
if status == 2
    fprintf(1,'WARNING: not all epochs were found in this datafile.\n');
    fprintf(1,'Number of epochs: %d   Number of snippets cut: %d\n',numepochs,snippetnum-1);
end



