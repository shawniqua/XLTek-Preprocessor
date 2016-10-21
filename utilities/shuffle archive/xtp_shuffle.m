function shuffledspectra = xtp_shuffle(varargin)
% XTP_SHUFFLE    Shuffles data from trials among several spectra. Outputs
% bare bones 'spectra' with enough data to run analyses on. The output
% spectra all have he same number of trials (maxtrials based on the maximum
% number of trials of any input variable). Output is in the form of a cell
% array of variables.
%
% EXAMPLE: shuffledspectra = xtp_shuffle(sepc1, spec2, spec3...);
%
% Change Control:
% Ver   Date        Person      Change
% ----- ----------- ----------- -------------------------------------------
% 1.0   01/11/09    S. Williams Created
% 1.2   01/22/09    S. Williams updated to support new spectra output field
%                               names. fixed bug in calculation of
%                               numchannels
% 1.3   01/23/09    S. Williams remove requirement that all output spectra
%                               have same number of trials. Each should
%                               have same number of trials as it came in
%                               with.
% 1.4  01/23/09    S. Williams consolidated some loops & preallocated some
%                               variables for performance. added .info
%                               field and separate .data field
% DON'T FORGET TO UPDATE VERSION NUMBER BELOW!!!

funcname = 'xtp_shuffle.m';
version = 'v1.4';

shuffledspectra.info.generatedby = funcname;
shuffledspectra.info.version = version;
shuffledspectra.info.rundate = clock;

rand('state',sum(100*clock)); % (see help RAND)

nvars = length(varargin);
numchannels = length(varargin{1}.output); %assumes all spectra have the same number of channels
listofvars = '';

% find out how many trials each input variable is holding
numtrials = zeros(1,nvars);
isOld = zeros(1,nvars);
for v=1:nvars
    numtrials(v) = size(varargin{v}.metadata, 2);
    listofvars = [listofvars ' ' inputname(v)];
    isOld(v) = ~isfield(varargin{v}, 'info');
end
shuffledspectra.info.source = ['shuffled from:' listofvars];

numTrialsSoFar = 0;
for v=1:nvars
    eligibleTrials(numTrialsSoFar+1:numTrialsSoFar+numtrials(v)) = ...
        (v*1000)+(1:numtrials(v));
    numTrialsSoFar = numTrialsSoFar+numtrials(v);
end

%% next shuffle the trial numbers
tottrials = sum(numtrials);
neworder = randperm(tottrials);
randomOrderTrials = eligibleTrials(neworder);
sourceVars = floor(randomOrderTrials./1000);
sourceTrialnum = randomOrderTrials - (sourceVars*1000);

%% finally, assign values to each output variable based on the new trial
%  number selections
shuffledspectra.data = cell(1,nvars);
lastTrialAssigned = 0;
for v = 1:nvars
    shuffledspectra.data{v} = cell(1,numchannels);
    for t=1:numtrials(v)
        shuffledspectra.data{v}.metadata(t) = ...
            varargin{sourceVars(lastTrialAssigned+t)}.metadata(sourceTrialnum(lastTrialAssigned+t));
        for c=1:numchannels
            if varargin{sourceVars(lastTrialAssigned+t)}.cparams.err(1) >= 1
                shuffledspectra.data{v}.output{c}.err(:,:,t) = ...
                    varargin{sourceVars(lastTrialAssigned+t)}.output{c}.err(:,:,sourceTrialnum(lastTrialAssigned+t));
            end
            %and the moment we've all been waiting for...
            if isOld(v)
                shuffledspectra.data{v}.output{c}.f = varargin{sourceVars(lastTrialAssigned+t)}.output{c}.freqs;
                shuffledspectra.data{v}.output{c}.S(:,t) = ...
                    varargin{sourceVars(lastTrialAssigned+t)}.output{c}.powers(:,sourceTrialnum(lastTrialAssigned+t));
            else 
                shuffledspectra.data{v}.output{c}.f = varargin{sourceVars(lastTrialAssigned+t)}.output{c}.f;
                shuffledspectra.data{v}.output{c}.S(:,t) = ...
                    varargin{sourceVars(lastTrialAssigned+t)}.output{c}.S(:,sourceTrialnum(lastTrialAssigned+t));
            end
        end
    end
    lastTrialAssigned = lastTrialAssigned+numtrials(v);
end