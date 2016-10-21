function [cg pca] = xtp_pcaWrapper(timeseries, cohPairListID, cparams, PCAparams)
% takes a time series and runs coherogram, then pca, then plots both.
%EXAMPLE:
%   [cg pca] = xtp_pcaWrapper(timeseries, cohPairList, [cparams], [PCAparams])
% where cparams is a structure with the following fields:
%   .tapers         [NW K]
%   .Fs             sampling frequency 
%   .fpass          [lower upper]
%   .pad            -1 for no padding
%   .err            [type   p] where type=0 for none, 1 for theoretical, 2 for jackknife
%   .trialave       0=no, 1=yes
%   .movingwin      [winsize winstep]
%
% and PCAparams is a structure with the following fields:
%   .cohpair        index of the coherency pair to analyze (default 1)
%   .pca_submean    1 to demean data, 0 to not (this is presumably
%                   redundant) Default 0
%   .pca_maxfreq    maximum frequency to use for PCA calculations (default
%                   is the max frequency for the first epoch)
%   .pca_ntoplot    # of principal components to plot (default 3)
%   .ifsurr         1 to generate surrogate data, 0 to not (default 0)
%
%   See also:  PHACOLOR, SURR_CORRGAU2, TEXT2SPECGRAM_DEMO.
%
% Dependencies: getinp
%
% CHANGE CONTROL
% Ver   Date        Person      Changes
% ----- ----------- ----------- -------------------------------------------
% 1.0   04/16/09    S. Williams Created from parse_spec_demo (3rd attempt)

% NEXT: REDESIGN FOR UNEQUAL LENGTH TRIALS. THEN DEFINE PLIST, TVALS, T, DT, PCAparams.

funcname = 'xtp_pcaWrapper.m';
version = 'v1.0';

global XTP_GLOBAL_PARAMS XTP_CHRONUX_PARAMS

if nargin < 4
    PCAparams.pca_submean = 1;
    PCAparams.pca_maxfreq = cparams.fpass(2);
    PCAparams.pca_ntoplot = 3;
    PCAparams.ifsurr = 0;
    if nargin < 3
        cparams = XTP_CHRONUX_PARAMS;
        if nargin < 2
            cohPairListID = 0;
        end
    end 
end

cg = xtp_cohgramc(timeseries, cohPairListID, cparams);
pca = xtp_pca(cg, PCAparams);

xtp_plotCohgram(cg, timeseries)
xtp_plotPCA(pca)
end