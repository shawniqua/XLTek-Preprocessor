function pbSpec = xtp_powerBand(fbands, spectrum)

% This function, given a power psectrum, generates the corresponding
% log spectrum with coarser aggregation of frequencies as determined by the
% fband input variable
%
% fband should be an Fx2 array with ranges of frequencies for which
% to calculate the power. One row per frequency band. 
%
% EXAMPLE:
%       pbSpec = xtp_powerBand(fbands, spectrum)
%
% Ver 	Date 	 Person         Change
% 1.0 	12/10/08 S. Williams 	Created xtp_collectPowerBand
% 2.0   01/23/09 S. Williams    one to one spectra in/out 
% 2.1   01/30/09 S. Williams    changed generatedby to generatedBy
% 3.0   02/12/09 S. Williams    integrate log power instead of power.
%                               calculate confidence intervals empirically.
% DON'T FORGET TO UPDATE THE VERSION NUMBER BELOW.

funcname = 'xtp_powerBand.m';
version = 'v3.0';

numchannels = size(spectrum.output, 2);
pbSpec = spectrum;
pbSpec.info.generatedBy = funcname;
pbSpec.info.version = version;
pbSpec.info.rundate = clock;
pbSpec.info.source = inputname(2);
pbSpec.info.fbands = fbands;
pbSpec = rmfield(pbSpec, 'output');

if spectrum.info.cparams.trialave ~= 1
    fprintf(1,'ERROR: this only works on non-trialaveraged spectra - sorry!\n');
    return;
end

% First: only take frequencies that are spaced W apart (W = bandwidth
% parameter used for multitaper spectral estimate)
[NW K] = spectrum.info.cparams.tapers;      % Only sum powers for every Kth 
                                            % frequency, starting with the
                                            % NWth frequency.
numfreqs = length(spectrum.output{1}.f);
% stepsize = (spectrum.info.cparams.fpass(2)-spectrum.info.cparams.fpass(1))/numfreqs;
% numsteps = ceil(W/stepsize);
findexes = NW:K:numfreqs;
newf = spectrum.output{1}.f(findexes);
newnumfreqs = length(findexes);
fbindexes = zeros(size(fbands));
for band = 1:size(fbands,1)
    fbindexes(band,:) = [find(newf >= fbands(band,1),1,'first'), find(newf < fbands(band,2),1,'last')];
end

meanlp = zeros(numchannels,newnumfreqs);
stddevlp = zeros(numchannels,newnumfreqs);
pbSpec.output = cell(1,numchannels);
for c=1:numchannels
    % Next: Identify the mean and std dev of log power for each chosen f
    meanlp(c,:) = log10(spectrum.output{c}.S(findexes));	% CxF matrix, F = new numfreqs, C = numchannels
    stddevlp(c,:) = (log10(spectrum.output{c}.err(2))-log10(spectrum.output{c}.err(1)))./3.92; %assumes spectra calculated on 95% confidence intervals
    
    % Next, generate 1000s of sample curves with the same distribution of log
    % powers at each chosen frequency
    numcurves = 10000;
    curves = randn(numcurves,newnumfreqs);
    means = ones(numcurves,1)*meanlp(c,:);
    stddevs = ones(numcurves,1)*stddevlp(c,:);
    curves = means + (stddevs.*curves);
    % return from log to base powers
    curves = 10.^curves;
    
    % For each curve, integrate the power over each frequency band, 
    % selecting only the chosen frequencies.
    % must do this for the real data as well as the empiric samples.
    sumPowers = zeros(numcurves,size(fbands,1));
    for band = 1:size(fbands,1)
        pbSpec.output{c}.S(1,band) = sum(spectrum.output{c}.S(fbindexes(band,1):fbindexes(band,2)));
        sumPowers(:,band) = sum(curves(:,fbindexes(band,1):fbindexes(band,2)),2);
    end

    % Now: sort each column independently from least to greatest, and take
    % the top and bottom 2.5% (again assuming 95% confidence intervals)
    sortedLogPowers = sort(sumLogPowers);
    pbSpec.output{c}.err(1,:) = sortedLogPowers(floor(numcurves*0.025),:);
    pbSpec.output{c}.err(2,:) = sortedLogPowers(ceil(numcurves*0.975),:);
    
    % also don't forget the f and S fields in the output spectrum!!
    pbSpec.output{c}.f = fbands(:,1);
    
end
end