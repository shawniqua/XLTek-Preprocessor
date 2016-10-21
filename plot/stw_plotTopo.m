load topomap
xtp_build_environment

hbid = input('headbox_id:');
% plot(headx,heady);hold on 
% plot(locs(:,1), locs(:,2), 'Marker', 'o', 'LineStyle', 'none')
% for pair=1:size(cohpairs,1)
%     xvals=XTP_HEADBOXES(1).plotLocations(cohpairs(pair,:),1);
%     yvals=XTP_HEADBOXES(1).plotLocations(cohpairs(pair,:),2);
%     line(xvals,yvals);
% end

% now plot it as a 2000 x 2000 image map
imgSize = 200;
figure
locs = (imgSize/2)+(100*XTP_HEADBOXES(hbid).plotLocations);    % convert plotLocations to indexes on a 2000x2000 pixel grid
cols = round(locs(:,1));   %y coordinates = columns
rows = round(locs(:,2));   %x coordinates = rows
cols(5) = 100;    % hardocde for A1 and A2 being out of range
cols(18) = 100;
knownSpots = sub2ind([imgSize imgSize],rows,cols);  % these are the indexes of the plot locations
testcolors =  [8 6 6 6 6 6 6 6 6 6 8 8 8 8 10 10 10 10 10 10 10 10 10 8 8 8 8 8 8 8 8 8 8 8 8];
imgMap = NaN(imgSize);
imgMap(knownSpots) = testcolors;
imagesc(imgMap)
