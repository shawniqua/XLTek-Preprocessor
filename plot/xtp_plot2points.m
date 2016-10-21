function handle = xtp_plot2points(pt1,pt2,varargin)
% plots lines between two sets of points identified by [x y] coordinates or
% by international 10-20 electrode location. passes any additional
% arguments to plotting function.
% EXAMPLES: 
%       xtp_plot2points('Fp1','F3')
%       xtp_plot2points([-0.1 .8], [-0.3 .7])
%       xtp_plot2points({'Fp1' 'Fp2' 'F7' 'F8'},{'F7' 'F8' 'T3' 'T4'})
%       xtp_plot2points('Fp1','F3','LineStyle','.-','LineSize',3)
%       
% where pt1 is a Px2 matrix, one row for each point of origin (column 1 for
% the x coordinate and column 2 for the y coordinate). Pt2 is the same for
% the corresponding destination points. pt2 must be of the same length as
% pt1.
%
% alternatively, pt1 and pt2 may each be a cell array of strings, where each
% string is the name of an international 10-20 electrode location ('Fp1',
% etc). again, pt2 must be of the same length as pt1.
%
% CHANGE CONTROL
% VER   DATE        PERSON          CHANGE
% ----- ----------- --------------- ---------------------------------------
% 1.0   05/25/09    S. Williams     Created
% 1.1   05/27/09    S. Williams     if the points are in the same
%                                   horizontal line then call xtp_plotArc
%                                   to create an arc instead. Also plot
%                                   dots at the endpoints
% 1.2   05/29/09    S. Williams     assume XTP_PLOT_LOCATIONS has already
%                                   been populated. Take out dashes from
%                                   channel names. support 10-20 locations
%                                   passed as strings if it's just one pair
%                                   of points. Do not automatically plot
%                                   the endpoint markers.

global XTP_PLOT_LOCATIONS

funcname = 'xtp_plot2points';
version = 'v1.2';

if isstr(pt1)
    pt1 = {pt1};
    pt2 = {pt2};
end

if iscellstr(pt1)
    for p = 1:length(pt1)
        pt1m(p,:) = XTP_PLOT_LOCATIONS.(upper(strrep(pt1{p},'-','')));
        pt2m(p,:) = XTP_PLOT_LOCATIONS.(upper(strrep(pt2{p},'-','')));
    end
    pt1 = pt1m;
    pt2 = pt2m;
end

if pt1(2) == pt2(2)     % if the points are in the same horizontal line then create an arc. THIS ASSUMES ONLY ONE PAIR OF POINTS!!!
    if nargin > 2
        handle = xtp_plotArc(pt1, pt2, varargin{:});
    else
        handle = xtp_plotArc(pt1, pt2);
    end
else
    % plot([pt1(:,1) pt2(:,1)]',[pt1(:,2) pt2(:,2)]','Marker','o','Color','k','LineStyle','none');hold on
    if nargin > 2
        handle = plot([pt1(:,1) pt2(:,1)]',[pt1(:,2) pt2(:,2)]', varargin{:});
    else
        handle = plot([pt1(:,1) pt2(:,1)]',[pt1(:,2) pt2(:,2)]');
    end
end    