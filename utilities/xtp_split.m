function varargout = xtp_split(dataIn, dataField)
% Splits a dataset into N subsets, each with 1/N randomly chosen epochs. N
% is determined based on the number of output arguments provided at command
% line (default 2). 
%
% By default this function assumes the data is in the .data field. For
% power spectra or other analysis data it may be found in the .output field
% (or others). Optionally specify the field where the data is stored as the
% second input argument.
%
% If there is a metadata field, only the epochs selected in the data field
% are included in the output metadata field.
%
% EXAMPLE: [PPdataOut1 PPDataOut2 PPDataOut3] = xtp_split(PPdataIn, [dataField])
%
% CHANGE CONTROL
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   06/12/09    S. Williams     Created.
% DON'T FORGET TO UPDATE THE VERSION NUMBER BELOW!!!

funcname = 'xtp_split';
version = 'v1.0';

if nargout == 0
    numout = 2;
else
    numout = nargout;
end

if nargin < 2
    dataField = 'data';
end

numepochs = size(dataIn.(dataField), 2);
numepochsPerOutvar = round(numepochs/numout);
neworder = randperm(numepochs);
nextEpoch = 1;
outvars = cell(1,numout);
for outvarNum = 1:numout  
    outvars{outvarNum} = dataIn;
    outvars{outvarNum}.info.generatedBy = funcname;
    outvars{outvarNum}.info.version = version;
    outvars{outvarNum}.info.source = inputname(1);
    outvars{outvarNum}.info.rundate = clock;
    if outvarNum < numout
        epochs2choose = neworder(nextEpoch:nextEpoch+numepochsPerOutvar-1);
    else
        epochs2choose = neworder(nextEpoch:end);
    end
    outvars{outvarNum}.info.chosenEpochs = epochs2choose;
    if isfield(dataIn, 'metadata')
        outvars{outvarNum}.metadata = dataIn.metadata(epochs2choose);
    end
    outvars{outvarNum}.(dataField) = dataIn.(dataField)(:,epochs2choose);
    if nargout > 0
        varargout{outvarNum} = outvars{outvarNum};
    else
        outvarname = [inputname(1) num2str(outvarNum)];
        assignin('base', outvarname, outvars{outvarNum})
    end
    nextEpoch = nextEpoch+numepochsPerOutvar;
end

end