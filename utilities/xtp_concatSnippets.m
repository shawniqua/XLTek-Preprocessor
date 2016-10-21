function seglist = stw_concatSnippets(Info, varargin)
% Concatenates a list of EEG segments end to end, each of dimensions Se x C
% (Se = the number of samples in the eth segment, C = number of channels).
% Returns a TS x C matrix (TS = total # of samples of all segments, C =
% channels). Also returns an Ex2 list of markers where E is the number of
% epochs. 
%
% Each segment may or may not already be a concatenated list of
% segments with its own list of markers. In this case the markers are added
% to the overall list.
%
% Optionally specify runtime parameters different from global defaults by
% adding a structure contining params at the end of the call. The params
% used by this function are:
% params.namesORnum     ='names' if the actual names of snippet variables
%                        are being passed. ='num' if we're just going up to
%                        a max number of epochs, and they are all named
%                        Snippet_x Snippet_y, Snippet_z etc
%
% EXAMPLE:  seglist = stw_concatSegs(Info, Snippet_1, Snippet_2, Snippet_3,... , [params])
%
% CHANGE CONTROL
% VER   DATE        PERSON      CHANGE
% ----- ----------- ----------- -------------------------------------------
% 1.0   03/24/09    S. Williams Created.
% 1.1   03/27/09    S. Williams removed confusing and contradictory
%                               helptext. made source default to
%                               Info.DataObj (take Info as first argument
%                               variable). preallocate metadata field.
%                               changed data output to cell
% 1.2   04/17/09    S. Williams if one argument, assume it is a crx
%                               variable
% DON'T FORGET TO UPDATE THE VERSION NUMBER BELOW.

funcname = 'xtp_concatSnippets.m';
version = 'v1.2';

global XTP_GLOBAL_PARAMS

if nargin == 1
    for sn = 1:length(fieldnames(Info))-1
        snippets{sn} = Info.(['Snippet_' num2str(sn)]);
    end
    Info = Info.Info;
else
    snippets = varargin;
end
if isfield(snippets{end}, 'readXLTfile')    % check if the last argument is params
    params = snippets{end};
    numsnippets = length(snippets)-1;
else
    params = XTP_GLOBAL_PARAMS;
    numsnippets = length(snippets);
end


seglist.info.datatype = 'TIMESERIES';
if params.interactive
    fprintf(1, 'Please specify a source for use in legends\n(default %s)', Info.DataObj);
    seglist.info.source = input(': ','s');
    if isempty(seglist.info.source)
        seglist.info.source = Info.DataObj;
    end
else
    seglist.info.source = Info.DataObj;
end
seglist.info.generatedBy = funcname;
seglist.info.version = version;
seglist.info.rundate = clock;
seglist.info.params = params;
seglist.info.sMarkers = [];
seglist.metadata = [];
seglist.data = [];

totallength = 0;
for snippetnum = 1:numsnippets
    seglist.metadata(snippetnum).srate = snippets{snippetnum}.Hdr.Common.Fs;
    seglist.metadata(snippetnum).start = snippets{snippetnum}.Data.SelectedSampleRange(1);
    seglist.metadata(snippetnum).end = snippets{snippetnum}.Data.SelectedSampleRange(2);
    seglist.metadata(snippetnum).numleads = snippets{snippetnum}.Data.ChannelsRead;
    seglist.metadata(snippetnum).headbox.labels = snippets{snippetnum}.Data.sensor.labels;
    seglist.metadata(snippetnum).units = 'uV';
    seglength = snippets{snippetnum}.Data.SamplesRead;
    seglist.info.sMarkers = [seglist.info.sMarkers;totallength+1 totallength+seglength];
    seglist.data = [seglist.data;snippets{snippetnum}.Data.modData{1}];
    
    totallength = totallength + seglength;
end     % for snippetnum
seglist.data = {seglist.data};
end     % function