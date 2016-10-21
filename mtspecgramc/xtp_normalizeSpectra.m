function [ sgramOut ] = xtp_normalizeSpectra(sgramIn, refSpec)
% given a spectrogram and a reference spectral profile, outputs the log-normalized
% spectrogram by 1) taking the log power of both the spectrogram and the
% reference spectrogram, 2) getting the mean and standard deviation of the
% log power across all included frequencies in reference spectral curve,
% and 3) subtracting the reference mean, dividing by reference standard deviation
%   
% Usage: sgramOut = xtp_normalizeSpectra(sgramIn, referenceSpec)
%
% CHANGE CONTROL
% Date      Ver     Change
% --------- ----    -------------------------------------
% 07/31/16  1.0     Created
% 08/10/16  2.0     Revised normalization technique, use log-transformed
%                   data

runParams = sgramIn.info.auditTrail(end).params;
% runParams.source = inputname(1);
runParams.refSpec = inputname(2);
sgramOut = xtp_auditTrail(sgramIn, 'xtp_normalizeSpectra', 'v1.0', clock, runParams);
% sgramOut.info.datatype = 'SPECTROGRAM';
sgramOut.info.auditTrail(end).source = inputname(1);
if sgramIn.info.auditTrail(end).params.fpass ~= refSpec.info.cparams.fpass
    disp('ERROR: sgramIn should contain the same frequencies as the baseline spectrum');
    return
end
% freqHist = histogram(refSpec.output{1}.f, length(sgramIn.output{1}.f), 'BinLimits', sgramIn.info.cparams.fpass);
% freqHist.BinEdges

% for each epoch and for each channel, I would ultimately like to normalize
% (divide) the S and Serr in each frequency band (sgramIn.output{:}.S(:,(freq),chNum)0
% by the mean of S for the frequencies in that corresponding band on the
% reference spectrum. As a first approximation I could (if necessary)
% assume the frequency resolution is higher in the reference power spectrum
% than in the input spectrogram. 

% However as a first step I am going to get the mean power across
% frequencies in the reference power spectrum and for each timepoint in the
% input spectrogram (for each channel and for each
% epoch).

numFreqs = length(sgramIn.output{1}.f);
refSA = cell2mat(refSpec.output);
refSmat = [refSA.S]; % F x C matrix of spectral power, where F is the frequencies used and C is the channels
logRefSm = mean(log10(refSmat),1);         % 1 x C mean reference power in the (total) frequency range for each channel **NOTE I LOG TRANSFORM AS IS DONE IN Collard et al 2016
logRefSsd = std(log10(refSmat),0,1);
% normS = cell(length(sgramIn.output));
% normSerr = cell(length(sgramIn.output));
for epochNum = 1:length(sgramIn.output)
%     meanS = mean(log10(sgramIn.output{epochNum}.S),2);  % (time x F x ch) where F = a single frequency [range]
%     stdS = std(log10(sgramIn.output{epochNum}.S),0,2);
%     meanSerr = mean(log10(sgramIn.output{epochNum}.Serr),3); % (errbarlim x time x F x ch) **assuming ERRORBARS ARE EXPRESSED IN ABSOLUTE NUMBERS not IN DIFFERENCES FROM THE S VALUE
%     stdSerr = std(log10(sgramIn.output{epochNum}.Serr),0,3);
%     sgramOut.output{epochNum}.S = meanS.\repmat(permute(refSm, [3 1 2]), size(meanS,1), 1, 1);
%     sgramOut.output{epochNum}.Serr = meanSerr.\repmat(permute(refSm, [4 3 1 2]), 2, size(meanSerr,2), 1, 1); 
%     sgramOut.output{epochNum}.f = mean(sgramIn.output{epochNum}.f);
    epochLen = size(sgramIn.output{epochNum}.S,1);
    sgramOut.output{epochNum}.S = (log10(sgramIn.output{epochNum}.S) - repmat(logRefSm, epochLen, numFreqs, 1))./repmat(logRefSsd,epochLen, numFreqs, 1);
    sgramOut.output{epochNum}.Serr = (log10(sgramIn.output{epochNum}.Serr) - repmat(logRefSm, 2, epochLen%%UR HERE
end

% not sure we really need to carry around the timeseries data.
if isfield(sgramOut, 'data')
    sgramOut = rmfield(sgramOut, 'data');
end
end