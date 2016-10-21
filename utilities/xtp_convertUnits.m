function outdata = xtp_convertUnits(indata)
% converts units from mV to uV

funcname = 'xtp_convertUnits';
version = 'v1.0';

numepochs = size(indata.data,2);
if isfield(indata,'info')
    outdata.info = indata.info;
end
outdata.info.datatype = 'TIMESERIES';
outdata.info.generatedBy = funcname;
outdata.info.version = version;
outdata.info.source = inputname(1);
outdata.info.rundate = clock;

for ep = 1:numepochs
    if strcmpi(indata.metadata(ep).units,'mV')
        outdata.metadata(ep) = indata.metadata(ep);
        outdata.data{ep} = indata.data{ep}*1000;
        outdata.metadata(ep).units = 'uV';
    else
        fprintf(1,'WARNING: epoch # %d has units of %s - not converted.\n',ep,indata.metadata(ep).units);
        outdata.metadata(ep) = indata.metadata(ep);
        outdata.data{ep} = indata.data{ep};
    end
end