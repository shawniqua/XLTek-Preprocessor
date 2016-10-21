function pvals = xtp_findPvals(stats, plotfield)
% hardcoded function to generate p values given a list of variances that
% were calculated as output from xtp_shuffleWrapper
%
% EXAMPLE:  pvals = xtp_findPvals(stats, plotfield)
%
% Change Control:
% Ver   Date        Person      Change
% ----- ----------- ----------- -------------------------------------------
% 1.0   01/23/09    S. Williams Created.
% 1.1   01/29/09    S. Williams Genericized to take an output field instead
%                               of harcoding variances as the field to
%                               plot. Also take advantage of new .f field
%                               (only available in xtp_shuffleWrapper v1.3
%                               and above) to plot frequencies (instead of
%                               harcoded range)
% 1.2   01/30/09    S. Williams change generatedby to generatedBy, use
%                               info.fbands field if it exists for xticks
% DON'T FORGET TO UPDATE VERSION NUMBER BELOW

funcname = 'xtp_findPvals.m';
version = 'v1.2';

global XTP_HB_MONTAGES
maxfreq = 100;

pvals.info.generatedBy = funcname;
pvals.info.version = version;
pvals.info.rundate = clock;
pvals.info.source = inputname(1);

[numreps numchannels] = size(stats.output);
numfreqs = length(stats.output(1).(plotfield));

for r=1:numreps
    for c=1:numchannels
        cube(r,c,:) = stats.output(r,c).(plotfield);
    end
end

for c=1:numchannels
    for f=1:numfreqs
        pvals.output(c,f) = sum(cube(:,c,f)>stats.measured(c).(plotfield)(f))/numreps;
    end
end

x=maxfreq*[1:numfreqs]/numfreqs;    % frequency bins for plotting (REVIEW RANGES, NOTE HARDCODING)
y=[1:numchannels];

figure;
ih = image(x,y,pvals.output, 'CDataMapping', 'scaled');
colorbar
set(gca, 'YTick',y,'YTickLabel', XTP_HB_MONTAGES(1).channelNames)
if isfield(stats.info, 'fbands')
    xlabels=cellstr(num2str(stats.info.fbands));
    xticks = stats.info.f;
    set(gca, 'XTickLabel', xlabels);
else
    xlabels=stats.info.f;
end
xlabel 'frequency (Hz)'
title(inputname(1))
end