function AdzJK = xtp_cohCompare(Jcond1, Jcond2)
% for two sets of FFTs, runs two_group_test to identify frequencies where
% they are significantly different. uses jacknife estimates. FFTs are
% generated from xtp_coherencyc Note: unlike with xtp_mtspecCompare,
% xtp_cohCompare requires xtp_coherencyc to be run separately as a prerequisite.
%
% EXAMPLE: AdzJK = xtp_cohCompare(Jcond1, Jcond2)
% Jcond and Jcond2 are structures with .info and .output cell arrays, each
% .output is Px2 with one row per cohpair, each cell containing an FxET
% matrix (F = # of frequencies, ET = # of epochs*# of tapers). 
%
% info is a structure array carrying cparams, channel names, a cohPairList
% and a list of frequencies. The .info structure from one of the coherency
% datastructures that is output from xtp_coherencyc can be used (except info.f does not exist).
% 
% cohPairListID is a reference to XTP_COHERENCY_PAIRS identifying which
% pairs of channels to compare
%
% If cparams are not specified, they will be taken from XTP_CHRONUX_PARAMS.
%
% Output: AdzJK is a structure containing as output an FxP (F =
% frequencies, P = channelPairs) matrix of 0, 1 and -1 with 1 at the
% frequencies for which Jcond1 has higher coherence, 
% -1 at frequencies where Jcond2 has higher coherence, and 0 where the
% difference is not statistically significant.

% CHANGE CONTROL
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   04/02/10    S. Williams     Created from xtp_mtspecCompare.
% 2.0   04/10/10    S. Williams     reworked according to new algorithm
% 2.1   04/15/10                    handle contingency of no good epochs
%***DONT FORGET TO UPDATE THE VERSION NUMBER BELOW.***

funcname = 'xtp_cohCompare';
version = 'v2.1';

global XTP_GLOBAL_PARAMS XTP_CHRONUX_PARAMS
%% confirm the two FFTs come from comparable datasets
incomparable = 0;
errtypes = [];

if ~strcmpi(Jcond1.info.datatype, 'COH FFT') || ~strcmpi(Jcond2.info.datatype, 'COH FFT')
    incomparable = 1;   % these two input datasets don't appear to be the right type of input for this operation.
    errtypes = [errtypes 1];
end
if ~isequal(Jcond1.info.cparams, Jcond2.info.cparams)
    incomparable = 1;   % different parameters were used to generate these two datasets
    errtypes = [errtypes 2];
end
if size(Jcond1.output) == size(Jcond2.output)
    if ~min(min(strcmpi(Jcond1.info.channelNames(Jcond1.info.cohpairs), Jcond2.info.channelNames(Jcond2.info.cohpairs))))
        incomparable = 1;   % the cohPairLists have the same number of pairs but the channel labels that they reference appear to differ
        errtypes = [errtypes 3];
    end
else
    incomparable = 1;   % the different cohPairLists don't even have the same number of pairs
    errtypes = [errtypes 4];
end

J1cparams = xtp_makeNotes(Jcond1.info.cparams);
J2cparams = xtp_makeNotes(Jcond2.info.cparams);
errmsgs = {
    'Type 1 error: These two input datasets do not appear to be the right type of input for this operation.';
    sprintf('Type 2 error: Different parameters were used to generate these two datasets. \n\tcparams1 is as follows: %s\n\tcparams2 is as follows: %s', char(J1cparams)', char(J2cparams)');
    'Type 3 error: The coherency pair lists for these two datasets appear to reference different channels.';
    'Type 4 error: The coherency pair lists for these two datasets are of different lengths.'
    };
if incomparable
    fprintf('WARNING: The datasets you selected do not appear to be comparable for the following reason(s):\n');
    for r=1:length(errtypes)
        disp(errmsgs{errtypes(r)});
    end
    if XTP_GLOBAL_PARAMS.interactive && ~strcmpi(input('Continue? [y/n] ', 's'),'y')
        return;
    end
end     

%% compare the spectra and generate AdzJK 
% (has ones for where condition 1 had higher coherence, -1 for where
% condition2 has higher coherence, zero where they are indistinguishable).
% ABOVE, Jcond1.OUTPUT{P,C} AND Jcond2.OUTPUT{P,C} ARE GOING TO BE CELL
% ARRAYS WITH FxExT MATRICES CONTAINING THE FOURIER TRANSFORMS.
% P = number of coherency pairs (this is different from little p = type 1
% error rate)
% C = 2 (2 channels in each pair)
% F = number of frequencies
% E = number of [good] epochs 
% T = number of tapers 
%       [will need to accommodate 0 good epochs!! if these were NaNs I
%       think it would flush out nicely with little effort] 

p = Jcond1.info.cparams.err(2);
f = Jcond1.info.f;
cohpairs = Jcond1.info.cohpairs;
numCohPairs = size(cohpairs,1);
channelNames = Jcond1.info.channelNames;
AdzJK.output = zeros(length(f),numCohPairs);    % there will be a row for each frequency and a column for each channel pair
% prep for calculating jackknife errors
Pmat=repmat([p/2 1-p/2],[length(f) 1]);   % this replicates the row [p/2 1-p/2] the length(f) number of times along the columns (e.g. [0.025 0.975 ; 0.025 0.975 ; 0.025 0.975...])
Mmat=zeros(size(Pmat));                      % matrix of means equal to 0 with same dimensions as Pmat

disp('Comparing coherences for cohPair:')
for cpNum=1:numCohPairs
    fprintf('%d (%s and %s)...',cpNum, channelNames{cohpairs(cpNum,1)}, channelNames{cohpairs(cpNum,2)});
    if ~(isempty(Jcond1.output{cpNum,1}) || isempty(Jcond2.output{cpNum,1})) %'there are good epochs for both channels in both conditions
        % reshape Jcond1.output{cpNum,1} and Jcond1.outpur{cpNum,2} to fit
        % input expected by TGTcoh. same for Jcond2. they should be FxET
        sz = size(Jcond1.output{cpNum,1});
        Jcond1chan1 = reshape(Jcond1.output{cpNum,1},[sz(1) sz(2)*sz(3)]);
        sz = size(Jcond1.output{cpNum,1});
        Jcond1chan2 = reshape(Jcond1.output{cpNum,2},[sz(1) sz(2)*sz(3)]);
        sz = size(Jcond2.output{cpNum,1});
        Jcond2chan1 = reshape(Jcond2.output{cpNum,1},[sz(1) sz(2)*sz(3)]);
        sz = size(Jcond2.output{cpNum,1});
        Jcond2chan2 = reshape(Jcond2.output{cpNum,2},[sz(1) sz(2)*sz(3)]);

        % call TGTcoh
        [dz,vdz,Adz] = two_group_test_coherence(Jcond1chan1, Jcond1chan2, Jcond2chan1, Jcond2chan2,p,'n',f);

        % calculate jackknife errors
        Vmat=[vdz(:) vdz(:)];
        Cdz=norminv(Pmat,Mmat,Vmat); %Cdz is the confidence bands. Can then define AdzJK (Jacknife) to be 1 when dz is outside the band
        AdzJK.output((dz<Cdz(:,1)),cpNum) = -1; %leave AdzJK to 0 where dz is within JacknifeCI, 
        AdzJK.output((dz>Cdz(:,2)),cpNum) = 1; %-1 where coh1<coh2 and +1 where coh1>coh2
    else
        fprintf(' SKIPPED. One of the conditions has no good epochs in one of the channels)');
        AdzJK.output(1:length(f),cpNum) = nan;
    end
    fprintf('\n');
end

%% add metadata to AdzJK

AdzJK.info = Jcond1.info;
AdzJK.info.source = {inputname(1), inputname(2)};
AdzJK.info.datatype = 'AdzJK';
AdzJK.info.rundate = clock;
AdzJK.info.generatedBy = funcname;
AdzJK.info.version = version;
AdzJK.info.f = f;
disp('Done.\n')