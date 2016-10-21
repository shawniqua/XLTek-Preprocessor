function localPeaks = xtp_localPeaks(freqRange, varargin)
% finds the local max within a given frequency range for a list of spectra
% Frequency range should be a 2-element matrix in the form of [lowF highF].
% localPeaks is a structure array, with three fields: spectrum is the name
% of the spectrum from which the peaks were taken, peakFreqs contains the 
% frequency location of the peak power value, peakS contains the peak power
% value itself. Each field is in the form of a CxT matrix where C = number 
% of channels and T = number of trials. 
% 
% EXAMPLE: localPeaks = xtp_localPeaks([5 13], spectra1, spectra2, ...)
%
% Change Control
% Ver   Date        Person          Change
% 1.0   01/31/09    S. Williams     Created
%NEED TO DEBUG. this is coming out with peakFreqs that are not within the
%range given!!

numspecs = length(varargin);
localPeaks = struct;
for s=1:numspecs
    localPeaks(s).spectrum = inputname(s+1);
    numchannels = size(varargin{s}.output, 2);
    firstfreqID = find(varargin{s}.output{1}.freqs>=freqRange(1), 1, 'first'); 
    lastfreqID = find(varargin{s}.output{1}.freqs<freqRange(2), 1, 'last');
    for c=1:numchannels
        [localPeaks(s).peakS(c,:) I(c,:)] = max(varargin{s}.output{c}.powers(firstfreqID:lastfreqID,:));
        localPeaks(s).peakFreqs(c,:) = varargin{s}.output{c}.freqs(I(c,:));
    end
end
