function dataStructure = xtp_aggregate (dataStructure1, varargin)
%compiles one big data structure by sequentially adding the datastructures
%the given datastructures to the base one. This function handles
%datastructures containing multiple epochs, whereas xtp_aggregate only
%support aggregating multiple datastructures each containing a single
%epoch.
%
%EXAMPLE: dataStructure = xtp_aggregate (dataStructure1, dataStructure2, dataStructure3...)
%
%CHANGE LOG
% Ver   Date        Person      Change
% 1.0   10/27/08    S. Williams Created
% 1.1   12/01/08    S. Williams renamed to xtp_aggregate
% 1.2   05/20/09    S. Williams support .info field
% 1.2.1 05/22/09    S. Williams temp bugfix to designation of .info.source
% 1.3   07/14/09    S. Williams add automatic adjustments if data is of
%                               unequal lengths (uses ULT functions)
% 1.4   02/09/14    S. Williams added support for SPectra and ADR
% DON'T FORGET TO UPDATE VERSION NUMBER BELOW.

funcname = 'xtp_aggregate';
version = 'v1.4';

if isstr(dataStructure1)
    vars2aggregate = evalin('base', ['who ' dataStructure1]); % hopefully this will give a cell array of strings
    specCell = arrayfun(@(x) evalin('base',vars2aggregate{x}),1:length(vars2aggregate),'UniformOutput', false);
    dataStructure = cell2mat(specCell);
elseif isstruct(dataStructure1)
    dataStructure = dataStructure1;
    % there should be no updating of datatype - it should come directly from
    % the source data and if it doesn't exist then xtp_aggregate is not going
    % to make it up.
    dataStructure.info.generatedBy = funcname;
    dataStructure.info.version = version;
    dataStructure.info.rundate = clock;
    dataStructure.info.source = inputname(1);

    switch dataStructure1.info.datatype
        case {'TIMESERIES', 'NK FILEDATA'}
            numsnippets = size(dataStructure.data, 2);

            for dsnum = 1:size(varargin,2)
                dataStructure.metadata = [dataStructure.metadata varargin{dsnum}.metadata];
                for s = 1:size(varargin{dsnum}.data,2)
                    if isfield(dataStructure.info, 'sMarkers')      % this must be ULT data
                        dataStructure.data{1} = [dataStructure.data{1}; varargin{dsnum}.data{1}];
                        dataStructure.info.sMarkers = cat(1,dataStructure.info.sMarkers,varargin{dsnum}.info.sMarkers+dataStructure.info.sMarkers(end,2));
                    else
                        dataStructure.data{numsnippets+s} = varargin{dsnum}.data{s};
                    end
                end
                if size(dataStructure.metadata, 2) ~= size(dataStructure.data,2)
                    fprintf(1,'ERROR: appending %s to the data structure yields unequal amounts of data & metadata.\n',inputname(dsnum+1));
                    return;
                end
                numsnippets = size(dataStructure.data, 2);
            end
        case 'POWER SPECTRA'
            disp('not yet coded to handle spectra variables passed. please pass a string the resolves to the variable names.')
            return
    end
end
end