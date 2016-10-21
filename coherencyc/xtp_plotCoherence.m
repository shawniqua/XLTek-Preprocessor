function xtp_plotLines(coh, freqs, cohPairNums)
% Plots coherence values between unipolar channels as lines connecting
% channels, with the color and width of the line indicating the strength of
% the coherence at the given frequency/range of frequencies
%
% EXAMPLE: xtp_plotCoherence(coherence, [frequencies], [coherencyPairNums])
%
% Change Control:
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   05/26/09    S. Williams     Created

% ** DON'T FORGET TO UPDATE VERSION IN THE CODE BELOW!!! **

funcname = 'xtp_plotCoherence.m';
version = 'v1.0';

global XTP_HEADBOXES XTP_GLOBAL_PARAMS XTP_PLOT_LOCATIONS

