% ANALYSIS
%
% Files
%   xtp_powerBand             - Given a power spectrum, generates the
%                               corresponding spectrum with total power
%                               integrated over frequency bands you specify.
%   xtp_shuffle               - Shuffles data from trials among several spectra. 
%   xtp_shuffleWrapper        - iteratively repeats a call to xtp_shuffle,
%                               running a test statistic of your choice on
%                               the shuffled data.
%   xtp_findPvals             - hardcoded function to generate p values
%                               given a list of variances that that were
%                               calculated as output from xtp_shuffleWrapper.
