function spectrogram = xtp_mtspecgramc(ppdata, cparams)
%
% Calls mtspectrogramc. Default movingwindow size is 1 second.
%
% EXAMPLE: spectrogram = xtp_mtspecgramc(ppdata, cparams)
%
% CHANGE CONTROL:
% VER   DATE        PERSON          CHANGE
% ----- ----------- --------------- ---------------------------------------
% 1.0   03/09/09    S. Williams     Created.
% 1.1   04/13/09    S. Williams     Get movingwin from cparams
% 1.2   11/30/09    S. Williams     include channel names in .info field
%                                   and call audit trail.
% 2.0   08/08/16    S. Williams     1) rearranged call to xtp_auditTrail so
%                                   that it doesn't overwrite the header
%                                   info. 2)DON'T copy over the entire
%                                   timeseries 3)
% DON'T FORGET TO UPDATE VERSION NUMBER BELOW

funcname = 'xtp_mtspecgramc';
version = 'v2.0';

global XTP_CHRONUX_PARAMS

% 20160808 moved these lines up in v2.0
cparams.trialave = 0;           % short term
spectrogram = xtp_auditTrail(ppdata,funcname,version,clock,cparams);
spectrogram.info.auditTrail(end).source = inputname(1);
spectrogram = rmfield(spectrogram, 'data');     % new in v2.0

spectrogram.info.datatype = 'SPECTROGRAM';
spectrogram.info.generatedBy = funcname;
spectrogram.info.version = version;
spectrogram.info.rundate = spectrogram.info.auditTrail(end).rundate;
spectrogram.info.source = inputname(1);
spectrogram.info.channelNames = ppdata.info.channelNames;

if nargin < 2
    cparams = XTP_CHRONUX_PARAMS;
end
if isfield(cparams, 'movingwin')
    movingwin = cparams.movingwin;
else
    movingwin = [ppdata.metadata(1).srate ppdata.metadata(1).srate]; % shouldn't this be [1 1]? unless cparams.Fs is 1
end


spectrogram.info.cparams = cparams;


% spectrogram.metadata = ppdata.metadata;

numepochs = size(ppdata.data,2);

for s=1:numepochs
    [S,t,f,Serr] = mtspecgramc(ppdata.data{s},movingwin,cparams);
    spectrogram.output{s}.S = S;
    spectrogram.output{s}.t = t;
    spectrogram.output{s}.f = f;
    spectrogram.output{s}.Serr = Serr;
end
end