% xtp_prefilter.m
% 
% This function, given a datastructure containing (montaged) eeg data,
% transforms each snippet to a matlab timeseries and detrends the data. It
% then returns the detrended data in a similar datastructure (with
% accompanying metadata).
%
% The parameters passed should include a setting for prefiltering. Valid
% values are:
%   'constant'    remove DC component of the signal
%   'linear'      remove linear component of the signal
%   'none'        do not process the signal
%
% If the parameter is left blank or is not supplied, it is taken from the
% global variable XTP_GLOBAL_PARAMS.prefiltering
%
%EXAMPLE: prefilteredData = xtp_prefilter(montagedData, params);
%

% Change Log:
% Ver Date      Person      Change
% --- --------- ----------- ---------------------------------------------
% 1.0 10/18/08  S. Williams Created.
% 1.1 10/24/08  S. Williams Changed options to CONSTANT, LINEAR or NONE,
%                           passed directly from params to detrending
%                           function. Also removed use of matlab timeseries
%                           and added prefiltering field to metadata
% 1.2 05/15/09  S. Williams monage .ifno field
%DON'T FORGET TO UPDATE VERSION BELOW!!!

function prefilteredData = xtp_prefilter(montagedData, params)

global XTP_GLOBAL_PARAMS

funcname = 'xtp_prefilter';
version = 'v1.2';

if nargin < 2
    params = XTP_GLOBAL_PARAMS;
end

if ~isfield(params, 'prefiltering')
    params.prefiltering = XTP_GLOBAL_PARAMS.prefiltering;
end

if strcmpi(params.prefiltering, 'none')
    message = 'Prefiltering option set to NONE.';
    disp(message);
    prefilteredData = montagedData;
    return
end

prefilteredData = montagedData;
prefilteredData.info.datatype = 'TIMESERIES';
prefilteredData.info.generatedBy = funcname;
prefilteredData.info.version = version;
prefilteredData.info.source = inputname(1);
prefilteredData.info.rundate = clock;

numMDsnippets = size(montagedData.data,2);
for mds=1:numMDsnippets
%   following 3 lines removed in v1.1
%    ts = timeseries(montagedData.data{1,mds});                        
%    dts = detrend(ts, params.prefiltering);                            
%    prefilteredData.data{1,mds} = dts.Data;
    prefilteredData.data{1,mds} = detrend(montagedData.data{1,mds}, params.prefiltering);       %added in v1.1
    prefilteredData.metadata(mds).prefiltering = params.prefiltering;
end

end