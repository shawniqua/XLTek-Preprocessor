function sgram = xtp_spectrogram(ppdata, cparams, channels)
% Function sgram = xtp_spectrogram(PPdata, cparams, channels)
%
% calls MATLAB spectrogram function to calculate spectrograms on data
% prepared through XTP preprocessor
% (written as a workaround to presumed bug in chronux mtspecgramc)
% NOTE: THIS FUNCTION YIELDS NEGATIVE AND IMAGINARY NUMBERS - not sure how
% to interpret this.
%
% input:
%   PPdata = structure that is output from XLTek Preprocessor containing
%   metadata in .info and .metadata (see help xtp_montage) and a cell array
%   of epochs in the .data field. 
%
%   cparams = structure with parameter values as for chronux params, with
%   one additional parameter: cparams.movingwin contains [winsize, winstep]
%   in units of SECONDS, e.g for a 200ms window size that advances by
%   100ms, it would be [0.2 0.1] (this assuming Fs and fpass are in Hz).
%
%   channels = optional array of the subset of channels for which to
%   calculate spectrogram (if omitted, do all channels)
%
% output:
%   sgram is a structure same as output from xtp_mtspecgramc
%
% (c)2016 Shawniqua T. Williams, MNG., M.D.
% University of Pennsylvania

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATE     VER     CHANGE
% -------- ------- ----------------------------------------
% 04/18/16 1.0     Created
%
% DON'T FORGET TO CHANGE THE VERSION NUMBER BELOW.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

funcname = 'xtp_spectrogram';
version = 'v1.0';

global XTP_CHRONUX_PARAMS

sgram.info.datatype = 'SPECTROGRAM';
sgram.info.generatedBy = funcname;
sgram.info.version = version;
sgram.info.rundate = clock;
sgram.info.source = inputname(1);
sgram.info.channelNames = ppdata.info.channelNames;

numChans = length(ppdata.info.channelNames);

if nargin < 3
    channels = 1:numChans;
    if nargin < 2
        cparams = XTP_CHRONUX_PARAMS;
    end
end

Fs = ppdata.metadata(1).srate;

% movingwin parameters that need to get passed to matlab script are
% actually in #samples, not # seconds.
if isfield(cparams, 'movingwin')
    movingwin = cparams.movingwin * Fs;
else
    movingwin = [Fs Fs];
end

% matlab spectrogram takes in the number of samples overlapped instead of the actual moving window step size
noverlap = movingwin(1) - movingwin(2);

sgram.info.cparams = cparams;  % note trialave feature is disabled 
sgram = xtp_auditTrail(ppdata,funcname,version,sgram.info.rundate,cparams);

sgram.metadata = ppdata.metadata;

numepochs = size(ppdata.data,2);

sgram.output = cell(1,numepochs);

for epNum=1:numepochs
    for chNum = channels
        [S,f,t] = spectrogram(ppdata.data{epNum}(:,chNum),movingwin(1), noverlap, Fs, Fs);
        sgram.output{epNum}.S(:,:,chNum) = real(S');    % should be time x frequencies x channels
    end
    sgram.output{epNum}.t = t;
    sgram.output{epNum}.f = f;
    % sgram.output{epNum}.Serr = Serr;   % no feature to compare multiple epochs
end
end