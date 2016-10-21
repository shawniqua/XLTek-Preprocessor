function xtp_globalize(varargin)

for v = 1:nargin
    argname = inputname(v);
    dummyvar = varargin{v};
    cmd = ['clear ' argname];
    evalin('base', cmd);
    cmd = ['global ' argname];
    evalin('base', cmd);
    eval(cmd)
    cmd = [argname ' = dummyvar;'];
    eval(cmd);
    clear dummyvar
end
end
    
