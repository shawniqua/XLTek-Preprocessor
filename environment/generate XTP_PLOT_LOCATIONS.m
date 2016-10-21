global XTP_HEADBOXES XTP_PLOT_LOCATIONS
XTP_PLOT_LOCATIONS = cell2struct(mat2cell(XTP_HEADBOXES(1).plotLocations*.8,ones(35,1),2),XTP_HEADBOXES(1).lead_list,1)