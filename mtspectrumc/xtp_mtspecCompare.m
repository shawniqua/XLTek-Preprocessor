function [spec1 spec2 AdzJK] = xtp_mtspecCompare(PPdata1, PPdata2, cparams, EMGcutoff)
% for two datasets, calls xtp_mtspectrumcOnlyGoodChannels and then runs
% two_group_test to identify frequencies where they are significantly
% different. uses jacknife estimates.
%
% EXAMPLE: [spec1 spec2 AdzJK] = xtp_mtspecOGCtgt(PPdata1, PPdata2, cparams, EMGcutoff)
% Where PPdata has three fields:
%       .info contains metadata about how & when the PPdata1 was generated
%       .metadata is a structure array with one element per epoch, with
%         information about each epoch (start date, end date, etc). Unlike
%         earlier XTP functions, each metadata element must also include an
%         EMGratings field, which is a 1xC array indicating the EMG rating
%         for each channel
%       .data is a cell array, each element containing an SxC matrix of the
%         channel voltages (S = # of samples, e.g. 2000 for a 10 second
%         epoch with sampling rate of 200Hz, C = # of channels, e.g. 18 for
%         standard longitudinal bipolar with 3 midline electrodes)
% If cparams are not specified, they will be taken from XTP_CHRONUX_PARAMS.
%
% Output: AdzJK is a structure containing as output an FxC matrix of 0s and 1s with 1s at the frequencies
% that are significantly different. F = frequencies, C = channels.

% CHANGE CONTROL
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   02/15/10    S. Williams     Created.
% 1.1   03/03/10    S. Williams     provision for channels with no good
%                                   epochs
% 1.2   03/31/10    S. Williams     distinguish greater than vs less than;
% 1.3   04/02/10    S. Williams     add metadata to AdzJK
%***DONT FORGET TO UPDATE THE VERSION NUMBER BELOW.***

funcname = 'xtp_mtspecCompare';
version = 'v1.3';

global XTP_GLOBAL_PARAMS XTP_CHRONUX_PARAMS
%% confirm the two datasets have the same montage
if ~(sum(strcmpi(PPdata1.info.channelNames, PPdata2.info.channelNames)))
    msg = ('WARNING: The datasets you selected are not comparable - they have 2 different montages!!');
    if XTP_GLOBAL_PARAMS.interactive && ~strcmpi(input('Continue? [y/n] ', 's'),'y')
        return;
    end
end     

%% setup and resolve input arguments
nChans = size(PPdata1.data{1},2);

if nargin < 4
    if isfield(XTP_GLOBAL_PARAMS, 'EMGcutoff')
        EMGcutoff = XTP_GLOBAL_PARAMS.EMGcutoff;
    else
        EMGcutoff = 1;
    end
    if nargin < 3
        cparams = XTP_CHRONUX_PARAMS;
    end
end
if EMGcutoff < 0
    fprintf(1,'WARNING: cannot have EMG cutoff < 0. Setting EMG cutoff to 0.\n');
    EMGcutoff = 0;
end
if ~isfield(PPdata1.metadata, 'EMGratings')
    fprintf(1,'WARNING: No EMG ratings specified for datatset 1. All channels will be used for all epochs.\n');
    [PPdata1.metadata.EMGratings] = deal(zeros(1,nChans));
end
if ~isfield(PPdata2.metadata, 'EMGratings')
    fprintf(1,'WARNING: No EMG ratings specified for datatset 2. All channels will be used for all epochs.\n');
    [PPdata2.metadata.EMGratings] = deal(zeros(1,nChans));
end

%% find the spectra (& ffts)
[spec1 J1] = xtp_mtspecOnlyGoodChannels(PPdata1, cparams, EMGcutoff);
[spec2 J2] = xtp_mtspecOnlyGoodChannels(PPdata2, cparams, EMGcutoff);


% ABOVE, J1 AND J2 ARE GOING TO BE CELL ARRAYS WITH FxET MATRICES
% CONTAINING THE FOURIER TRANSFORMS.
% F = number of frequencies
% ET = number of [good] epochs x number of tapers 
%       [will need to accommodate 0 good epochs!!]
% Each fft cell array will have C cells (C = number of channels)

%% compare the spectra and generate AdzJK 
% (has ones for where they are the same)
p = cparams.err(2);
f = spec1.output{1}.f;
AdzJK.output = zeros(length(f),nChans);
disp('Comparing spectra for channel:')
for chNum=1:nChans
    fprintf('%d...',chNum);
    if ~sum(sum(isnan(spec1.output{chNum}.S))) && ~sum(sum(isnan(spec2.output{chNum}.S)))
        J1{chNum} = reshape(J1{chNum},[size(J1{chNum},1) size(J1{chNum},2)*size(J1{chNum},3)]);
        J2{chNum} = reshape(J2{chNum},[size(J2{chNum},1) size(J2{chNum},2)*size(J2{chNum},3)]);
        [dz,vdz,Adz]=two_group_test_spectrum(J1{chNum},J2{chNum},p,'n',f);
        %calculate the jacknife errors as well
         P=repmat([p/2 1-p/2],[length(f) 1]);   % this replicates the row [p/2 1-p/2] the length(f) number of times along the columns
         M=zeros(size(P));                      % matrix of means equal to 0 with same dimensions as P
         V=[vdz(:) vdz(:)];
         Cdz=norminv(P,M,V); %Cdz is the confidence bands. Can then define AdzJK (Jacknife) to be 1 when dz is outside the band
    %      AdzJK{chNum} = ones(size(dz)); %changed zeros to ones
    %      indxJK=find(dz>=Cdz(:,1) & dz<=Cdz(:,2)); 
         AdzJK.output((dz<Cdz(:,1)),chNum) = -1; %leave AdzJK to 0 where dz is within JacknifeCI, 
         AdzJK.output((dz>Cdz(:,2)),chNum) = 1; %-1 where spec1<spec2 and +1 where spec1>spec2
    else
        fprintf('(no good epochs for %d) ',chNum);
        AdzJK.output(1:length(f),chNum) = nan;
    end
end

%% add metadata to AdzJK

AdzJK.info = spec1.info;
AdzJK.info.source = {inputname(1), inputname(2)};
AdzJK.info.datatype = 'AdzJK';
AdzJK.info.rundate = clock;
AdzJK.info.generatedBy = funcname;
AdzJK.info.version = version;
AdzJK.info.f = spec1.output{1}.f;
disp('Done.\n')