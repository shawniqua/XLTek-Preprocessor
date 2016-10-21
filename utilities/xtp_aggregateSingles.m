% xtp_aggregateSingles.m
%
% This function collects multiple xtp data structures, each containing a single
% snippet, into a singel data structure. It was originally written for
% filteredd data, but may also work with prefiltered, montaged or cut
% snippets. It does NOT work with data structures containing more than one
% snippet - these structures will need to be analyzed separately or
% manually combined for analysis. it will also not work with spectra as it
% assumes a data structure containing only two fields (.data and .metadata)
%
% EXAMPLE: agg = xtp_aggregate(dataset1, dataset2, dataset3...);
%
% CHANGE LOG
% Ver   Date     Person      Change
% -------------------------------------------------------------------------
% 1.0            S. Williams Created
% 1.01  10/25/08 S. Williams added helptext and change log
% 1.1   12/01/08 S. Williams renamed to xtp_aggregateSingles
% 1.2   05/15/09 S. Williams support .info field

function agg = xtp_aggregateSingles(varargin)

funcname = 'xtp_aggregateSingles';
version = 'v1.2';

agg = varargin{1};
agg.info.generatedBy = funcname;
agg.info.version = version;
agg.info.rundate = clock;
agg.info.source = inputname;

for n=1:nargin
    agg.data{n} = varargin{n}.data{1};    
    agg.metadata{n} = varargin{n}.metadata;
    agg.metadata{n}.sourceDataset = inputname(n);
end
    agg.metadata = cell2mat(agg.metadata);
end