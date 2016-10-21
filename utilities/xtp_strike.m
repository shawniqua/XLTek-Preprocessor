function [line1 line2] = stw_strike(axisHandle)
% draws big black lines through an axis
% EXAMPLE: [line1 line2] = stw_strike(axisHandle)

if nargin < 1
    axisHandle = gca;
end
axPos = get(axisHandle, 'Position');
lineX = [axPos(1) sum(axPos([1 3]))];
lineY = [axPos(2) sum(axPos([2 4]))];

line1 = annotation('line', lineX, lineY, 'LineWidth', 2, 'Color', 'k');
line2 = annotation('line', lineX, lineY([2 1]), 'LineWidth', 2, 'Color', 'k');

end