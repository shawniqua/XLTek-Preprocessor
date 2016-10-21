function [pctdifference myCI chronuxCI] = xtp_checkCI(spectrum, NTspectrum)
% This function compares the confidence interval indicated by
% spectrum.output{t}.err on the trialaveraged spectrum to 3.92*the standard
% error of the mean, calculated from the analogous nontrialaveraged
% spectrum.
%
% EXAMPLE: xtp_checkCI(spectrum, NTspectrum)
%
% Ver   Date        Person          Change
% 1.0   12/5/08     S. Williams     Created.

numchannels = size(spectrum.output,2);
numtapers = spectrum.cparams.tapers(2);
numtrials = size(NTspectrum.output{1}.powers,2);
sqrtN = sqrt(numtrials * numtapers);
% sqrtT = sqrt(numtrials);
numfreqs = length(spectrum.output{1}.freqs);
pctdifference = zeros(numchannels,numfreqs);
for c=1:numchannels
    myCI = 3.92*std(NTspectrum.output{c}.powers,0,2)'./sqrtN;
    chronuxCI = spectrum.output{c}.err(2,:)-spectrum.output{c}.err(1,:);
    pctdifference(c,:) = abs(myCI-chronuxCI)./myCI;
end
sig = sum(pctdifference > 0.05,2);
for c=1:numchannels
    fprintf(1,'Of %d frequencies, %d in channel %d have CI greater than 0.05 difference from what I calculated.\n',numfreqs,sig(c),c);
end
end
    