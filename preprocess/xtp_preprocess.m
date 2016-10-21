% xtp_preprocess.m
%
% This is just a wrapper function to test run data through the whole process.
%
% EXAMPLE: filteredData = xtp_preprocess([params], [data], [cparams])
%
% CHANGE LOG:
% Ver  Date     Person          Change
% 1.0           S. Williams     Created
% 1.1  10/24/08 S. Williams     moved interactive entry of montage choice
%                               to v1.2 of xtp_montage
% 1.2  10/25/08 S. Williams     optional hard stop if xtp_cutSnippets
%                               raises warning (this should be added to all
%                               subroutines!)
% 1.3  10/31/08 S. Williams     call to subroutines dependent on 
%                               corresponding params fields set to 1.
% 1.4  11/03/08 S. Williams     added reminder for making epoch list global
% 1.5  01/13/09 S. Williams      control requirements for user input based on global
%                               'interactive' parameter
% 1.51 01/27/09 S. Williams     bugfix: get rawd interactively if it is not
%                               specified at the command line *NOTE THIS
%                               FIX IS NOT IN VERSION 1.6!!*
% 1.7  03/11/09 S. Williams     call xtp_readEpochs & pass epochlist +
%                               params to cutSnippets
% 1.71 03/11/09 S. Williams     remove warning about global epoch list
%                               variable
% 1.8  06/04/09 S. Williams     pass params to calls to xtp_montage &
%                               xtp_readXLTfile, fix dependency on
%                               params.interactive for plotting data
% 1.9  02/11/10 S. Williams     call xtp_filter regardless of filter
%                               params. let it decide whether to do any
%                               work or not.
% 1.10S 01/14/12 S. Williams    accept cparams and pass it to xtp_filter if
%                               available.
% 2.1S 01/17/12 S. Williams    accept data to cut even if cparams is
%                               passed
%DON'T FORGET TO UPDATE VERSION NUMBER BELOW!!!

function filtd = xtp_preprocess(params, data, cparams)

global XTP_HB_MONTAGES XTP_GLOBAL_PARAMS XTP_CHRONUX_PARAMS

funcname = 'xtp_preprocess';
version = 'v2.1S';

if isempty(XTP_HB_MONTAGES) || isempty(XTP_GLOBAL_PARAMS) || isempty(XTP_CHRONUX_PARAMS)
    fprintf(1,'Please load environment variables using\n "xtp_build_environment" or "load xtp_environment.mat"\n');
    filtd = 0;
    return
end

if nargin < 1
    params = XTP_GLOBAL_PARAMS;
    cparams = XTP_CHRONUX_PARAMS;
    fprintf(1, 'Using global parameters...\n');
end

if params.readXLTfile
    % if params.cutSnippets && params.interactive
        % fprintf(1,'This process will attempt to read an XLT file and cut snippets.\nPlease ensure the epoch list for cutting snippets is a GLOBAL variable!\n');
        % goahead = input('Continue? [Y/N]','s');
        %if ~strcmpi(goahead, 'Y')
        %    filtd = [];
        %    return
        %end
    % end
    rawd = xtp_readXLTfile(0,params);
else
    if nargin >= 2         %v2.1S >= instead of ==
        rawd = data;
    else
        % This line fixed in v1.51. It is NOT fixed in v1.6!!
        rawd = input('Please specify the data structure to be processed. ');
    end
end

if params.cutSnippets
    if params.interactive
        epochlist = xtp_readEpochs;
    else
        % can remove the following if statement once xtp_build_environment
        % is updated to include a default epochListFile. 
        if ~isfield(params, 'epochListFile')
            params.epochListFile = 'epochlist.txt';
        end
        epochlist = xtp_readEpochs(params.epochListFile);
    end
    [cutd status] = xtp_cutSnippets(rawd, epochlist, params);
    if status > 1 && params.interactive
        goahead = input('Continue? [Y/N]','s');
        if ~strcmpi(goahead, 'Y')
            filtd = [];
            return
        end
    end
else
    cutd = rawd;
end

if params.montageData
    montd = xtp_montage(cutd,params);
else
    montd = cutd;
end

prefiltd = xtp_prefilter(montd, params);


% v1.9 removed the if statement below - call xtp_filter regardless of params.apply*    
% if params.applyLPF || params.applyHPF || params.applyNotchFilter
    % v1.10S pass cparams if available
    filtd = xtp_filter(prefiltd, params, cparams);
% else
%     filtd = prefiltd;
% end



fprintf(1, 'Preprocess complete.\n'); 
%outvarname = input('How would you like to name this data? ', 's');
%(outvarname) = filtd;
%fprintf(1, 'OK, saved data to variable %s. Would you like to plot this now? ', outvarname);
if params.interactive && strcmpi(input('Plot data?[Y/N] ', 's'),'Y')
        xtp_plot(filtd, 1);
end

end