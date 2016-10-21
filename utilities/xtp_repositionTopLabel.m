% xtp_repositionTopLabel.m

% function to reposition the top label when a figure is resized. Keeps the
% label to 20 pixels tall and centered in the width of the figure.

u = findobj('Tag','TopLabel');
fig = gcbo;
old_units = get(fig,'Units');
set(fig,'Units','pixels');
figpos = get(fig,'Position');
upos = [0, figpos(4) - 20, figpos(3), 20];
set(u,'Position',upos);
set(fig,'Units',old_units);