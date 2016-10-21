function outData = xtp_analyze(analysis, inData, dataField)
% Runs an analysis function of the users choice on one or more sets of
% preprocessed data. Takes as input the specs on the analysis function to
% call, in the form of a structure with the following fields:
%
% analysis.function: string containing the function name to be called
% analysis.inputs: structure containing the variables to pass
%                    to the analyzer function. The subfield named
%                    inputs.dataField carries a string indicating the name
%                    of the data field to analyze in the input data. It is
%                    assumed that this will be the first input argument to
%                    the analysis function. It is also assumed that the
%                    dataField is a cell array of matrices, and the analysis
%                    function is called separately once for each element of
%                    the cell array.
% analysis.outputs: cell array with names of the output variables to pass
%                     to the statistics function.
%
%                     The fields in inputs and strings in outputs must
%                     appear in the order that they will be passed to the
%                     statistics function.
%
% Also requires the preprocessed data, with fields .metadata and .data as
% returned from xtp_preprocess (.metadata is a structure array with one 
% element per epoch, .data is a cell array with one element per epoch)
%
% EXAMPLE:
%   outData = xtp_analyze(analysis, inData)
%       where analysis is a struct defined as above, inData is the input
%       data to be analyzed.
% outputs a structure with the following fields: 
%   .info gives metadata about how the output variable was derived
%   .output is a cell array with one cell per epoch, and fields inside
%           each cell to match the output variable names specified for the
%           analysis function
%
% Change Control
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   03/13/09    S. Williams     Created.
% 1.1   06/03/09    S. Williams     Support analysis of output field
%                                   instead of data field (i.e. spectra or
%                                   other processed datastructures). also
%                                   support inData structures with 2D
%                                   dataFields
% 1.2   06.04/09    S. Williams     record dataField in output structure
%                                   under .info.analysis.inputs.dataField
% 1.3   07/30/09    S. Williams     copy all .info from source data
% 1.4   12/21/09    S. Williams     accept .dataField as a subfield of
%                                   .inputs instead of as a separate
%                                   argument. Assume dataField is a cell
%                                   array and repeat the analysis for each
%                                   cell. Only copy .info from source data
%                                   if it exists.
% DON'T FORGET TO UPDATE THE VERSION NUMBER BELOW.

funcname = 'xtp_analyze.m';
version = 'v1.4';

% if nargin < 3
%     dataField = 'data';
% end

dataField = analysis.inputs.dataField;

if isfield(inData, 'info')
    outData.info = inData.info;
end

outData.info.generatedBy = funcname;
outData.info.version = version;
outData.info.rundate = clock;
outData.info.source = inputname(1);
outData.info.analysis = analysis;
outData.info.analysis.inputs.dataField = dataField;
% outData.output = struct;      

numrows = size(inData.(dataField),1);
numcols = size(inData.(dataField),2);
%% building the calls to the analysis function

analysis.inputs = rmfield(analysis.inputs, 'dataField');
inargs = fieldnames(analysis.inputs);
ninargs = length(inargs);
noutargs = length(analysis.outputs);

analCmd = '[';
for outargnum =1:noutargs
    analCmd = [analCmd ' outData.output{rownum,colnum}.' analysis.outputs{outargnum}];
end
analCmd = [analCmd '] = ' analysis.function '(inData.' dataField '{rownum,colnum}'];
for inargnum=1:ninargs
    analCmd = [analCmd ', analysis.inputs.' inargs{inargnum}];
end
analCmd = [analCmd ');']; 

%% run stats on measured data
for rownum = 1:numrows
    for colnum = 1:numcols
        eval(analCmd);
    end
end



end