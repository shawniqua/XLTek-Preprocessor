function cohSlope = xtp_cohSlope(coh, absval)
% Finds the slope of the coherency function at each frequency
%
% EXAMPLE: cohSlope = stw_cohSlope(coh, [absval])
%   If absval is set to 'Y' function will output the absolute value of the
%   slope (i.e. rate of change). Otherwise it will be the calcuated slope.
%
% CHANGE CONTROL:
% VER   DATE        PERSON          CHANGE
% ----- ----------- --------------- ---------------------------------------
% 1.0   03/11/09    S. Williams     Created.
%DON'T FORGET TO CHANGE THE VERSION NUMBER BELOW.

functionname = 'xtp_cohSlope.m';
version = 'v1.0';

if nargin > 1
    do_absval = strcmpi(absval, 'y');
else
    do_absval = 0;
end
cohSlope = coh;
cohSlope.info.datatype = 'COHERENCY SLOPES';
cohSlope.info.source = inputname(1);
cohSlope.info.generatedBy = functionname;
cohSlope.info.version = version;
cohSlope.info.rundate = clock;
switch do_absval
    case 1
        cohSlope.info.slopeType = 'ACTUAL SLOPE';
    case 0
        cohSlope.info.slopeType = 'ABS VALUE OF SLOPE';
end
for c = 1:length(coh.output)
    N = size(coh.output{c}.C,1);
    if do_absval
        cohSlope.output{c}.C(2:N) = abs(coh.output{c}.C(2:N) - coh.output{c}.C(1:N-1))./(coh.output{c}.f(2:N) - coh.output{c}.f(1:N-1))';
    else
        cohSlope.output{c}.C(2:N) = (coh.output{c}.C(2:N) - coh.output{c}.C(1:N-1))./(coh.output{c}.f(2:N) - coh.output{c}.f(1:N-1))';
    end
    cohSlope.output{c}.C(1) = 0;
end
    