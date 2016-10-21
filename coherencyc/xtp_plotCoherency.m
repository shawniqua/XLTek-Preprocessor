function xtp_plotCoherency(coh1, coh2, coherencyPairNum, newwindow, params)
% Plots two coherency traces on the same axis, with error bars if given.
%
% EXAMPLE: xtp_plotCoherency(coh1, coh2, coherencyPairNum, [newwindow], [params])
%
% Change Control:
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   01/06/09    S. Williams     Created
% ** DON'T FORGET TO UPDATE VERSION IN THE CODE BELOW!!! **

funcname = 'xtp_plotCoherency.m';
version = 'v1.0';

global XTP_HEADBOXES XTP_GLOBAL_PARAMS
if nargin < 5
    params = XTP_GLOBAL_PARAMS;
end

if nargin < 4
    if params.interactive
        newwindow = input('Plot in a  new window? [Y/N] ', 's');
    else
        newwindow = 'Y';
    end
end
if strcmpi(newwindow, 'Y')
    figure;
end

switch coh1.coherencyinfo.cparams.err(1)
    case 2
        plot_vector(coh1.data{coherencyPairNum}.C, coh1.data{coherencyPairNum}.f, 'n', coh1.data{coherencyPairNum}.Cerr, 'b');
    otherwise
        plot_vector(coh1.data{coherencyPairNum}.C, coh1.data{coherencyPairNum}.f, 'n');
end

hold on

switch coh2.coherencyinfo.cparams.err(1)
    case 2
        plot_vector(coh2.data{coherencyPairNum}.C, coh2.data{coherencyPairNum}.f, 'n', coh2.data{coherencyPairNum}.Cerr, 'g');
    otherwise
        plot_vector(coh2.data{coherencyPairNum}.C, coh2.data{coherencyPairNum}.f, 'n');
end
hold off
set(gca, 'FontSize', 6)
lead1 = coh1.coherencyinfo.cohpairs(coherencyPairNum,1);    % assume the same for coh1 and coh2!!
lead2 = coh1.coherencyinfo.cohpairs(coherencyPairNum,2);    % assume the same for coh1 and coh2!!
hbid = params.headboxID;    
fprintf('Labels printed according to headbox %s. Please update params if this is inappropriate.\n', XTP_HEADBOXES(hbid).name);
titlestr = [XTP_HEADBOXES(hbid).lead_list{lead1} ' vs. ' XTP_HEADBOXES(hbid).lead_list{lead2}];
title(titlestr);
end