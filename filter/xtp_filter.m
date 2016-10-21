% xtp_filter.m
%
% This function takes an XLTek preprocessor data structure (with fields
% metadata and data) and applies the filters as specified by the following
% PARAMS fields:
%   .applyLPF           1 if yes, 0 if no
%   .LPFalgorithm       e.g. 'butter' or 'besself'
%   .LPForder           filter order 
%   .LPFfrequency       low pass frequency cutoff
%   .applyHPF           1 if yes, 0 if no
%   .HPFalgorithm       e.g. 'butter' 
%   .HPForder           filter order 
%   .HPFfrequency       high pass frequency cutoff
%   .applyNotchFilter   1 if yes, 0 if no
%   .notchAlgorithm     e.g. 'butter' or 'rmlinesc'
%   .notchOrder         filter order 
%   .notchFreq          xtp_filter will filter from 1Hz below to 1Hz above
%
%EXAMPLE: filteredData = xtp_filter(prefilteredData, params, [cparams])
%   where params are as defined above, and cparams is a structure including
%   fields: .tapers, .Fs, .fpass, .pad, .P as described in chronux manual
%   for rmlinesc routine (cparams is only required if notchAlgorithm =
%   rmlinesc)
%

% Change Log:
% Ver   Date     Person         Change
% ---   -------- -----------    ---------------------------------------------
% 1.0   10/18/08 S. Williams    Created.
% 1.1   10/24/08 S. Williams    Added tracking of filterparams in metadata.
%                               this may be too much data for large datasets.
% 1.11  10/25/08 S. Williams    filterparams need to go in the for loop!
% 1.2   12/09/08 S. Williams    notch high and low set to equal input parameter
% 1.3   01/27/09 S. Williams    reset notch high & low to 1Hz above & below
%                               input parameter
% 1.4   05/15/09 S. Williams    manage .info field, support chronux
%                               rmlinesc function for notch filtering 
% 1.5   02/11/10 S. Williams    use switch/case instead of if/then for
%                               filter algorithms.
% 1.6   05/13/10 S. Williams    call to rmlinesc uses p value from cparams 
% 1.7   05/18/10 S. Williams    call xtp_auditTrail
%DON'T FORGET TO UPDATE VERSION NUMBER BELOW.

function filteredData = xtp_filter(prefilteredData, params, cparams)

global XTP_GLOBAL_PARAMS XTP_CHRONUX_PARAMS

funcname = 'xtp_filter';
version = 'v1.7';

if nargin < 3
    cparams = XTP_CHRONUX_PARAMS;
    if nargin < 2
        params = XTP_GLOBAL_PARAMS;
    end
end

filteredData = prefilteredData;
filteredData.info.datatype = 'TIMESERIES';
filteredData.info.generatedBy = funcname;
filteredData.info.version = version;
filteredData.info.source = inputname(1);
filteredData.info.rundate = clock;

numPFsnippets = size(prefilteredData.data,2);
for s=1:numPFsnippets
    srate = prefilteredData.metadata(s).srate;
    if params.applyLPF
        switch params.LPFalgorithm
            case 'butter'
                LPFnormalizedCutoff = params.LPFfrequency*2/srate;
                [lpfb lpfa] = butter(params.LPForder, LPFnormalizedCutoff, 'low');
                prefilteredData.data{s} = filter(lpfb, lpfa, prefilteredData.data{s});
            otherwise
                message('Hmmm, you want a low pass filter but I only support butterworth at this time. Please choose butter in the LPFalgorithm field.');
                disp(message);
        end
    end
    if params.applyHPF
        switch params.HPFalgorithm
            case 'butter'
                HPFnormalizedCutoff = params.HPFfrequency*2/srate;
                [hpfb hpfa] = butter(params.HPForder, HPFnormalizedCutoff, 'high');
                prefilteredData.data{s} = filter(hpfb, hpfa, prefilteredData.data{s});
            otherwise
                message('Hmmm, you want a high pass filter but I only support butterworth at this time. Please choose butter in the HPFalgorithm field.');
                disp(message);
        end
    end
    if params.applyNotchFilter
        switch params.notchAlgorithm
            case 'butter'
                stopband = [(params.notchFreq-1)*2/srate (params.notchFreq+1)*2/srate]; % removed in v1.2, added back in v1.3
   %            stopband = [(params.notchFreq)*2/srate (params.notchFreq)*2/srate];     % added in v1.2
                [notchb notcha] = butter(params.notchOrder, stopband, 'stop');
                prefilteredData.data{s} = filter(notchb, notcha, prefilteredData.data{s});
            case 'rmlinesc'
                prefilteredData.data{s} = rmlinesc(prefilteredData.data{s}, cparams, cparams.err(2)/size(prefilteredData.data{s},2), 'n', params.notchFreq);
            otherwise
                message('Hmmm, you want a notch filter but I only support butterworth and rmlinesc at this time. \nPlease choose butter or rmlinesc in the notchAlgorithm field.');
                disp(message);
        end
    end
    filteredData.data{s} = prefilteredData.data{s};
    %copy in filter parameters for tracking purposes. This assumes only one
    %pass through xtp_filter!
    filteredData.metadata(s).filterparams.applyLPF = params.applyLPF;
    filteredData.metadata(s).filterparams.LPFalgorithm = params.LPFalgorithm;
    filteredData.metadata(s).filterparams.LPForder= params.LPForder;
    filteredData.metadata(s).filterparams.LPFfrequency= params.LPFfrequency;       
    filteredData.metadata(s).filterparams.applyHPF= params.applyHPF;           
    filteredData.metadata(s).filterparams.HPFalgorithm= params.HPFalgorithm;       
    filteredData.metadata(s).filterparams.HPForder= params.HPForder;           
    filteredData.metadata(s).filterparams.HPFfrequency = params.HPFfrequency;       
    filteredData.metadata(s).filterparams.applyNotchFilter= params.applyNotchFilter;   
    filteredData.metadata(s).filterparams.notchAlgorithm= params.notchAlgorithm;     
    filteredData.metadata(s).filterparams.notchOrder= params.notchOrder;         
    filteredData.metadata(s).filterparams.notchFreq= params.notchFreq;          
    
end
auditTrailParams.source = inputname(1);
auditTrailParams.params = params;
auditTrailParams.cparams = cparams;
filteredData = xtp_auditTrail(filteredData, funcname, version, filteredData.info.rundate, auditTrailParams);


