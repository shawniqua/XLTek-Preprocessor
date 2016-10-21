function numGoodEpochs = xtp_countGoodEpochs(data, EMGcutoff)
% gives a list of the total number of acceptable epochs for a data
% structure (preprocessed data, spectra or coherence) based on the
% metadata.EMGratings field and an EMGcutoff specified by the user or in
% the .info field. For timeseries and power spectra, returns the number of
% good epochs per channel. For coherences, returns the number of good
% epochs per cohpair.
%
% EXAMPLE: goodEpochs = xtp_countGoodEpochs(data, [EMGcutoff])
%   For spectra and coherences, the EMGcutoff used for the
%   spectral/coherence estimates is used, and any command line EMGcutoff is
%   ignored. For tiemseries data, EMGcutoff must be specified at the
%   command line (since there is no cutoff specified in the .info field)
%
% CHANGE CONTROL
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   06/27/09    S. Williams     Created.

funcname = 'xtp_countGoodEpochs';
version = 'v1.0';

if isfield(data.info, 'EMGcutoff')
    EMGcutoff = data.info.EMGcutoff;
end
numepochs = length(data.metadata);
[ratings{1:numepochs,1}] = data.metadata.EMGratings;
ratings = cell2mat(ratings);        % nEpochs x nChannels
goodEpochs = (ratings<=EMGcutoff);     
if strcmpi(data.info.datatype, 'COHERENCY')
    numCohpairs = size(data.info.cohpairs,1);
    goodEpochs4bothChannels = nan(numepochs, numCohpairs);
    for cp = 1:numCohpairs
        goodEpochs4bothChannels(:,cp) = (goodEpochs(:,data.info.cohpairs(cp,1)) & goodEpochs(:,data.info.cohpairs(cp,2)));
    end
    numGoodEpochs = sum(goodEpochs4bothChannels,1);
else
    numGoodEpochs = sum(goodEpochs,1);
end
