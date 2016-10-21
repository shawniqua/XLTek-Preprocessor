function th = stw_title(text, th)
% Labels the current figure with the specified text. 
% if title handle is provided, deletes any existing text with the same handle.
%
% EXAMPLE: titleHandle = stw_title(text, [titleHandle])
%

if nargin == 2
    delete(th)
end

th = annotation('textbox', [0 0.95 1 0.05], 'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'String', text);
end