function [pctDifference myCIspectrum] = xtp_checkSpectrumCI(spectrum, spectrumNT)
% xtp_checkSpectrumCI   calculates 95% confidence intervals on a
% non-trialaveraged spectrum and compares it with existing calculations on
% a corresponding power spectrum. N is treated as (# of trials * # of
% tapers). 
%
% EXAMPLE: [pctDifference myCIspectrum] = xtp_checkSpectrumCI(spectrum, spectrumNT)
%
% Change Control
% Ver   Date        Person      Change
% ----- ----------- ----------- -------------------------------------------
% 1.0   12/06/08    S. Williams created.

numchannels = size(spectrum.output,2);
numtrials = size(spectrum.metadata,2);
numtapers = spectrum.cparams.tapers(2);
numfreqs = length(spectrum.output{1}.freqs);
sqrtN = sqrt(numtrials*numtapers);
sqrtNminus1 = sqrt (numtrials*numtapers-1);
myCIspectrum = spectrum;
myCIspectrum.source = [myCIspectrum.source 'CI'];
pctDifference = cell(numchannels,1);

for c=1:numchannels
    chronuxCI = spectrum.output{c}.err(2,:) - spectrum.output{c}.err(1,:);
    meanPower = mean(spectrumNT.output{c}.powers,2); %single column
    meanPower = meanPower*ones(1,numtrials);    %duplicate to form matrix
    sumofsquares = numtapers*sum((spectrumNT.output{c}.powers - meanPower).^2,2);
    mystddev = sqrt(sumofsquares)./sqrtNminus1;
    myCI = 3.92*mystddev./sqrtN;
    myCIspectrum.output{c}.err(1,:) = spectrum.output{c}.powers'-0.5*myCI';
    myCIspectrum.output{c}.err(2,:) = spectrum.output{c}.powers'+0.5*myCI';
    pctDifference{c} = (myCI - chronuxCI')./myCI;
    badapples = sum(pctDifference{c}>0.05);
    fprintf(1, 'Channel %d: There are %d out of %d frequencies where chronuxCI width is \n',c, badapples, numfreqs);
    fprintf(1,'more than 5 percent smaller than my calculated 95 pct CI. \n');
end