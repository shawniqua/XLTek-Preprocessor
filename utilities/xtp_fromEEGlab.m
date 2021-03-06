function prunedData = xtp_fromEEGlab(eeg, unprunedData, params)
% converts data from EEGLAB format back to XTP format. Assumes the EEGLAB
% dataset is in the current workspace (must pass in the correct dataset
% dataset). Output is in format analagous to preprocessed data - should be
% able to run spectra & coherences on it using standard xtp functions.
%
% Usage: prunedData = xtp_fromEEGlab(EEGLABdataset, [unprunedData])

% CHANGE CONTROL
% Ver   Date    Person      Change
% ----- ------- ----------- -----------------------------------------------
% 1.0   5.6.10  S. Williams Created.
% DON'T FORGET TO UPDATE VERSION NUMBER BELOW!!!

funcname = 'xtp_fromEEGlab';
version = '1.0';

global XTP_GLOBAL_PARAMS

if nargin < 3
    params = XTP_GLOBAL_PARAMS;
end
%% crude checking for matches 
% list of possible errors
errMsgs = {
    '1. Number of trials in EEGLAB data doesn''t match number of epochs in unpruned metadata.'
    '2. Channel Names in EEGLAB data doesn''t match unpruned channel list.'
    };
errTypes = [];
if nargin >= 2
    if (length(unprunedData.metadata) ~= eeg.trials) 
        errTypes = [errTypes 1];
    end
    channelNames = {eeg.chanlocs.labels}';
    if ~isequal(channelNames, unprunedData.info.channelNames)
        errTypes = [errTypes 2];
    end
    if errTypes 
        fprintf('WARNING: The EEGLAB data does not appear to match the unpruned dataset.\n');
        for e = errTypes
            fprintf(' - %s\n',errMsgs{e})
        end
        if params.interactive
            keepGoin = input('Continue [default N]?', 's');
            if isempty(keepGoin) || strcmpi(keepGoin, 'n')
                return
            end
        end
    end
    prunedData = unprunedData;
else
    disp('WARNING: unpruned datastructure is required to generate metadata.')
    disp('         dummy metadata will be used instead.');
    metadata = struct('sourceFile', [], ...
        'start', [],...
        'end', [],...
        'units', [],...
        'srate', eeg.srate, ...
        'numleads', [],...
        'hbnum', [],...
        'numsamples', eeg.pnts, ...
        'HBmontageID', 0,...
        'HBmontageName', '',...
        'prefiltering', [],...
        'EMGratings',[],...
        'filterparams',struct([]));
    [prunedData.metadata(1:eeg.trials)] = metadata;
end

prunedData.info.datatype = 'TIMESERIES';
prunedData.info.generatedBy = funcname;
prunedData.info.version = version;
prunedData.info.source = eeg.setname;
prunedData.info.rundate = clock;
prunedData.info.channelNames = {eeg.chanlocs.labels}';

% convert data
dataSize = size(eeg.data);
data = permute(eeg.data, [2 1 3]);      % convert from channels x samples x epochs to SxCxE
data = reshape(data, [dataSize(2) dataSize(1)*dataSize(3)]);    % convert to a 2D matrix of size SxCE so the epochs are end to end and the channels are repeated horizontally
prunedData.data = mat2cell(data, dataSize(2),dataSize(1)*ones(1,dataSize(3)));  % one cell for each SxC epoch

end

%% hint on how to reduce number of epochs
% list = 1:79
% rejlist = [5:8 14 16 17 19 20 21 40 41:43 50 51:53];
% list(rejlist) = 0;
% IN301M2007t1h1pPP.metadata = IN301M2007t1h1pPP.metadata(find(list~=0))
