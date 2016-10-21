function xtp_globalize(varargin)

for a = 1:nargin
    varlist = who(varargin{a});
    nvars = size(varlist,2);
    for v=1:nvars
        argname = varlist{v};
        cmd = ['dummyvar = ' argname];
        evalin('base', cmd)

        cmd = ['clear ' argname];
        evalin('base', cmd);

        cmd = ['global ' argname];
        evalin('base', cmd);

        cmd = [argname ' = dummyvar;'];
        evalin('base',cmd);
        
        evalin('base', 'clear dummyvar');
    end
end
end
    
