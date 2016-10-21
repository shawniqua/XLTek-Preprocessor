function xtp_makeGlobal (varargin)

global dummyvar;
evalin('base', 'global dummyvar;');

for argnum = 1:nargin
    dummyvar = varargin{argnum};
    cmd = ['global ' inputname(argnum) ' ;'];
    evalin('base', cmd);
    cmd = [inputname(argnum) ' = dummyvar;'];
    evalin('base', cmd);
end

clear global dummyvar;

end
    