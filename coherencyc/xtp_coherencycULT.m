function coh = xtp_coherencycULT(timeseries, cparams)
% calls coherencyc_unequal_length_trials for each pair of electrode leads
% in timeseries.data. Note timeseries is required to have an info.sMarkers
% field. Also, cparams may optionally have a movingwin parameter in the
% form of [winsize winstep]. If it is not present, default is [1 1].
%
% EXAMPLE: coh = xtp_coherencycULT(timeseries, [cparams])
%
% CHANGE CONTROL
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   04/08/09    S. Williams     Created.
% 1.1   04/09/09    S. Williams     add metadata to output structure
% 1.2   04/10/09    S. Williams     add channelNames to info

funcname = 'xtp_coherencycULT.m';
version = 'v1.2';

global XTP_CHRONUX_PARAMS XTP_HB_MONTAGES

if nargin < 2
    cparams = XTP_CHRONUX_PARAMS;
    % pull sampling rate from first epoch of timeseries 
    cparams.Fs = timeseries.metadata(1).srate;
    cparams.fpass(2) = max(cparams.fpass(1), min([cparams.fpass(2), cparams.Fs/2]));
end

if ~isfield(cparams, 'movingwin')
    cparams.movingwin = [1 1];
end

coh.info = timeseries.info;
coh.info.datatype = 'COHERENCY';
coh.info.source = inputname(1);
coh.info.generatedBy = funcname;
coh.info.version = version;
coh.info.rundate = clock;
coh.info.cparams = cparams;
coh.info.cohPairListID = 0;
if isfield(timeseries.metadata, 'HBmontageID')
    hbmid = timeseries.metadata(1).HBmontageID;
    coh.info.channelNames = XTP_HB_MONTAGES(hbmid).channelNames;
else
    fprintf(1, 'WARNING: no montage information provided.\n')
end
coh.metadata = timeseries.metadata;

switch cparams.err(1)
    case 2
        [Cmn,Phimn,Smn,Smm,f,ConfC,PhiStd,Cerr] = coherencyc_unequal_length_trials(timeseries.data{1}, cparams.movingwin, cparams, timeseries.info.sMarkers);
    case 1
        [Cmn,Phimn,Smn,Smm,f,ConfC,PhiStd] = coherencyc_unequal_length_trials(timeseries.data{1}, cparams.movingwin, cparams, timeseries.info.sMarkers);
    otherwise
        [Cmn,Phimn,Smn,Smm,f] = coherencyc_unequal_length_trials(timeseries.data{1}, cparams.movingwin, cparams, timeseries.info.sMarkers);
end

numchannels = size(timeseries.data{1},2);
numcohpairs = size(Cmn,2);

% build cohpairs matrix as [2 1; 3 1; 3 2; 4 1; 4 2; 4 3; ... etc]
cohpairs=zeros(sum(numchannels-1:-1:1),2);
for ch=2:numchannels
    cohpairs(sum(1:ch-2)+1:sum(1:ch-2)+ch-1,1:2) = [ch*ones(ch-1,1) (1:ch-1)'];
end
coh.info.cohpairs = cohpairs;

for cohpair = 1:numcohpairs
    coh.output{cohpair}.C = Cmn(:,cohpair);
    coh.output{cohpair}.phi = Phimn(:,cohpair);
    coh.output{cohpair}.S12 = Smn(:,cohpair);
    coh.output{cohpair}.S1 = Smm(:,cohpairs(cohpair,1));
    coh.output{cohpair}.S2 = Smm(:,cohpairs(cohpair,2));      
    coh.output{cohpair}.f = f;
    switch cparams.err(1)
        case 2
            coh.output{cohpair}.Cerr = Cerr(:,:,cohpair);
            coh.output{cohpair}.confC = ConfC(cohpair);
            coh.output{cohpair}.phistd = PhiStd(:,cohpair);
        case 1
            coh.output{cohpair}.confC = ConfC(cohpair);
            coh.output{cohpair}.phistd = PhiStd(:,cohpair);
    end %switch

end % for cohpair
end % function