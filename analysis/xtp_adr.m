function adr = xtp_adr(spec, freqRanges)
% given a set of power spectra and a set of frequency ranges, calculates
% the average (mean) power over the specified ranges
%
% spec - as output from xtp_mtspectrumc
% freqRanges - an Nx2 matrix with teh first column representing the lower
% limit of each frequency range and the second column representing the
% upper limit of each frequency range for which the mean power will be
% calculated.
%
% EXAMPLE:
%   adr = xtp_adr(spec, freqRanges)
%       where spec is a struct defined as above, freqRanges = [2 3.99;4
%       7.99;8 12.99;13 20]
% outputs a structure with the following fields: 
%   .info gives metadata about how the output variable was derived
%   .output is a structure array with one element per channel, and each
%   structure has the following fields:
%         .meanADR is an Nx3 matrix containing the mean power, errorbar max
%         and errorbar min for each frequency range given in the freqRange
%         inputs.
%
% Change Control
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   02/05/14    S. Williams     Created.
% DON'T FORGET TO UPDATE THE VERSION NUMBER BELOW.

funcname = 'xtp_adr.m';
version = 'v1.0';

adr.info = spec.info;
adr.info.datatype = 'ADR';
adr.info.generatedBy = funcname;
adr.info.version = version;
adr.info.rundate = clock;
adr.info.source = inputname(1);
adr.info.freqRanges = freqRanges;

f = spec.output{1}.f;   % assume it's the same across all channels, which it should be.
numFreqs = length(f);
numChans = length(spec.info.channelNames);

% First get a consolidated matrix of all power estimates across frequencies
% and channels
outputSA = cell2mat(spec.output);  % gives a structure array with ch elements

allS = [outputSA.S];    % gives an FxC matrix (F=# of frequencies, C=# of channels) (!)looks like choice of rows vs columns may be variable?
allS = reshape(allS,1,numFreqs, numChans);  % reorder the dimensions to 1xFxC 
allErr = [outputSA.err];   % should be 2xFC
allErr = reshape(allErr, 2,numFreqs,numChans);  %dimensions now 2xFxC
% safety check
if or(~isequal(permute(allS(1,:,numChans),[2 3 1]), spec.output{numChans}.S),...
        ~isequal(allErr(:,:,numChans),spec.output{numChans}.err))
    disp('ERROR: there seems to be a problem with the S or err matrix shapes');
    return;
end
allSandErr = allS;
allSandErr(2:3,:,:) = allErr;   % 3xFxC matrix with first plane = all powers, second two planes = errorbars


% now divide up into chunks of frequency ranges (like delta, theta, alpha,
% beta)

disp('using powerChunks cell')
tic
powerChunks = cell(1,size(freqRanges,1));   % I feel like I could do this without the cell and the for loop, e.g. with an array function...
for freqRangeNum = 1:length(powerChunks)
    powerChunks{freqRangeNum} = allSandErr(:,find(and(f>=freqRanges(freqRangeNum,1),f<freqRanges(freqRangeNum,2))),:); % 3 x fr x C where fr is the length of the frequency range
    frMean(:,freqRangeNum,:) = mean(powerChunks{freqRangeNum},2);   % mean power (S) and associated error bars witin the given frequency range
end
toc

disp('using arrayfun')
tic
altfrMean = arrayfun(@(x) mean(allSandErr(:,find(and(f>=freqRanges(x,1),f<freqRanges(x,2))),:),2), 1:size(freqRanges,1), 'UniformOutput', false);
altfrMean = cell2mat(altfrMean);    % 3 x fr x C 
toc

% see if they are the same
if isequal(frMean, altfrMean)
    disp('both methods of calculation for mean power in the frequency ranges are equivalent')
else
    disp('something is wrong, the calculations are not equivalent');
end

% add frequency means to the adr output variable
meanSbyFR = permute(altfrMean(1,:,:),[2 3 1]); % dimensions of .S will be fr x C
adr.output.meanSbyFR = meanSbyFR;
adr.output.meanErrByFR = permute(altfrMean(2:3,:,:), [2 3 1]); %dimensions of .err will be fr x C x 2
disp('assuming frequency ranges are listed in order of delta, theta, alpha, beta')
adr.output.adr = meanSbyFR(3,:)./meanSbyFR(1,:);
adr.output.dtabr = (meanSbyFR(1,:)+meanSbyFR(2,:))./(meanSbyFR(3,:)+meanSbyFR(4,:));
end