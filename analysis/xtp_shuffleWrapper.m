function stats = xtp_shuffleWrapper(statistics, varargin)
% xtp_shuffleWrapper    iteratively repeats a call to xtp_shuffle, running
% a test statistic of the users choice on the shuffled data. Takes as input
% the specs on the statistics function to call, in the form of a structure
% with the following fields:
%
% statistics.function: string containing the function name to be called
% statistics.inputs: structure containing the 2nd through nth variables to pass
%                    to the statistics function. It is assumed that the
%                    first input variable is an T X F matrix of the shuffled
%                    data (F = freqencies, T = trials).
% statistics.outputs: cell array with names of the output variables to pass
%                     to the statistics function.
%
%                     The fields in inputs and strings in outputs must
%                     appear in the order that they will be passed to the
%                     statistics function.
%
% The remaining variables contain the spectral data to be shuffled.
%
% The program outputs an R x C structure array with R = number of repeat
% iterations and C = number of channels of data. Each element contains the
% results from the statistics function (one field for each output variable)
%
% EXAMPLE:
%   stats = xtp_shuffleWrapper(statistics, spec1, spec2, spec3...)
%
% Change Control
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   01/12/09    S. Williams     Created.
% 1.1   01/22/09    S. Williams     output metadata to info field (instead
%                                   of funcinfo). convert shuffled data
%                                   into a TxFxC cube for processing by the
%                                   specified statistics function
% 1.2   01/23/09    S. Williams     updated with new structure of shuffled
%                                   spectra
% 1.3   01/29/09    S. Williams     updated stats.output with new field .f
%                                   for frequencies, copied from the first
%                                   input variable
% DON'T FORGET TO UPDATE THE VERSION NUMBER BELOW.

funcname = 'xtp_shuffleWrapper.m';
version = 'v1.3';

numrepeats = 500;

nvars = nargin - 1;
numchannels = size(varargin{1}.output, 2);
nfreqs = size(varargin{1}.output{1}.f,2);
stats.info.generatedby = [funcname ' ' version];
stats.info.rundate = clock;
stats.info.statistics = statistics;
stats.output = struct;      

stats.output.f = varargin{1}.output{1}.f;

%% building the calls to the statistics function
% statcmd1 is for the original measured dataset
% statcmd2 is for the shuffled data

stinvarnames = fieldnames(statistics.inputs);
nstinvars = length(stinvarnames);
nstoutvars = length(statistics.outputs);

statcmd1 = '[';
statcmd2 = '[';
for stv=1:nstoutvars
    statcmd1 = [statcmd1 ' stats.measured(c).' statistics.outputs{stv}];
    statcmd2 = [statcmd2 ' stats.output(r,c).' statistics.outputs{stv}];
end
statcmd1 = [statcmd1 '] = ' statistics.function '(data'];
statcmd2 = [statcmd2 '] = ' statistics.function '(data'];
for stv=1:nstinvars
    statcmd1 = [statcmd1 ', statistics.inputs.' stinvarnames{stv}];
    statcmd2 = [statcmd2 ', statistics.inputs.' stinvarnames{stv}];
end
statcmd1 = [statcmd1 ');']; 
statcmd2 = [statcmd2 ');']; 

%% run stats on measured data
for c=1:numchannels
    data = zeros(nvars, nfreqs);
    for v=1:nvars
        if isfield(varargin{v}, 'info')
            data(v,:) = mean(varargin{v}.output{c}.S,2)';
        else
            data(v,:) = mean(varargin{v}.output{c}.powers,2)';
        end
    end
    eval(statcmd1);
end

%% iteratively shuffle and run stats
for r=1:numrepeats
    shuffledSpec = xtp_shuffle(varargin{:});
    % won't be able to make a data cube with different numbers of trials
    % for each variable. I will average them on the fly - this is useful
    % for the current analysis... not sure about the future...
    % 
    for c=1:numchannels
        data = zeros(nvars,nfreqs);
        for v=1:nvars
            data(v,:) = mean(shuffledSpec.data{v}.output{c}.S,2)';    
        end
        eval(statcmd2);
    end
end
end