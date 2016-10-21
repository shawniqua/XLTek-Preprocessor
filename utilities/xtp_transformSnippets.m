function outdata = xtp_transformSnippets(indata, snippetLength)
% <<<< KNOWN BUG ALERT!!!>>>
% 8/10/11 This function generated more than the expected number of epochs when run
% for L2sel3sQ1min, not sure why. need to debug it before future use! (or
% run the kluge fix which was to take the output data as well as metadata
% and reduce it to only half the samples using indexes [1:2:numEpochs]
% <<<< END OF ALERT >>>>
%
% transforms output from xtp_concatSnippets to data that can be used with
% xtp_mtspectrumc and xtp_coherencyc. Input: structure with .data field as
% a single TNxC matrix with TN total samples across all snippets and C
% channels. This structure should also have a .metadata field indicating
% data for each snippets, and .info.sMarkers field specifying start and end
% indexes of each snippet.
%
% output: corresponding structure with .data field as a cell array of NxC
% matrices, N = number of samples for each snippet, C = number of channels.
%
% EXAMPLE:  output = xtp_transformSnippets(input, [snippetLength])
% Where snippetLength is the length of the output snippets. Input snippets
% that are shorter than this snippetLength will be ignored. Input snippets
% that are longer than this snippetLength will be trimmed to this length. If
% there is enough room for multiple output snippets of the specified
% snippetLength to be generated, they will be treated as separate snippets
% in the output data. If an input snippet's length is not an exact multiple
% of the chosen snippetLength, data that is 'left over' after the maximum
% possible number of output snippets have been derived from the given input
% snippet (i.e. the tail end of the input snippet) will be discarded.
%
% NOT YET IMPLEMENTED:
% If no snippetLength is given, the procedure should maybe take the snippets 
% at their existing length. WARNING: If they are of differing lengths,
% xtp_mtspectrumc would fail or would pad the timeseries and will thus not 
% give correct information. 
%
% CHANGE CONTROL
% VER   DATE        PERSON      CHANGE
% ----- ----------- ----------- -------------------------------------------
% 1.0   06/01/09    S. Williams Created.
% 1.1   07/07/09    S. Williams update metadata.numsamples field
% 1.2   07/21/09    S. Williams explicit call to deal for specifying
%                               metadata.numsamples
% 1.21  08/10/10    S. Williams placemarker here because THERE IS A BUG
%                               WHERE THE OUTPUT HAS 2E-1 SEGMENTS IN IT,
%                               NOT SURE WHY BUT I MANUALLY ADJUSTED IT
%                               FOR L2sel3sQ1minUnPP - FUNCTION NEEDS
%                               DEBUGGING!!
% DON'T FORGET TO UPDATE THE VERSION NUMBER BELOW.

funcname = 'xtp_transformSnippets';
version = 'v1.21';

sMarkers = indata.info.sMarkers;
sLengths = sMarkers(:,2)-sMarkers(:,1);
fprintf(1,'snippet lengths range from %d to %d\n', min(sLengths), max(sLengths));

startSampleNums = [];
sampleSourceNums = [];
for inSampleNum = 1:size(sMarkers,1)
    startSampleNums = [startSampleNums sMarkers(inSampleNum,1):snippetLength:sMarkers(inSampleNum,2)];
    sampleSourceNums = [sampleSourceNums inSampleNum*ones(1,length(startSampleNums)-length(sampleSourceNums))];
end
startSampleNums = startSampleNums(1:end-1);         % the last one would go over the end
endSampleNums = startSampleNums+snippetLength-1;

outdata = rmfield(indata, 'data');
outdata = rmfield(outdata, 'metadata');
outdata.info.generatedBy = funcname;
outdata.info.source = inputname(1);
outdata.info.version = version;
outdata.info.rundate = clock;

outdata.data = cell(1,length(startSampleNums));

for outSampleNum = 1:length(startSampleNums)
    outdata.metadata(outSampleNum) = indata.metadata(sampleSourceNums(outSampleNum));
    outdata.data{outSampleNum} = indata.data{1}(startSampleNums(outSampleNum):endSampleNums(outSampleNum),:);
end
[outdata.metadata.numsamples] = deal(snippetLength);