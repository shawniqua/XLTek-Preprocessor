function dataStructure = xtp_append (dataStructure1, varargin)
%compiles one big data structure by sequentially adding the datastructures
%the given datastructures to the base one. This function handles
%datastructures containing multiple epochs, whereas xtp_aggregate only
%support aggregating multiple datastructures each containing a single
%epoch.
%
%EXAMPLE: dataStructure = xtp_addon (dataStructure1, dataStructure2, dataStructure3...)
%
%CHANGE LOG
% Ver   Date        Person      Change
% 1.0   10/27/08    S. Williams Created
%

dataStructure = dataStructure1;
numsnippets = size(dataStructure.data, 2);

for dsnum = 1:size(varargin,2)
    dataStructure.metadata = [dataStructure.metadata varargin{dsnum}.metadata];
    for s = 1:size(varargin{dsnum}.data,2)
        dataStructure.data{numsnippets+s} = varargin{dsnum}.data{s};
    end
    if size(dataStructure.metadata, 2) ~= size(dataStructure.data,2)
        fprintf(1,'ERROR: appending %s to the data structure yields unequal amounts of data & metadata.\n',inputname(dsnum+1));
        return;
    end
    numsnippets = size(dataStructure.data, 2);
end