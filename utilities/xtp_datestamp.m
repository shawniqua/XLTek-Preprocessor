function dsh = xtp_datestamp()
% Labels the current figure with the current date in the lower right corner. 
% if existing datestamp handle is provided, deletes any existing text with the same handle.
%
% EXAMPLE: dsHandle = xtp_datestamp([fh])
% where fh is the figure handle (default current figure)

% WOULD HAVE LIKED TO IMPLEMENT THE FOLLOWING ARGUMENTS:
%       dsHandle is the object handle of the datestamp annotation (if
%           provided, will replace the specified datestamp)
%       text is the text string (default current time and date)
% 
% (c) 2016 Shawniqua T. Williams, MNG, MD 
%          University of Pensylvania


% switch nargin
%     case 0
%         fh = gcf;
%         text = datestr(now);
%         dsh = -1;
%     case 1
%         % gotta figure out whether it is text, a figure handle or an
%         % annotation handle and act appropriately
%     case 2
%         % gotta do some figuring
%     case 3
%         fh = varargin{1};
%         dsh = varargin{2};
%         text = varargin{3};
%     otherwise
%         disp('Cannot interpret more than 4 arguments. Try help xtp_datestamp for help.')
%         return
% end

dsh = annotation('textbox', [0.90 0.025 0.1 0.05], 'EdgeColor', 'none', 'HorizontalAlignment', 'left', 'FontSize', 8, 'String', datestr(now));
end