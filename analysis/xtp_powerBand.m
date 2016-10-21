function pbSpec = xtp_powerBand(fbands, spectrum, sumORmean)

% This function, given a power psectrum, generates the corresponding
% spectrum with coarser aggregation of frequencies as determined by the
% fband input variable. Determines confidence intervals empirically,
% assuming log power is normally distributed.
%
% fband should be an Fx2 array with ranges of frequencies for which
% to calculate the power. One row per frequency band. 
%
% EXAMPLE:
%       pbSpec = xtp_powerBand(fbands, spectrum, sumORmean)
% sumORmean should be an 's' for sum or an 'm' for mean. Default is sum.
%
% Ver 	Date 	 Person         Change
% 1.0 	12/10/08 S. Williams 	Created xtp_collectPowerBand
% 2.0   01/23/09 S. Williams    one to one spectra in/out 
% 2.1   01/30/09 S. Williams    changed generatedby to generatedBy
% 3.0   02/12/09 S. Williams    calculate confidence intervals empirically
%                               convert to log power to generate sample
%                               curves with the same distribution of the
%                               log power as the input spectrum at each
%                               frequency. also provide rundate and more
%                               sensible frequencies.
% 3.1   03/11/09 S. Williams    support for coherency spectra & average
%                               instead of total
%                               
% DON'T FORGET TO UPDATE THE VERSION NUMBER BELOW.

funcname = 'xtp_powerBand.m';
version = 'v3.1';

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

if nargin < 3
    calculateMean = 0;
else
    calculateMean = strcmpi(sumORmean, 'm');
end

% support for coherency
switch spectrum.info.datatype
    case 'COHERENCY'
        datafield = 'C';
        errfield = 'Cerr';
    otherwise
        datafield = 'S';
        errfield = 'err';
end

% First: only take frequencies that are spaced W apart (W = bandwidth
% parameter used for multitaper spectral estimate)

numfreqs = length(spectrum.output{1}.f);
% stepsize = (spectrum.info.cparams.fpass(2)-spectrum.info.cparams.fpass(1))/numfreqs;
% numsteps = ceil(W/stepsize);
findexes = spectrum.info.cparams.tapers(1):spectrum.info.cparams.tapers(2):numfreqs;
% findexes = NW:K:numfreqs;                 % Only sum powers for every Kth 
                                            % frequency, starting with the
                                            % NWth frequency.
newf = spectrum.output{1}.f(findexes);
newnumfreqs = length(findexes);
fbindexes = zeros(size(fbands));
for band = 1:size(fbands,1)
    fbindexes(band,:) = [find(newf >= fbands(band,1),1,'first'), find(newf < fbands(band,2),1,'last')];     % note these are indexes of the newf array and can not be used on arrays from the original spectrum!
end

meanlp = zeros(numchannels,newnumfreqs);
stddevlp = zeros(numchannels,newnumfreqs);
pbSpec.output = cell(1,numchannels);
for c=1:numchannels
    % support for coherences
    if strcmpi(spectrum.info.datatype,'COHERENCY')
        spectrum.output{c}.S = spectrum.output{c}.C;
        spectrum.output{c}.err = spectrum.output{c}.Cerr;
    end
    
    % Next: Identify the mean and std dev of log power for each chosen f
    newS = spectrum.output{c}.S(findexes);
    meanlp = log10(newS)';	
    stddevlp = (log10(spectrum.output{c}.err(2,findexes))-log10(spectrum.output{c}.err(1,findexes)))./3.92; %assumes spectra calculated on 95% confidence intervals
    
    % Next, generate 1000s of sample curves with the same distribution of log
    % powers at each chosen frequency
    numcurves = 10000;
    curves = randn(numcurves,newnumfreqs);
    means = ones(numcurves,1)*meanlp;
    stddevs = ones(numcurves,1)*stddevlp;
    curves = means + (stddevs.*curves);
    % return from log to base powers
    curves = 10.^curves;
    
    % For each curve, integrate the power over each frequency band, 
    % selecting only the chosen frequencies.
    % must do this for the real data as well as the empiric samples.
    sumOrMeanPowers = zeros(numcurves,size(fbands,1));
    output = zeros(size(fbands,1),1);
    for band = 1:size(fbands,1)
        if calculateMean
            output(band,1) = mean(newS(fbindexes(band,1):fbindexes(band,2)));
            sumOrMeanPowers(:,band) = mean(curves(:,fbindexes(band,1):fbindexes(band,2)),2);
        else
            output(band,1) = sum(newS(fbindexes(band,1):fbindexes(band,2)));
            sumOrMeanPowers(:,band) = sum(curves(:,fbindexes(band,1):fbindexes(band,2)),2);
        end
    end
    pbSpec.output{c}.(datafield) = output;

    % Now: sort each column independently from least to greatest, and take
    % the top and bottom 2.5% (again assuming 95% confidence intervals)
    sortedPowers = sort(sumOrMeanPowers);
    errorbars(1,:) = sortedPowers(floor(numcurves*0.025),:);
    errorbars(2,:) = sortedPowers(ceil(numcurves*0.975),:);
    pbSpec.output{c}.(errfield) = errorbars;
    % also don't forget the f and S fields in the output spectrum!!
    pbSpec.output{c}.f = fbands(:,1)';
    
end
end