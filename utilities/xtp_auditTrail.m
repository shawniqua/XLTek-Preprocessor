function outvar = xtp_auditTrail(source,fn,ver,rundate,params)
% maintains list of processing steps run on each variable
%
% EXAMPLE: filtd = xtp_auditTrail(prefiltd,'xtp_filter', 'v1.0', clock, params)
% where params is a structure containing the relevant parameters for the
% function, and their values (e.g. cparams or filter params)
%
% output variable contains a structure array info.auditTrail with the
% following fields: 
%   .funcname, 
%   .version, 
%   .rundate (date vector format)
%   .source (string contaning name of the input variable)
%   .params (structure with fields = name of each parameter field and
%   values = their values)

% CHANGE LOG:
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   11/30/2009  S. Williams     Created.
%   DON'T FORGET TO UPDATE THE VERSION NUMBER BELOW (although
%   xtp_auditTrail is not going to go into the audit trail)

funcname = 'xtp_auditTrail';
version = 'v1.0';

if nargin < 5
    params = struct;
end

outvar = source;

if isfield(outvar.info,'auditTrail')
    outvar.info.auditTrail(end+1).funcname = fn;
    outvar.info.auditTrail(end).version = ver;
    outvar.info.auditTrail(end).rundate = rundate;
    outvar.info.auditTrail(end).source = inputname(1);
    outvar.info.auditTrail(end).params = params;
else
    outvar.info.auditTrail.funcname = fn;
    outvar.info.auditTrail.version = ver;
    outvar.info.auditTrail.rundate = rundate;
    outvar.info.auditTrail.source = inputname(1);
    outvar.info.auditTrail.params = params;
end    